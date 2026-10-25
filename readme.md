1. Query street geodata and relevant metadata from OSM in .geojson format.
2. Process geojsons and sort into duckdb table which labels each object by 'district' based on their query vintage.
3. Dissolve line segments for each street by grouping objects by street name ['name']
4. Extract wikidata etymology tags, if present, from all named streets.



duckdb: Automatic processing pipeline for street names queried from OSM. Chosen because this project was an excuse to learn Duckdb.

Google Drive & Google Sheets: Curate and store data in Google Sheets. Chosen for easy collaboration and to avoid common text encoding errors with Slovak diacritical markings that come up with .csv reading in Excel. File sizes are also not prohibitively large Functions as the project's single source of truth.
- updates are manual
- sources are helpful
- Google Sheet 
