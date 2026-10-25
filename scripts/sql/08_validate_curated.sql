-- Features with a category that isn't in category.csv
SELECT 'unknown category' AS issue, f.feature_id, f.category
FROM curated.feature f
LEFT JOIN curated.category c ON c.category = f.category
WHERE f.category IS NOT NULL AND c.category IS NULL;

-- Features whose QID has no namesake row
SELECT 'orphan qid' AS issue, f.feature_id, f.qid
FROM curated.feature f
LEFT JOIN curated.namesake n ON n.qid = f.qid
WHERE f.qid IS NOT NULL AND n.qid IS NULL;

-- Name-history rows pointing at a feature that doesn't exist
SELECT 'orphan feature_id' AS issue, h.feature_id, h.name
FROM curated.name_history h
LEFT JOIN curated.feature f ON f.feature_id = h.feature_id
WHERE f.feature_id IS NULL;

-- Curated features with no geometry, and geometry with no curated row
SELECT 'no geometry' AS issue, f.feature_id, NULL AS name
FROM curated.feature f
LEFT JOIN raw.osm_street s
       ON slug(s.district, s.name) = f.feature_id
WHERE s.name IS NULL;

SELECT 'no curated row' AS issue, slug(s.district, s.name) AS feature_id, s.name
FROM raw.osm_street s
LEFT JOIN curated.feature f ON f.feature_id = slug(s.district, s.name)
WHERE f.feature_id IS NULL;

-- Duplicate keys
SELECT 'duplicate feature_id' AS issue, feature_id, NULL
FROM curated.feature GROUP BY feature_id HAVING count(*) > 1;

SELECT 'duplicate qid' AS issue, qid, NULL
FROM curated.namesake GROUP BY qid HAVING count(*) > 1;