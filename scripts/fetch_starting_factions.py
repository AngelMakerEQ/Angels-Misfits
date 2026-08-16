#!/usr/bin/env python3
"""
Fetch starting faction standings from the P99 wiki.

Parses the Starting_Faction_Standings page and outputs SQL for the
p99_reference_starting_factions table.

Must be run from a local environment with access to wiki.project1999.com.

Usage:
    python fetch_starting_factions.py [--output <file.sql>]
"""

import argparse
import json
import re
import sys
import urllib.request
import urllib.parse

WIKI_RAW = "https://wiki.project1999.com/index.php"


def fetch_page(title):
    url = f"{WIKI_RAW}?{urllib.parse.urlencode({'title': title, 'action': 'raw'})}"
    req = urllib.request.Request(url, headers={
        'User-Agent': 'AngelsMisfits-FactionReconciliation/1.0'
    })
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            return resp.read().decode('utf-8')
    except Exception as e:
        print(f"Error fetching {title}: {e}", file=sys.stderr)
        return None


def parse_starting_factions(content):
    """Parse the Starting_Faction_Standings wiki page.

    The page typically has tables organized by race, with columns for
    class/deity combinations and rows for each faction.
    """
    results = []

    # The page format varies but generally has wiki tables like:
    # {| class="wikitable"
    # ! Race !! Class !! Faction !! Standing
    # |-
    # | Human || Warrior || Knights of Truth || 100
    # |}

    # Try parsing wiki tables
    tables = re.split(r'\{\|', content)

    current_race = None
    current_class = None

    for line in content.split('\n'):
        # Detect race headers
        race_match = re.match(r'==+\s*(.+?)\s*==+', line)
        if race_match:
            potential_race = race_match.group(1).strip()
            known_races = [
                'Human', 'Barbarian', 'Erudite', 'Wood Elf', 'High Elf',
                'Dark Elf', 'Half Elf', 'Dwarf', 'Troll', 'Ogre',
                'Halfling', 'Gnome', 'Iksar',
            ]
            for r in known_races:
                if r.lower() in potential_race.lower():
                    current_race = r
                    break

        # Detect class headers
        class_match = re.match(r'===+\s*(.+?)\s*===+', line)
        if class_match:
            current_class = class_match.group(1).strip()

        # Parse table rows
        if '||' in line and current_race:
            cells = [c.strip().strip('|').strip() for c in line.split('||')]
            if len(cells) >= 2:
                # Try to extract faction name and standing value
                for i, cell in enumerate(cells):
                    # Look for patterns like "Faction Name (Warmly)" or "Faction Name: 100"
                    faction_standing = re.match(
                        r'(.+?)\s*(?:\(([^)]+)\)|:\s*([+-]?\d+))',
                        cell
                    )
                    if faction_standing:
                        fname = faction_standing.group(1).strip()
                        label = faction_standing.group(2)
                        value = faction_standing.group(3)
                        if value:
                            value = int(value)
                        results.append({
                            'race': current_race,
                            'class': current_class or 'Unknown',
                            'deity': None,
                            'faction_name': fname,
                            'standing_value': value if value else 0,
                            'standing_label': label,
                        })

    # Also try a more generic table parser
    in_table = False
    headers = []
    for line in content.split('\n'):
        if line.strip().startswith('{|'):
            in_table = True
            headers = []
            continue
        if line.strip().startswith('|}'):
            in_table = False
            continue
        if in_table and line.strip().startswith('!'):
            headers = [h.strip().strip('!').strip() for h in line.split('!!')]
        if in_table and line.strip().startswith('|') and '||' in line:
            cells = [c.strip().strip('|').strip() for c in line.split('||')]
            if len(cells) >= 3 and headers:
                row = dict(zip([h.lower() for h in headers], cells))
                faction = row.get('faction', row.get('faction name', ''))
                standing = row.get('standing', row.get('value', ''))
                race = row.get('race', current_race or '')
                cls = row.get('class', current_class or '')

                if faction and standing:
                    try:
                        sval = int(re.sub(r'[^\d+-]', '', standing))
                    except ValueError:
                        sval = 0
                    label_match = re.search(r'(Ally|Warmly|Kindly|Amiable|Indifferent|Apprehensive|Dubious|Threatening|Scowls)', standing, re.IGNORECASE)
                    results.append({
                        'race': race,
                        'class': cls,
                        'deity': row.get('deity'),
                        'faction_name': faction,
                        'standing_value': sval,
                        'standing_label': label_match.group(1) if label_match else None,
                    })

    return results


