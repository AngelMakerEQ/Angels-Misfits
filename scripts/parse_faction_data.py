#!/usr/bin/env python3
"""
Parse faction hit data from cached P99 wiki NPC pages.

Reads raw wiki markup from the P99 wiki cache directory and extracts
faction hit information from {{Namedmobpage}} templates. Outputs SQL
INSERT statements for the p99_reference_npc_factions table.

Usage:
    python parse_faction_data.py <wiki_cache_dir> [--output <file.sql>]

The wiki cache directory should contain raw wiki markup files (one per
NPC page), as fetched by the MediaWiki API:
    curl -s "https://wiki.project1999.com/index.php?title=<Page>&action=raw"

Expected input format (inside {{Namedmobpage}} template):
    | faction = {{Faction|Claws of Veeshan|+1}}{{Faction|Kromzek|-5}}
  or:
    | faction = [[Claws of Veeshan]] (+1), [[Kromzek]] (-5)
  or:
    | faction = Claws of Veeshan (+1), Kromzek (-5)

Also extracts emu_id from:
    | emu_id = 12345
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path

FACTION_TEMPLATE_RE = re.compile(
    r'\{\{Faction\s*\|\s*([^|]+?)\s*\|\s*([+-]?\d+)\s*\}\}',
    re.IGNORECASE
)

FACTION_LINK_RE = re.compile(
    r'\[\[([^\]]+?)\]\]\s*\(([+-]?\d+)\)',
)

FACTION_PLAIN_RE = re.compile(
    r'([A-Z][A-Za-z\s\'`]+?)\s*\(([+-]?\d+)\)',
)

EMU_ID_RE = re.compile(
    r'^\s*\|\s*emu_id\s*=\s*(\d+)',
    re.MULTILINE
)

FACTION_LINE_RE = re.compile(
    r'^\s*\|\s*faction\s*=\s*(.*)',
    re.MULTILINE | re.IGNORECASE
)


def extract_emu_id(content):
    match = EMU_ID_RE.search(content)
    if match:
        try:
            val = int(match.group(1))
            if 0 < val < 2147483647:
                return val
        except ValueError:
            pass
    return None


def extract_faction_hits(content):
    """Extract faction hit data from wiki page content."""
    faction_match = FACTION_LINE_RE.search(content)
    if not faction_match:
        return []

    faction_text = faction_match.group(1).strip()
    if not faction_text or faction_text.lower() in ('none', 'n/a', '?', 'unknown'):
        return []

    # Handle multi-line faction fields (continuation lines start with whitespace
    # or contain faction templates, until the next pipe-delimited field)
    lines = content[faction_match.start():].split('\n')
    full_text = lines[0]
    for line in lines[1:]:
        stripped = line.strip()
        if stripped.startswith('|') and '=' in stripped and 'Faction' not in stripped:
            break
        if stripped.startswith('}}'):
            break
        if stripped:
            full_text += ' ' + stripped

    faction_text = full_text.split('=', 1)[1].strip() if '=' in full_text else full_text

    hits = []

    # Try {{Faction|Name|Value}} template format first
    for match in FACTION_TEMPLATE_RE.finditer(faction_text):
        name = match.group(1).strip()
        value = int(match.group(2))
        if name and name.lower() not in ('none', 'n/a'):
            hits.append((name, value))

    if hits:
        return hits

    # Try [[Name]] (+Value) link format
    for match in FACTION_LINK_RE.finditer(faction_text):
        name = match.group(1).strip()
        if '|' in name:
            name = name.split('|')[-1].strip()
        value = int(match.group(2))
        if name and name.lower() not in ('none', 'n/a'):
            hits.append((name, value))

    if hits:
        return hits

    # Try plain "Name (+Value)" format
    for match in FACTION_PLAIN_RE.finditer(faction_text):
        name = match.group(1).strip()
        value = int(match.group(2))
        if len(name) > 2 and name.lower() not in ('none', 'n/a', 'unknown'):
            hits.append((name, value))

    return hits


def escape_sql(s):
    """Escape a string for SQL insertion."""
    return s.replace("\\", "\\\\").replace("'", "\\'")


def parse_cache_directory(cache_dir):
    """Parse all wiki pages in the cache directory."""
    results = []
    cache_path = Path(cache_dir)

    if not cache_path.exists():
        print(f"Error: cache directory '{cache_dir}' does not exist", file=sys.stderr)
        sys.exit(1)

    files = sorted(cache_path.glob('*'))
    if not files:
        # Try subdirectories (cache may be organized by first letter)
        files = sorted(cache_path.rglob('*.txt')) + sorted(cache_path.rglob('*.wiki'))

    if not files:
        print(f"Error: no files found in '{cache_dir}'", file=sys.stderr)
        sys.exit(1)

    parsed = 0
    with_faction = 0

    for filepath in files:
        if filepath.is_dir():
            continue

        try:
            content = filepath.read_text(encoding='utf-8', errors='replace')
        except Exception as e:
            print(f"Warning: could not read {filepath}: {e}", file=sys.stderr)
            continue

        if '{{Namedmobpage' not in content and '{{namedmobpage' not in content:
            continue

        parsed += 1
        title = filepath.stem
        emu_id = extract_emu_id(content)
        hits = extract_faction_hits(content)

        if hits:
            with_faction += 1
            for faction_name, value in hits:
                results.append({
                    'wiki_title': title,
                    'emu_id': emu_id,
                    'faction_name': faction_name,
                    'faction_value': value,
                })

    print(f"Parsed {parsed} NPC pages, {with_faction} have faction data, "
          f"{len(results)} total faction hits", file=sys.stderr)
    return results


def parse_json_cache(cache_file):
    """Parse faction data from a JSON cache file (batch API responses)."""
    results = []

    with open(cache_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pages = {}
    if isinstance(data, dict):
        if 'query' in data and 'pages' in data['query']:
            pages = data['query']['pages']
        elif 'pages' in data:
            pages = data['pages']
        else:
            pages = data

    parsed = 0
    with_faction = 0

    for page_id, page_data in pages.items():
        if isinstance(page_data, dict) and 'revisions' in page_data:
            title = page_data.get('title', f'page_{page_id}')
            content = page_data['revisions'][0].get('*', '') if page_data['revisions'] else ''
        elif isinstance(page_data, str):
            title = page_id
            content = page_data
        else:
            continue

        if '{{Namedmobpage' not in content and '{{namedmobpage' not in content:
            continue

        parsed += 1
        emu_id = extract_emu_id(content)
        hits = extract_faction_hits(content)

        if hits:
            with_faction += 1
            for faction_name, value in hits:
                results.append({
                    'wiki_title': title,
                    'emu_id': emu_id,
                    'faction_name': faction_name,
                    'faction_value': value,
                })

    print(f"Parsed {parsed} NPC pages from JSON, {with_faction} have faction data, "
          f"{len(results)} total faction hits", file=sys.stderr)
    return results


def generate_sql(results, output_file=None):
    """Generate SQL INSERT statements."""
    lines = []
    lines.append("-- Auto-generated by parse_faction_data.py")
    lines.append("-- Source: P99 wiki cache ({{Namedmobpage}} template faction fields)")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS p99_reference_npc_factions (")
    lines.append("  id INT AUTO_INCREMENT PRIMARY KEY,")
    lines.append("  wiki_title VARCHAR(255) NOT NULL,")
    lines.append("  emu_id INT DEFAULT NULL,")
    lines.append("  faction_name VARCHAR(255) NOT NULL,")
    lines.append("  faction_value INT NOT NULL,")
    lines.append("  UNIQUE KEY uq_npc_faction (wiki_title, faction_name)")
    lines.append(") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;")
    lines.append("")
    lines.append("TRUNCATE TABLE p99_reference_npc_factions;")
    lines.append("")

    for r in results:
        title = escape_sql(r['wiki_title'])
        emu_id = r['emu_id'] if r['emu_id'] is not None else 'NULL'
        fname = escape_sql(r['faction_name'])
        fval = r['faction_value']

        if emu_id == 'NULL':
            lines.append(
                f"INSERT INTO p99_reference_npc_factions (wiki_title, emu_id, faction_name, faction_value) "
                f"VALUES ('{title}', NULL, '{fname}', {fval}) "
                f"ON DUPLICATE KEY UPDATE emu_id = VALUES(emu_id), faction_value = VALUES(faction_value);"
            )
        else:
            lines.append(
                f"INSERT INTO p99_reference_npc_factions (wiki_title, emu_id, faction_name, faction_value) "
                f"VALUES ('{title}', {emu_id}, '{fname}', {fval}) "
                f"ON DUPLICATE KEY UPDATE emu_id = VALUES(emu_id), faction_value = VALUES(faction_value);"
            )

    lines.append("")
    lines.append(f"-- Total: {len(results)} faction hit entries")

    output = '\n'.join(lines)

    if output_file:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"Wrote {len(results)} entries to {output_file}", file=sys.stderr)
    else:
        print(output)


def main():
    parser = argparse.ArgumentParser(
        description='Parse faction data from P99 wiki cache'
    )
    parser.add_argument(
        'input',
        help='Wiki cache directory (flat files) or JSON cache file'
    )
    parser.add_argument(
        '--output', '-o',
        help='Output SQL file (default: stdout)'
    )
    parser.add_argument(
        '--format',
        choices=['sql', 'json', 'csv'],
        default='sql',
        help='Output format (default: sql)'
    )

    args = parser.parse_args()

    input_path = Path(args.input)
    if input_path.is_file() and input_path.suffix == '.json':
        results = parse_json_cache(args.input)
    elif input_path.is_dir():
        results = parse_cache_directory(args.input)
    else:
        print(f"Error: '{args.input}' is not a directory or JSON file", file=sys.stderr)
        sys.exit(1)

    if not results:
        print("Warning: no faction data found", file=sys.stderr)
        sys.exit(0)

    if args.format == 'sql':
        generate_sql(results, args.output)
    elif args.format == 'json':
        output = json.dumps(results, indent=2)
        if args.output:
            with open(args.output, 'w') as f:
                f.write(output)
        else:
            print(output)
    elif args.format == 'csv':
        import csv
        out = open(args.output, 'w', newline='') if args.output else sys.stdout
        writer = csv.DictWriter(out, fieldnames=['wiki_title', 'emu_id', 'faction_name', 'faction_value'])
        writer.writeheader()
        writer.writerows(results)
        if args.output:
            out.close()


if __name__ == '__main__':
    main()
