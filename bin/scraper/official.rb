#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'

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

puts EveryPoliticianScraper::ScraperData.new('http://www.parliament.am/deputies.php?lang=eng').csv
