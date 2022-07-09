#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

# Decorator to remove all 'Noprint' sections (e.g. Citiation Needed)
class RemoveNoprint < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.noprint').remove
    end.to_s
  end
end


class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator RemoveNoprint
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Image'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[img _ name dates].freeze
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
