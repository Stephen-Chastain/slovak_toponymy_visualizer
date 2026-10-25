INSTALL httpfs;
LOAD httpfs;

SET VARIABLE sheet = 'https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/export?format=csv&gid=';

CREATE OR REPLACE TABLE curated.feature AS
SELECT * FROM read_csv(getvariable('sheet') || '0', header = true);

CREATE OR REPLACE TABLE curated.namesake AS
SELECT * FROM read_csv(getvariable('sheet') || '1884573829', header = true);   -- real gid

CREATE OR REPLACE TABLE curated.category AS
SELECT * FROM read_csv(getvariable('sheet') || '209384756', header = true);    -- real gid

COPY curated.feature  TO 'data/curated/feature.csv'  (HEADER, DELIMITER ',');
COPY curated.namesake TO 'data/curated/namesake.csv' (HEADER, DELIMITER ',');
COPY curated.category TO 'data/curated/category.csv' (HEADER, DELIMITER ',');  -- changed: typo