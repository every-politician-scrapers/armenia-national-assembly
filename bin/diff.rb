#!/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/comparison'

diff = Comparison.new('data/wikidata.csv', 'data/official.csv').diff
puts diff.sort_by { |r| [r.first, r.last.to_s] }.reverse.map(&:to_csv)
