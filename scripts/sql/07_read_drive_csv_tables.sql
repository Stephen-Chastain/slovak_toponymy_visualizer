INSTALL httpfs;
LOAD httpfs;

CREATE SCHEMA IF NOT EXISTS curated;

SET VARIABLE sheet = 'https://docs.google.com/spreadsheets/d/1dSuZF54vy0pjIht-MEI1Lc-zCPvjkNNsmRwzhGRRWFI/export?format=csv&gid=';
SET VARIABLE gid_feature      = '0';
SET VARIABLE gid_namesake     = '860820447';
SET VARIABLE gid_category     = '1880283247';
SET VARIABLE gid_name_history = '378580274';
SET VARIABLE gid_nationality =  '1294466999';
SET VARIABLE gid_occupation = '1246602498';

CREATE OR REPLACE TABLE curated.feature AS
SELECT
    trim(f.feature_id)                AS feature_id,
    trim(f.district)                  AS district,
    f.name,
    nullif(trim(f.qid), '')           AS qid,
    lower(trim(f.qid_conflict)) IN ('true','1','yes') AS qid_conflict,
    nullif(trim(f.category), '')      AS category,
    nullif(f.category_note, '')       AS category_note,
    nullif(f.context, '')             AS context
FROM read_csv(getvariable('sheet') || getvariable('gid_feature'), header = true, all_varchar = true) AS f;

CREATE OR REPLACE TABLE curated.namesake AS
SELECT
    trim(n.qid)                       AS qid,
    n.label_en,
    n.label_sk,
    n.description_en,
    n.description_sk,
    try_cast(n.birth_date AS DATE)    AS birth_date,
    try_cast(n.death_date AS DATE)    AS death_date,
    n.article_en,
    n.article_sk,
    n.image_url,
    n.wd_citizenship, 
    n.wd_occupation, 
    n.wd_instance_of, 
    nullif(trim(n.category), '')      AS category,
    nullif(trim(n.nationality), ''), 
    nullif(trim(n.occupation), ''),
    nullif(n.blurb_en, '')            AS blurb_en,
    nullif(n.blurb_sk, '')            AS blurb_sk,
    nullif(n.source_note, '')         AS source_note
FROM read_csv(getvariable('sheet') || getvariable('gid_namesake'), header = true, all_varchar = true) AS n;

CREATE OR REPLACE TABLE curated.category AS
SELECT
    trim(c.category)                  AS category,
    c.label_en,
    c.label_sk,
    trim(c.color)                     AS color,
    try_cast(c.sort_order AS INTEGER) AS sort_order
FROM read_csv(getvariable('sheet') || getvariable('gid_category'), header = true, all_varchar = true) AS c;

CREATE OR REPLACE TABLE curated.name_history AS
SELECT
    trim(h.feature_id)                AS feature_id,
    h.current_name,
    h.name,
    nullif(trim(h.lang), '')          AS lang,
    nullif(trim(h.valid_from), '')    AS valid_from,
    nullif(trim(h.valid_to), '')      AS valid_to,
    h.tag,
    h.source,
    nullif(h.context, '')                AS context
FROM read_csv(getvariable('sheet') || getvariable('gid_name_history'), header = true, all_varchar = true) AS h;

CREATE OR REPLACE TABLE curated.nationality AS
SELECT
    trim(a.nationality)               AS nationality,
    a.label_en,
    a.label_sk,
    try_cast(a.sort_order AS INTEGER) AS sort_order
FROM read_csv(getvariable('sheet') || getvariable('gid_nationality'),
              header = true, all_varchar = true) AS a;


CREATE OR REPLACE TABLE curated.feature AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_feature'), header = true);

CREATE OR REPLACE TABLE curated.namesake AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_namesake'), header = true);

CREATE OR REPLACE TABLE curated.category AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_category'), header = true);

CREATE OR REPLACE TABLE curated.name_history AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_name_history'), header = true);

CREATE OR REPLACE TABLE curated.occupation AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_occupation'), header = true);



COPY curated.feature  TO 'data/curated/feature.csv'  (HEADER, DELIMITER ',');
COPY curated.namesake TO 'data/curated/namesake.csv' (HEADER, DELIMITER ',');
COPY curated.category TO 'data/curated/category.csv' (HEADER, DELIMITER ',');
COPY curated.name_history TO 'data/curated/name_history.csv' (HEADER, DELIMITER ',');
COPY curated.nationality TO 'data/curated/nationality.csv' (HEADER, DELIMITER ',');
COPY curated.occupation  TO 'data/curated/occupation.csv'  (HEADER, DELIMITER ',');