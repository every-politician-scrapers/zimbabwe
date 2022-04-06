#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

class Comparison < EveryPoliticianScraper::NulllessComparison
  def columns
    super - %i[partylabel startdate enddate]
  end
end

diff = Comparison.new('wikidata.csv', 'scraped.csv').diff
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
