INSTALL httpfs;
LOAD httpfs;

CREATE SCHEMA IF NOT EXISTS curated;

SET VARIABLE sheet = 'https://docs.google.com/spreadsheets/d/1dSuZF54vy0pjIht-MEI1Lc-zCPvjkNNsmRwzhGRRWFI/export?format=csv&gid=';
SET VARIABLE gid_feature      = '0';
SET VARIABLE gid_namesake     = '860820447';
SET VARIABLE gid_category     = '1880283247';
SET VARIABLE gid_name_history = '378580274';

CREATE OR REPLACE TABLE curated.feature AS
SELECT
    trim(feature_id)                AS feature_id,
    trim(district)                  AS district,
    name,
    nullif(trim(qid), '')           AS qid,
    lower(trim(qid_conflict)) IN ('true','1','yes') AS qid_conflict,
    nullif(trim(category), '')      AS category,
    nullif(category_note, '')       AS category_note,
    nullif(context, '')             AS context
FROM read_csv(getvariable('sheet') || 'gid_feature', header = true, all_varchar = true);

CREATE OR REPLACE TABLE curated.namesake AS
SELECT
    trim(qid)                       AS qid,
    label_en,
    label_sk,
    description_en,
    description_sk,
    try_cast(birth_date AS DATE)    AS birth_date,
    try_cast(death_date AS DATE)    AS death_date,
    article_en,
    article_sk,
    image_url,
    nullif(blurb_en, '')            AS blurb_en,
    nullif(blurb_sk, '')            AS blurb_sk,
    nullif(trim(category), '')      AS category,
    nullif(source_note, '')         AS source_note
FROM read_csv(getvariable('sheet') || 'gid_namesake', header = true, all_varchar = true);

CREATE OR REPLACE TABLE curated.category AS
SELECT
    trim(category)                  AS category,
    label_en,
    label_sk,
    trim(color)                     AS color,
    try_cast(sort_order AS INTEGER) AS sort_order
FROM read_csv(getvariable('sheet') || 'gid_category', header = true, all_varchar = true);

CREATE OR REPLACE TABLE curated.name_history AS
SELECT
    trim(feature_id)                AS feature_id,
    current_name,
    name,
    nullif(trim(lang), '')          AS lang,
    nullif(trim(valid_from), '')    AS valid_from,
    nullif(trim(valid_to), '')      AS valid_to,
    tag,
    source,
    nullif(note, '')                AS note
FROM read_csv(getvariable('sheet') || 'gid_name_history', header = true, all_varchar = true);


CREATE OR REPLACE TABLE curated.feature AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_feature'), header = true);

CREATE OR REPLACE TABLE curated.namesake AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_namesake'), header = true);

CREATE OR REPLACE TABLE curated.category AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_category'), header = true);

CREATE OR REPLACE TABLE curated.name_history AS
SELECT * FROM read_csv(getvariable('sheet') || getvariable('gid_name_history'), header = true);


COPY curated.feature  TO 'data/curated/feature.csv'  (HEADER, DELIMITER ',');
COPY curated.namesake TO 'data/curated/namesake.csv' (HEADER, DELIMITER ',');
COPY curated.category TO 'data/curated/category.csv' (HEADER, DELIMITER ',');
COPY curated.name_history TO 'data/curated/name_history.csv' (HEADER, DELIMITER ',');