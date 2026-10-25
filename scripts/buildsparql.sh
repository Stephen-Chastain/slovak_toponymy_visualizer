QIDS=$(cat data/out/qids.txt)
sed "s|__QIDS__|$QIDS|" \
    scripts/external_queries/qids_query_wikidata.sparql.tmpl \
    > data/out/qids_query_wikidata.sparql