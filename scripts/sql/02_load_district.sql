LOAD spatial;
--Loader works by district and helps to standardize column names, especially for etymology columns.
--

--change variable below for different districts

SET VARIABLE district_code = 'stare-mesto';
SET VARIABLE source_file   = 'data/raw/staremesto.geojson';

DELETE FROM raw.osm_street_segment
WHERE district = getvariable('district_code');

INSERT INTO raw.osm_street_segment BY NAME
SELECT
    getvariable('district_code') AS district,
    "@id"                        AS osm_id,
    geom,
    COLUMNS('^(highway|name|name:1908-1918|name:1908-1945|name:1918-1945|
    name:de|name:en|name:hu|name:ru|name:sk|
    name:etymology|name:etymology:wikidata|name:etymology:wikipedia|
    name:wikipedia|network:wikidata|
    old_name|old_name:-1991-04-01|old_name:1918-1938|old_name:1920-1932|old_name:1932-WWII|old_name:1939-1945|old_name:\?-1991-04-01|old_name:de|old_name:de:until_1918|old_name:en|old_name:hu|old_name:hu:until_1918|
    short_name|sorting_name|start_date|wikidata|wikipedia)$')
FROM ST_Read(getvariable('source_file'));