-- Creates macro to generate slug 'featureid' combining district and feature name, without diacritcal markings.
-- Writes curated data to the gitignored 'out' folder. Then we'll copy each new district manually into "curated" to avoid overwrite disasters.
-- Google Drive .csv will be the source of truth. script 07 updates /curated with the three sheets after data are added from research.
-- Collision check step will return (print in terminal) any features with potentially different names (after stripping punctuation and diacriticals) within a district . I don't expect this to happen.
----Strip_accents and punctuation removal is lossy.
load SPATIAL;

CREATE OR REPLACE MACRO slug(d, n) AS
    d || '--' ||
    lower(
      regexp_replace(
        regexp_replace(strip_accents(n), '[^a-zA-Z0-9]+', '-', 'g'),
        '(^-+|-+$)', '', 'g'
      )
    );

COPY (
    SELECT
        slug(s.district, s.name) AS feature_id,
        s.district,
        s.name,
        max(c.qid)               AS qid,                                -- Some squares (namestia) are included as both polygons and lines; this aggregates them since their names are identical.
        count(DISTINCT c.qid) > 1         AS qid_conflict,              -- Flags if any qid conflicts happen because max(qid) would silently drop the others.
        ''                       AS category,
        ''                       AS category_note,
        ''                       AS blurb_en,
        ''                       AS blurb_sk,
        ''                       AS context        
    FROM raw.osm_street s
    LEFT JOIN raw.etymology_coverage c
           ON c.district = s.district
          AND c.name     = s.name
    GROUP BY s.district, s.name                                         -- Geometry is stored in the 'raw.osm_street' table so distinction is unneeded here
    ORDER BY s.district, s.name
) TO 'data/out/seed_feature.csv' (HEADER, DELIMITER ',');

COPY (
    SELECT DISTINCT
        w.qid,
        w.label_en,
        w.label_sk,
        w.description_en,
        w.description_sk,
        w.birth_date,
        w.death_date,
        w.article_en,
        w.article_sk,
        w.image_url,
        w.wd_citizenship,        -- wd prefix for Wikidata pulls. Only here for reference.
        w.wd_occupation,         -- wd prefix for Wikidata pulls. Only here for reference.
        w.wd_instance_of,        -- wd prefix for Wikidata pulls. Only here for reference.
        ''  AS category,
        ''  AS nationality,
        ''  AS occupation,
        ''                       AS blurb_en,
        ''                       AS blurb_sk,
        ''                       AS source_note
    FROM raw.wikidata_namesake w
    ORDER BY w.label_en
) TO 'data/out/seed_namesake.csv' (HEADER, DELIMITER ',');

COPY (
    WITH wide AS (
        SELECT
            district,
            name AS current_name,
            "name:1908-1918", "name:1908-1945", "name:1918-1945",
            "name:de", "name:hu",
            "old_name",
            "old_name:-1991-04-01", "old_name:?-1991-04-01",
            "old_name:1918-1938", "old_name:1920-1932",
            "old_name:1932-WWII", "old_name:1939-1945",
            "old_name:de", "old_name:de:until_1918",
            "old_name:en", "old_name:hu", "old_name:hu:until_1918"
        FROM raw.osm_street_segment
        WHERE name IS NOT NULL
    ),
    long AS (
        UNPIVOT wide
        ON COLUMNS(* EXCLUDE (district, current_name))
        INTO NAME tag VALUE historical_name
    ),
    mapped AS (
        SELECT DISTINCT
            slug(district, current_name)  AS feature_id,
            current_name,
            trim(historical_name)         AS name,
            tag,
            CASE
                WHEN tag LIKE '%:de%' THEN 'de'
                WHEN tag LIKE '%:hu%' THEN 'hu'
                WHEN tag LIKE '%:en%' THEN 'en'
                ELSE ''
            END                           AS lang,
            CASE
                WHEN tag = 'name:1908-1918'    THEN '1908'
                WHEN tag = 'name:1908-1945'    THEN '1908'
                WHEN tag = 'name:1918-1945'    THEN '1918'
                WHEN tag = 'old_name:1918-1938' THEN '1918'
                WHEN tag = 'old_name:1920-1932' THEN '1920'
                WHEN tag = 'old_name:1932-WWII' THEN '1932'
                WHEN tag = 'old_name:1939-1945' THEN '1939'
                ELSE ''
            END                           AS valid_from,
            CASE
                WHEN tag = 'name:1908-1918'          THEN '1918'
                WHEN tag = 'name:1908-1945'          THEN '1945'
                WHEN tag = 'name:1918-1945'          THEN '1945'
                WHEN tag = 'old_name:1918-1938'      THEN '1938'
                WHEN tag = 'old_name:1920-1932'      THEN '1932'
                WHEN tag = 'old_name:1932-WWII'      THEN '1939'
                WHEN tag = 'old_name:1939-1945'      THEN '1945'
                WHEN tag LIKE '%until_1918'          THEN '1918'
                WHEN tag LIKE 'old_name:%1991-04-01' THEN '1991-04-01'
                ELSE ''
            END                           AS valid_to,
            'osm'                         AS source,
            ''                            AS context
        FROM long
        WHERE historical_name IS NOT NULL
          AND trim(historical_name) <> ''
    )
    SELECT feature_id, current_name, name, lang, valid_from, valid_to, tag, source, context
    FROM mapped
    ORDER BY feature_id, valid_from, name
) TO 'data/out/seed_name_history.csv' (HEADER, DELIMITER ',');



-- Collision check for duplicate features which could erase manually curated data
SELECT feature_id, count(*), list(name)
FROM read_csv('data/out/seed_feature.csv', header = true)
GROUP BY feature_id
HAVING count(*) > 1;