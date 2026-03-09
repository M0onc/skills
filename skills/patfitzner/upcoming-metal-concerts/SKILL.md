---
name: upcoming-metal-concerts
description: Search for upcoming metal concerts and festivals by country, city, or band using concerts-metal.com. Use when the user asks about upcoming metal shows, gigs, or festivals.
metadata: {"openclaw":{"emoji":"🤘","requires":{"bins":["python3"]}}}
---

# Upcoming Metal Concerts

Search for upcoming metal concerts and festivals worldwide via concerts-metal.com.

## Usage

```bash
python3 {baseDir}/events.py --country ES --city Valencia
```

## Command Options

- `--country` (optional): ISO country code (default: ES). Use `--list-countries` to see all supported codes.
- `--city` (optional): Filter by city name (case-insensitive, partial match)
- `--band` (optional): Filter by band name (case-insensitive, partial match)
- `--list-countries` (optional): Print supported country codes and exit

## Examples

```bash
# All upcoming metal concerts in Spain
python3 {baseDir}/events.py --country ES

# Metal shows in Valencia
python3 {baseDir}/events.py --country ES --city Valencia

# Find a specific band's shows in the UK
python3 {baseDir}/events.py --country GB --band "Kreator"

# List supported countries
python3 {baseDir}/events.py --list-countries
```

## Output

The script prints a JSON array to stdout. Each entry contains:

- `date`: Event date (YYYY-MM-DD)
- `artists`: List of artist/band names
- `venue`: Venue name
- `city`: City name
- `url`: Link to the event page on concerts-metal.com

Present the results to the user as a readable table sorted by date.

## Notes

- No API key required. Data is sourced from concerts-metal.com broadcast pages.
- Coverage is excellent for metal, punk, hardcore, and adjacent genres across 50+ countries.
