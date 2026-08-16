#!/usr/bin/env python3
"""
Fetch faction data from P99 wiki faction pages.

Fetches individual faction wiki pages and the Category:Factions index,
then parses them to extract NPC-faction relationships, hit values, and
membership information. Outputs SQL for the p99_reference_factions table.

Must be run from a local environment with access to wiki.project1999.com
(blocked from remote Claude Code sessions).

Usage:
    python fetch_faction_pages.py [--output <file.sql>] [--cache-dir <dir>]

The script fetches in batches of 50 using the MediaWiki API to minimize
requests.
"""

import argparse
import json
import os
import re
import sys
import time
import urllib.request
import urllib.parse
from pathlib import Path

WIKI_API = "https://wiki.project1999.com/api.php"
WIKI_RAW = "https://wiki.project1999.com/index.php"

FACTION_HIT_RE = re.compile(
    r'\{\{Faction\s*\|\s*([^|]+?)\s*\|\s*([+-]?\d+)\s*\}\}',
    re.IGNORECASE
)

NPC_LINK_RE = re.compile(
    r'\[\[([^\]|]+?)(?:\|[^\]]+?)?\]\]'
)


def fetch_url(url, retries=3, delay=2):
    """Fetch a URL with retries and exponential backoff."""
    for attempt in range(retries):
        try:
            req = urllib.request.Request(url, headers={
                'User-Agent': 'AngelsMisfits-FactionReconciliation/1.0'
            })
            with urllib.request.urlopen(req, timeout=30) as resp:
                return resp.read().decode('utf-8')
        except Exception as e:
            if attempt < retries - 1:
                wait = delay * (2 ** attempt)
                print(f"  Retry {attempt + 1}/{retries} after {wait}s: {e}", file=sys.stderr)
                time.sleep(wait)
            else:
                print(f"  Failed after {retries} attempts: {e}", file=sys.stderr)
                return None


def fetch_category_members(category, limit=500):
    """Fetch all pages in a MediaWiki category."""
    members = []
    cmcontinue = None

    while True:
        params = {
            'action': 'query',
            'list': 'categorymembers',
            'cmtitle': f'Category:{category}',
            'cmlimit': str(min(limit, 500)),
            'cmtype': 'page',
            'format': 'json',
        }
        if cmcontinue:
            params['cmcontinue'] = cmcontinue

        url = f"{WIKI_API}?{urllib.parse.urlencode(params)}"
        data = fetch_url(url)
        if not data:
            break

        result = json.loads(data)
        for member in result.get('query', {}).get('categorymembers', []):
            members.append(member['title'])

        if 'continue' in result and 'cmcontinue' in result['continue']:
            cmcontinue = result['continue']['cmcontinue']
        else:
            break

    return members


def fetch_pages_batch(titles, cache_dir=None):
    """Fetch multiple wiki pages in a single API call (max 50)."""
    pages = {}

    for i in range(0, len(titles), 50):
        batch = titles[i:i+50]
        titles_param = '|'.join(batch)

        params = {
            'action': 'query',
            'titles': titles_param,
            'prop': 'revisions',
            'rvprop': 'content',
            'format': 'json',
            'redirects': '1',
        }

        url = f"{WIKI_API}?{urllib.parse.urlencode(params)}"
        data = fetch_url(url)
        if not data:
            continue

        result = json.loads(data)
        for page_id, page_data in result.get('query', {}).get('pages', {}).items():
            if int(page_id) < 0:
                continue
            title = page_data.get('title', '')
            revisions = page_data.get('revisions', [])
            if revisions:
                content = revisions[0].get('*', '')
                pages[title] = content

                if cache_dir:
                    safe_name = title.replace('/', '_').replace(':', '_')
                    cache_path = Path(cache_dir) / f"{safe_name}.wiki"
                    cache_path.write_text(content, encoding='utf-8')

        if i + 50 < len(titles):
            time.sleep(1)

    return pages


def parse_faction_page(title, content):
    """Parse a faction wiki page for NPC relationships and hit values."""
    entries = []

    # Look for faction hit templates
    for match in FACTION_HIT_RE.finditer(content):
        npc_name = match.group(1).strip()
        hit_value = int(match.group(2))
        entries.append({
            'faction_name': title.replace(' (faction)', '').replace('_(faction)', ''),
            'npc_name': npc_name,
            'hit_value': hit_value,
            'is_member': 0,
        })

    # Look for "NPCs that affect this faction" style sections
    in_npc_section = False
    for line in content.split('\n'):
        if re.search(r'==\s*(NPC|Mob|Kill|Affect)', line, re.IGNORECASE):
            in_npc_section = True
            continue
        if line.startswith('==') and in_npc_section:
            in_npc_section = False
            continue

        if in_npc_section:
            # Look for bullet-pointed NPC entries with values
            hit_match = re.search(r'\[\[([^\]]+?)\]\].*?([+-]\d+)', line)
            if hit_match:
                npc_name = hit_match.group(1).strip()
                if '|' in npc_name:
                    npc_name = npc_name.split('|')[0].strip()
                hit_value = int(hit_match.group(2))
                faction_name = title.replace(' (faction)', '').replace('_(faction)', '')
                key = (faction_name, npc_name)
                if not any(e['faction_name'] == faction_name and e['npc_name'] == npc_name for e in entries):
                    entries.append({
                        'faction_name': faction_name,
                        'npc_name': npc_name,
                        'hit_value': hit_value,
                        'is_member': 0,
                    })

    # Look for "Members" or "NPCs in this faction" sections
    in_member_section = False
    for line in content.split('\n'):
        if re.search(r'==\s*(Member|Belong|Part of|NPC.*faction)', line, re.IGNORECASE):
            in_member_section = True
            continue
        if line.startswith('==') and in_member_section:
            in_member_section = False
            continue

        if in_member_section:
            for link_match in NPC_LINK_RE.finditer(line):
                npc_name = link_match.group(1).strip()
                faction_name = title.replace(' (faction)', '').replace('_(faction)', '')
                existing = [e for e in entries if e['faction_name'] == faction_name and e['npc_name'] == npc_name]
                if existing:
                    existing[0]['is_member'] = 1
                else:
                    entries.append({
                        'faction_name': faction_name,
                        'npc_name': npc_name,
                        'hit_value': None,
                        'is_member': 1,
                    })

    return entries


