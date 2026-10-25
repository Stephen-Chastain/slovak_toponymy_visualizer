1. Query street geodata and relevant metadata from OSM in .geojson format.
2. Process geojsons and sort into duckdb table which labels each object by 'district' based on their query vintage.
3. Dissolve line segments for each street by grouping objects by street name ['name']
4. Extract wikidata etymology tags, if present, from all named streets.

qids_query_wikidata.sparql.tmpl is a template that generates the wikidata file. It is referenced by buildsparql.sh which is a sed command you can run in the WSL terminal which plops all the current, valid qid's from the output of 04_qid_string_export.sql. Copy and paste this directly into wikidata for your query.

Adding a new autopopulated wikidata field: this requires a few steps, and may not be necessary unless you want to do bulk wikidata imports. I'm skeptical this will come up much. Bratislava Stare Mesto was only partially covered and I expect it's the most famous neighborhood in the whole country so it probably has the best coverage.
1. add the field to qids_query_wikidata.sparql.tmpl
2. make the lookup table in the Google Sheet, if needed
3. add it to the appropriate table in 06 seed curated o regenerate if necessary (e.g. 'occupation' and 'nationality' were added post hoc as aspects of 'namesake'). 
4. add the field's entries to 07_read_drive_csv_tables 
4. rerun 07 to bring the database up to date with curated tables.

duckdb: Automatic processing pipeline for street names queried from OSM. Chosen because this project was an excuse to learn Duckdb.

Google Drive & Google Sheets: Curate and store data in Google Sheets. Chosen for easy collaboration and to avoid common text encoding errors with Slovak diacritical markings that come up with .csv reading in Excel. File sizes are also not prohibitively large Functions as the project's single source of truth.
- updates are manual
- sources are helpful
- Google Sheet 
