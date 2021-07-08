#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/wikidata_query'

query = <<SPARQL
  SELECT DISTINCT ?id ?name (STRAFTER(STR(?member), STR(wd:)) AS ?item)
    WITH {
      # members can have more than one official ID, so take the highest one
      SELECT ?member (MAX(xsd:integer(?parliamentID)) AS ?id) WHERE {
        ?member p:P39 ?ps ; wdt:P5213 ?parliamentID .
        ?ps ps:P39 wd:Q17277248 ; pq:P2937 wd:Q61165268 .
        FILTER NOT EXISTS { ?ps pq:P582 [] }
        ?member wdt:P5213 ?parliamentID .
      }
      GROUP BY ?member
    } AS %members
    WHERE {
      INCLUDE %members .
      ?member p:P5213 ?idstatement .
      ?idstatement ps:P5213 ?id2 .
      # we only want to get the name associated with the latest ID
      FILTER (xsd:integer(?id2) = ?id)
      OPTIONAL { ?idstatement pq:P1810 ?namedAs }
      # Their on-wiki label as a fall-back if no "named as"
      OPTIONAL { ?member rdfs:label ?enLabel FILTER(LANG(?enLabel) = "en") }
      BIND(COALESCE(?namedAs, ?enLabel) AS ?name)
    }
  ORDER BY ?name
SPARQL

puts EveryPoliticianScraper::WikidataQuery.new(query, 'every-politican-scrapers/armenia-national-assembly').csv
