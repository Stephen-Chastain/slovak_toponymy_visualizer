sed -e "/__QIDS__/r data/out/qids.txt" -e "/__QIDS__/d" \
    /scripts/external_queries/qids_query_wikidata.sparql.tmpl \
    > data/out/qids_query_wikidata.sparql