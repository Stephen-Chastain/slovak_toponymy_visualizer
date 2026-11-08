#!/usr/bin/env bash
# Rebuilds everything the web map serves from docs/data/.
# Run from anywhere:  ./build_site.sh
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p data/out docs/data

# 1. DuckDB -> newline-delimited GeoJSON (for tiles) + card JSON
duckdb warehouse.duckdb < scripts/sql/09_export.sql

# 2. GeoJSON -> PMTiles. Needs tippecanoe 2.17+ (felt/tippecanoe) for .pmtiles output.
#    -l streets     layer name; index.html reads source-layer "streets"
#    -Z11 -z16      zoom range baked into the tiles; MapLibre overzooms beyond 16
#    -y ...         keep only these properties in the tiles
tippecanoe \
  -o docs/data/stare_mesto.pmtiles --force \
  -l streets -Z11 -z16 \
  -y feature_id -y name_sk -y feature_type -y category \
  --no-feature-limit --no-tile-size-limit \
  data/out/stare_mesto.geojsonl

ls -lh docs/data/