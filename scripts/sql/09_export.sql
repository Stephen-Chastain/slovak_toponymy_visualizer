-- 09_export.sql
-- Writes the files the web map reads:
--   data/out/stare_mesto.geojsonl        -> tippecanoe -> docs/data/stare_mesto.pmtiles
--   docs/data/stare_mesto_popups.json    -> card content, loaded when a street is clicked
--   docs/data/categories.json            -> legend labels and colours
--
-- Run by build_site.sh. To run it on its own, from the project root:
--   duckdb warehouse.duckdb < scripts/sql/09_export.sql
--
-- The AS aliases are the contract with docs/index.html: change the left-hand
-- side freely, but keep the aliases.

LOAD spatial;

-- ---------------------------------------------------------------------------
-- 1. Map features: geometry plus only what the map needs to draw, colour,
--    label and filter. Pieces of one feature are merged into one line
--    feature and/or one area feature per feature_id.
-- ---------------------------------------------------------------------------
CREATE OR REPLACE TEMP VIEW export_feature AS
SELECT
    f.feature_id                                                 AS feature_id,
    any_value(f.name)                                            AS name,
    s.feature_type                                               AS feature_type,
    any_value(coalesce(n.category, f.category, 'uncategorized')) AS category,
    ST_Union_Agg(s.geom)                                         AS geom
FROM curated.feature AS f
JOIN raw.osm_street AS s
  ON s.name = f.name
LEFT JOIN curated.namesake AS n
  ON n.qid = f.qid
GROUP BY f.feature_id, s.feature_type;

COPY (
    SELECT
        'Feature' AS type,
        {
            'feature_id':   feature_id,
            'name':         name,
            'feature_type': feature_type,
            'category':     category
        } AS properties,
        ST_AsGeoJSON(geom)::JSON AS geometry
    FROM export_feature
    ORDER BY feature_id
) TO 'data/out/stare_mesto.geojsonl' (FORMAT JSON);

-- ---------------------------------------------------------------------------
-- 2. Card content, one object per feature. blurb, if present, otherwise 'null'
-- ---------------------------------------------------------------------------
COPY (
    SELECT
        f.feature_id                                      AS feature_id,
        f.name                                            AS name,
        coalesce(n.category, f.category, 'uncategorized') AS category,
        n.label_en                                        AS label_en,
        n.label_sk                                        AS label_sk,
        coalesce(f.blurb_en, n.description_en)            AS description_en,
        coalesce(f.blurb_sk, n.description_sk)            AS description_sk,
        f.context                                         AS context,
        n.image_url                                       AS image_url,
        NULL::VARCHAR                                     AS image_credit,
        n.article_en                                      AS wikipedia_en,
        n.article_sk                                      AS wikipedia_sk
    FROM curated.feature AS f
    LEFT JOIN curated.namesake AS n
      ON n.qid = f.qid
    QUALIFY row_number() OVER (PARTITION BY f.feature_id ORDER BY f.feature_id) = 1
    ORDER BY f.feature_id
) TO 'docs/data/stare_mesto_popups.json' (FORMAT JSON, ARRAY true);

-- ---------------------------------------------------------------------------
-- 3. Category list for the legend and colours, from curated.category (Sheets).
-- ---------------------------------------------------------------------------
COPY (
    SELECT
        category                                                 AS category,
        coalesce(label_sk, category)                             AS label_sk,
        coalesce(label_en, category)                             AS label_en,
        CASE WHEN color IS NULL OR color = '' THEN '#5a5a5a'
             WHEN starts_with(color, '#')     THEN color
             ELSE '#' || color END                               AS color
    FROM curated.category
    WHERE category IS NOT NULL AND category <> ''
    QUALIFY row_number() OVER (PARTITION BY category ORDER BY sort_order) = 1
    ORDER BY sort_order NULLS LAST, category
) TO 'docs/data/categories.json' (FORMAT JSON, ARRAY true);

-- ---------------------------------------------------------------------------
-- 4. Checks. All three should return nothing.
-- ---------------------------------------------------------------------------
-- Features that found no geometry (name mismatch between curated and raw):
SELECT f.feature_id, f.name AS unmatched_name
FROM curated.feature AS f
ANTI JOIN raw.osm_street AS s ON s.name = f.name;

-- Same feature exported twice for the same geometry type:
SELECT feature_id, feature_type, count(*) AS n
FROM export_feature
GROUP BY ALL
HAVING n > 1;

-- Category codes used by streets but missing from curated.category:
SELECT DISTINCT category AS unknown_category
FROM export_feature
WHERE category <> 'uncategorized'
  AND category NOT IN (SELECT trim(category) FROM curated.category WHERE category IS NOT NULL);