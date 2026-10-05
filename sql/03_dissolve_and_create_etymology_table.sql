--First part dissolves feature segments into streets by grouping by name

CREATE OR REPLACE TABLE raw.osm_street AS
SELECT
    district,
    name,
    any_value("name:en")                 AS name_en,
    'street'                             AS feature_type,
    count(*)                             AS segment_count,
    list(DISTINCT highway)               AS highway_types,
    list(osm_id)                         AS osm_ids,
    ST_LineMerge(ST_Union_Agg(geom))     AS geom
FROM raw.osm_street_segment
WHERE name IS NOT NULL
  AND ST_GeometryType(geom) IN ('LINESTRING', 'MULTILINESTRING')
GROUP BY district, name

UNION ALL

SELECT
    district,
    name,
    any_value("name:en"),
    'area',
    count(*),
    list(DISTINCT highway),
    list(osm_id),
    ST_Union_Agg(geom)
FROM raw.osm_street_segment
WHERE name IS NOT NULL
  AND ST_GeometryType(geom) IN ('POLYGON', 'MULTIPOLYGON')
GROUP BY district, name;

-- Second part creates a table of the results of  the etymology columns in OpenStreetMap for subsequent 04 and 05 steps which create
-- a string for a wikidata query and read those parts into a table in raw, respectively.
CREATE OR REPLACE TABLE raw.etymology_coverage AS
WITH segment AS (
    SELECT
        district,
        name,
        nullif(trim("name:etymology:wikidata"),  '') AS qid,
        nullif(trim("name:etymology:wikipedia"), '') AS sitelink,
        nullif(trim("name:etymology"),           '') AS etym_text
    FROM raw.osm_street_segment
    WHERE name IS NOT NULL
),
rolled AS (
    SELECT
        district,
        name,
        count(*)                  AS segment_count,
        max(qid)                  AS qid,
        max(sitelink)             AS sitelink,
        max(etym_text)            AS etym_text,
        count(DISTINCT qid)       AS n_qid,
        count(DISTINCT sitelink)  AS n_sitelink,
        count(DISTINCT etym_text) AS n_etym_text
    FROM segment
    GROUP BY district, name
)
SELECT
    district,
    name,
    segment_count,
    qid       IS NOT NULL AS has_qid,
    sitelink  IS NOT NULL AS has_sitelink,
    etym_text IS NOT NULL AS has_etym_text,
    qid,
    sitelink,
    etym_text,
    (n_qid > 1 OR n_sitelink > 1 OR n_etym_text > 1) AS has_conflict
FROM rolled
ORDER BY district, name;