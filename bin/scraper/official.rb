#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'scraped'

# require 'pry'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'

class Legislature
  # details for an individual member
  class Member < Scraped::HTML
    field :id do
      url[/ID=(\d+)/, 1]
    end

    # in "Firstname Lastname" format
    #   this will do the wrong thing if there are too many parts, but
    #   can be fixed kui that arises
    field :name do
      display_name.split(/\s+/).reverse.join(' ')
    end

    private

    def link
      noko.css('a').last
    end

    def url
      link.attr('href')
    end

    # in "Lastname Firstname" format
    def display_name
      link.text
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      noko.css('.dep_name_list').map { |mp| fragment(mp => Member).to_h }
    end
  end
end

url = 'http://www.parliament.am/deputies.php?lang=eng'
data = Legislature::Members.new(response: Scraped::Request.new(url: url).response).members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
