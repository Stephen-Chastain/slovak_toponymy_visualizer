--returns list of any segment entries by 'name' which have both lines and polygons for cleaning up duplicate geometry.
--One example: a pedestrian path intersecting a square may be counted twice with the same name.

--later add a way to check only within specific districts (if multiple cities are present)

select
name,
count(*) FILTER (WHERE ST_GEometryType(geom) IN ('POLYGON','MULTIPOLYGON')) AS polygon,
count(*) FILTER (WHERE ST_GEometryType(geom) IN ('LINESTRING', 'MULTILINESTRING')) AS line
FROM raw.v_street_segment
GROUP BY name, geom
HAVING polygon > 0 AND line > 0 ;