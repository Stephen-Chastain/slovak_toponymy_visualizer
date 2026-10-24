--Creates table of wikidata etymology table from the QID codes query where it exists.


CREATE OR REPLACE TABLE raw.wikidata_namesake AS
SELECT
    regexp_extract(item, 'Q[0-9]+$')  AS qid,
    itemLabel_sk                      AS label_sk,
    itemLabel_en                      AS label_en,
    description_sk,
    description_en,
    image                             AS image_url,
    try_cast(birth AS DATE)           AS birth_date,
    try_cast(death AS DATE)           AS death_date,
    article_sk,
    article_en
FROM read_csv('data/raw/wikidata_etymology.csv', header = true);