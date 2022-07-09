#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Picture'
  end

  def table_number
    '1'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[no img name start end].freeze
    end

    def empty?
      super || noko.text.include?('vacant')
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
