INSTALL httpfs;
LOAD httpfs;

SET VARIABLE sheet = 'https://docs.google.com/spreadsheets/d/1dSuZF54vy0pjIht-MEI1Lc-zCPvjkNNsmRwzhGRRWFI/export?format=csv&gid=';

CREATE OR REPLACE TABLE curated.feature AS
SELECT * FROM read_csv(getvariable('sheet') || '0', header = true);

CREATE OR REPLACE TABLE curated.namesake AS
SELECT * FROM read_csv(getvariable('sheet') || '860820447', header = true);

CREATE OR REPLACE TABLE curated.category AS
SELECT * FROM read_csv(getvariable('sheet') || '1880283247', header = true);

CREATE OR REPLACE TABLE curated.name_history AS
SELECT * FROM read_csv(getvariable('sheet') || '378580274', header = true);


COPY curated.feature  TO 'data/curated/feature.csv'  (HEADER, DELIMITER ',');
COPY curated.namesake TO 'data/curated/namesake.csv' (HEADER, DELIMITER ',');
COPY curated.category TO 'data/curated/category.csv' (HEADER, DELIMITER ',');
COPY curated.name_history TO 'data/curated/name_history.csv' (HEADER, DELIMITER ',');