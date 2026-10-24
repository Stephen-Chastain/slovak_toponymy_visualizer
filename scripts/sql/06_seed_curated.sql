-- Writes curated data to the gitignored 'out' folder. Then we'll copy each new district  anually into "curated" to avoid overwrite disasterss.


load SPATIAL;

COPY (
    SELECT
        s.district || '--' ||
        lower(
          regexp_replace(
            regexp_replace(strip_accents(s.name), '[^a-zA-Z0-9]+', '-', 'g'),
            '(^-+|-+$)', '', 'g'
          )
        )                        AS feature_id,
        s.district,
        s.name,
        max(c.qid)               AS qid,                                -- some squares (namestia) are included as both polygons and lines; this aggregates them since their names are identical.
        ''                       AS category,
        ''                       AS category_note
    FROM raw.osm_street s
    LEFT JOIN raw.etymology_coverage c
           ON c.district = s.district
          AND c.name     = s.name
    GROUP BY s.district, s.name                                         -- geometry is stored in the 'raw.osm_street' table so distinction is unneeded here
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
        ''                       AS blurb_en,
        ''                       AS blurb_sk,
        ''                       AS category,
        ''                       AS source_note
    FROM raw.wikidata_namesake w
    ORDER BY w.label_en
) TO 'data/out/seed_namesake.csv' (HEADER, DELIMITER ',');

-- Collision check for duplicate features which could erase manually curated data
SELECT feature_id, count(*), list(name)
FROM read_csv('data/out/seed_feature.csv', header = true)
GROUP BY feature_id
HAVING count(*) > 1;