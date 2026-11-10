#!/usr/bin/env bash
# Rebuilds everything the web map serves from docs/data/, for all districts.
# This code should be 100% reusable for adding new districts.
# Run from the project root:  ./build_site.sh
set -euo pipefail
cd "$(dirname "$0")"

DB=warehouse.duckdb
EXPORT_SQL=scripts/sql/09_export.sql

mkdir -p data/out docs/data

# 1. DuckDB -> GeoJSON for the whole city, card files per district, category list
duckdb "$DB" < "$EXPORT_SQL"

# 2. GeoJSON -> one PMTiles file for the whole city (tippecanoe 2.17+)
tippecanoe \
  -o docs/data/streets.pmtiles --force \
  -l streets -Z11 -z16 \
  -y feature_id -y name -y district -y feature_type -y category \
  --no-feature-limit --no-tile-size-limit \
  data/out/streets.geojsonl

# 3. Tidy up the old single-district files from earlier builds, if present
rm -f docs/data/stare_mesto.pmtiles docs/data/stare_mesto_popups.json data/out/stare_mesto.geojsonl

ls -lh docs/data/ docs/data/popups/*/