def escape_sql(s):
    if s is None:
        return 'NULL'
    return s.replace("\\", "\\\\").replace("'", "\\'")


def generate_sql(results, output_file=None):
    lines = []
    lines.append("-- Auto-generated by fetch_starting_factions.py")
    lines.append("-- Source: P99 wiki Starting_Faction_Standings page")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS p99_reference_starting_factions (")
    lines.append("  id INT AUTO_INCREMENT PRIMARY KEY,")
    lines.append("  race VARCHAR(50) NOT NULL,")
    lines.append("  class VARCHAR(50) NOT NULL,")
    lines.append("  deity VARCHAR(50) DEFAULT NULL,")
    lines.append("  faction_name VARCHAR(255) NOT NULL,")
    lines.append("  standing_value INT NOT NULL,")
    lines.append("  standing_label VARCHAR(50) DEFAULT NULL,")
    lines.append("  UNIQUE KEY uq_start_faction (race, class, faction_name),")
    lines.append("  KEY idx_faction_name (faction_name)")
    lines.append(") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;")
    lines.append("")
    lines.append("TRUNCATE TABLE p99_reference_starting_factions;")
    lines.append("")

    for r in results:
        race = escape_sql(r['race'])
        cls = escape_sql(r['class'])
        deity = f"'{escape_sql(r['deity'])}'" if r.get('deity') else 'NULL'
        fname = escape_sql(r['faction_name'])
        sval = r['standing_value']
        label = f"'{escape_sql(r['standing_label'])}'" if r.get('standing_label') else 'NULL'

        lines.append(
            f"INSERT INTO p99_reference_starting_factions "
            f"(race, class, deity, faction_name, standing_value, standing_label) "
            f"VALUES ('{race}', '{cls}', {deity}, '{fname}', {sval}, {label}) "
            f"ON DUPLICATE KEY UPDATE standing_value = VALUES(standing_value), "
            f"standing_label = VALUES(standing_label);"
        )

    lines.append("")
    lines.append(f"-- Total: {len(results)} starting faction entries")

    output = '\n'.join(lines)
    if output_file:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(output)
        print(f"Wrote {len(results)} entries to {output_file}", file=sys.stderr)
    else:
        print(output)


def main():
    parser = argparse.ArgumentParser(description='Fetch P99 starting faction standings')
    parser.add_argument('--output', '-o', help='Output SQL file')
    parser.add_argument('--from-file', help='Read from a local file instead of fetching')
    args = parser.parse_args()

    if args.from_file:
        with open(args.from_file, 'r', encoding='utf-8') as f:
            content = f.read()
    else:
        print("Fetching Starting_Faction_Standings...", file=sys.stderr)
        content = fetch_page('Starting_Faction_Standings')
        if not content:
            print("Failed to fetch page", file=sys.stderr)
            sys.exit(1)

    results = parse_starting_factions(content)
    print(f"Parsed {len(results)} starting faction entries", file=sys.stderr)

    if results:
        generate_sql(results, args.output)
    else:
        print("Warning: no data parsed. The page format may need manual inspection.", file=sys.stderr)
        print("Try fetching the raw page and inspecting its structure:", file=sys.stderr)
        print('  curl -s "https://wiki.project1999.com/index.php?title=Starting_Faction_Standings&action=raw" > starting_factions_raw.txt', file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
