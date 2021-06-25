#!/bin/env ruby
# frozen_string_literal: true

require 'cgi'
require 'csv'
require 'scraped'

class Results < Scraped::JSON
  field :members do
    json[:results][:bindings].map { |result| fragment(result => Member).to_h }
  end
end

class Member < Scraped::JSON
  field :id do
    json.dig(:id, :value)
  end

  field :name do
    json.dig(:name, :value)
  end

  field :item do
    json.dig(:item, :value).split('/').last
  end
end

# In this case it might make more sense to fetch as CSV and output it
# directly, but this way keeps it in sync with our normal approach, and
# allows us to more easily post-process if needed
WIKIDATA_SPARQL_URL = 'https://query.wikidata.org/sparql?format=json&query=%s'

memberships_query = <<SPARQL
  SELECT DISTINCT ?item ?id ?name
    WITH {
      # members can have more than one official ID, so take the highest one
      SELECT ?item (MAX(xsd:integer(?parliamentID)) AS ?id) WHERE { 
        ?item p:P39 ?ps ; wdt:P5213 ?parliamentID .
        ?ps ps:P39 wd:Q17277248 ; pq:P2937 wd:Q61165268 .
        FILTER NOT EXISTS { ?ps pq:P582 [] }  
        ?item wdt:P5213 ?parliamentID .
      }
      GROUP BY ?item
    } AS %members
    WHERE {
      INCLUDE %members .
      ?item p:P5213 ?idstatement .
      ?idstatement ps:P5213 ?id2 .
      # we only want to get the name associated with the latest ID
      FILTER (xsd:integer(?id2) = ?id)
      OPTIONAL { ?idstatement pq:P1810 ?namedAs }
      # Their on-wiki label as a fall-back if no "named as"
      OPTIONAL { ?item rdfs:label ?enLabel FILTER(LANG(?enLabel) = "en") }
      BIND(COALESCE(?namedAs, ?enLabel) AS ?name)
    }
  ORDER BY ?name
SPARQL

url = WIKIDATA_SPARQL_URL % CGI.escape(memberships_query)
headers = { 'User-Agent' => 'every-politican-scrapers/finland-eduskunta' }
data = Results.new(response: Scraped::Request.new(url: url, headers: headers).response).members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
