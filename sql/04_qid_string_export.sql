--creates plaintext file of delimited qid from the OSM name:etymology:wikidata field to automatically connect to wikidata entries.

COPY (
  WITH good_qid AS (
    SELECT qid
    --, district
    FROM raw.etymology_coverage
    WHERE has_qid AND regexp_matches(qid, '^Q[0-9]+$')
  )
  SELECT string_agg(DISTINCT 'wd:' || qid, ' ')
  FROM good_qid
) TO 'data/out/qids.txt' (HEADER false, DELIMITER E'\x01');