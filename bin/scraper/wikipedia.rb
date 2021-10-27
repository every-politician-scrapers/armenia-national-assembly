#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MembersPage < Scraped::HTML
  decorator RemoveReferences
  decorator WikidataIdsDecorator::Links

  field :members do
    member_rows.map { |ul| fragment(ul => Member).to_h }
  end

  private

  def member_rows
    uls.flat_map { |ul| ul.xpath('.//li[a]') }
  end

  def uls
    noko.css('.navbox-list table ul')
  end
end

class Member < Scraped::HTML
  field :item do
    name_link.attr('wikidata')
  end

  field :name do
    name_link.text.tidy
  end

  private

  def name_link
    noko.css('a')
  end
end

url = 'https://hy.wikipedia.org/wiki/%D4%BF%D5%A1%D5%B2%D5%A1%D5%BA%D5%A1%D6%80:%D5%80%D5%A1%D5%B5%D5%A1%D5%BD%D5%BF%D5%A1%D5%B6%D5%AB_%D5%80%D5%A1%D5%B6%D6%80%D5%A1%D5%BA%D5%A5%D5%BF%D5%B8%D6%82%D5%A9%D5%B5%D5%A1%D5%B6_%D4%B1%D5%A6%D5%A3%D5%A1%D5%B5%D5%AB%D5%B6_%D4%BA%D5%B8%D5%B2%D5%B8%D5%BE%D5%AB_8-%D6%80%D5%A4_%D5%A3%D5%B8%D6%82%D5%B4%D5%A1%D6%80%D5%B8%D6%82%D5%B4'
data = MembersPage.new(response: Scraped::Request.new(url: url).response).members

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