def escape_sql(s):
    if s is None:
        return 'NULL'
    return s.replace("\\", "\\\\").replace("'", "\\'")


def generate_sql(results, output_file=None):
    lines = []
    lines.append("-- Auto-generated by fetch_faction_pages.py")
    lines.append("-- Source: P99 wiki faction pages (Category:Factions)")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS p99_reference_factions (")
    lines.append("  id INT AUTO_INCREMENT PRIMARY KEY,")
    lines.append("  wiki_title VARCHAR(255) NOT NULL,")
    lines.append("  faction_name VARCHAR(255) NOT NULL,")
    lines.append("  npc_name VARCHAR(255) DEFAULT NULL,")
    lines.append("  hit_value INT DEFAULT NULL,")
    lines.append("  is_member TINYINT(1) DEFAULT 0,")
    lines.append("  notes TEXT DEFAULT NULL,")
    lines.append("  UNIQUE KEY uq_faction_npc (faction_name, npc_name),")
    lines.append("  KEY idx_faction_name (faction_name)")
    lines.append(") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;")
    lines.append("")
    lines.append("TRUNCATE TABLE p99_reference_factions;")
    lines.append("")

    for r in results:
        wiki_title = escape_sql(r.get('wiki_title', r['faction_name']))
        fname = escape_sql(r['faction_name'])
        npc = escape_sql(r['npc_name']) if r['npc_name'] else 'NULL'
        hval = str(r['hit_value']) if r['hit_value'] is not None else 'NULL'
        is_mem = r.get('is_member', 0)

        npc_sql = f"'{npc}'" if npc != 'NULL' else 'NULL'

        lines.append(
            f"INSERT INTO p99_reference_factions (wiki_title, faction_name, npc_name, hit_value, is_member) "
            f"VALUES ('{wiki_title}', '{fname}', {npc_sql}, {hval}, {is_mem}) "
            f"ON DUPLICATE KEY UPDATE hit_value = VALUES(hit_value), is_member = VALUES(is_member);"
        )

    lines.append("")
    lines.append(f"-- Total: {len(results)} faction-NPC entries")

    output = '\n'.join(lines)
    if output_file:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"Wrote {len(results)} entries to {output_file}", file=sys.stderr)
    else:
        print(output)


def main():
    parser = argparse.ArgumentParser(description='Fetch P99 wiki faction pages')
    parser.add_argument('--output', '-o', help='Output SQL file')
    parser.add_argument('--cache-dir', help='Directory to cache fetched pages')
    parser.add_argument('--from-cache', help='Read from cached pages instead of fetching')
    parser.add_argument('--significant-only', action='store_true',
                        help='Only fetch Category:Significant_Factions')
    args = parser.parse_args()

    if args.cache_dir:
        os.makedirs(args.cache_dir, exist_ok=True)

    all_results = []

    if args.from_cache:
        cache_path = Path(args.from_cache)
        for filepath in sorted(cache_path.glob('*.wiki')):
            title = filepath.stem.replace('_', ' ')
            content = filepath.read_text(encoding='utf-8', errors='replace')
            entries = parse_faction_page(title, content)
            for e in entries:
                e['wiki_title'] = title
            all_results.extend(entries)
            if entries:
                print(f"  {title}: {len(entries)} entries", file=sys.stderr)
    else:
        categories = ['Significant Factions']
        if not args.significant_only:
            categories.append('Factions')

        all_titles = set()
        for cat in categories:
            print(f"Fetching Category:{cat}...", file=sys.stderr)
            members = fetch_category_members(cat)
            print(f"  Found {len(members)} pages", file=sys.stderr)
            all_titles.update(members)

        titles = sorted(all_titles)
        print(f"Fetching {len(titles)} faction pages...", file=sys.stderr)

        pages = fetch_pages_batch(titles, cache_dir=args.cache_dir)
        print(f"  Retrieved {len(pages)} pages", file=sys.stderr)

        for title, content in pages.items():
            entries = parse_faction_page(title, content)
            for e in entries:
                e['wiki_title'] = title
            all_results.extend(entries)
            if entries:
                print(f"  {title}: {len(entries)} entries", file=sys.stderr)

    print(f"\nTotal: {len(all_results)} faction-NPC entries", file=sys.stderr)
    generate_sql(all_results, args.output)


if __name__ == '__main__':
    main()
