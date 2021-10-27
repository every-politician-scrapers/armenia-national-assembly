const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
    return `SELECT (STRAFTER(STR(?statement), '/statement/') AS ?psid) ?item ?itemLabel ?start WHERE {
    ?item p:P39 ?statement .
    ?statement ps:P39 wd:${meta.legislature.member} .
    ?statement pq:P580 ?start .
    FILTER NOT EXISTS { ?statement pq:P582 ?end }
    FILTER NOT EXISTS { ?statement pq:P2937 ?term }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "en". }
    # ${new Date().toISOString()}
  }
  ORDER BY DESC(?start)`
}
