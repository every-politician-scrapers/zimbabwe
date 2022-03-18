#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class RepList < Scraped::HTML
  decorator RemoveReferences
  # decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  field :members do
    member_entries.map { |ul| fragment(ul => Rep) }.reject(&:empty?).map(&:to_h)
  end

  private

  def member_entries
    noko.css('.navbox-list-with-group ul li')
  end

  class Rep < Scraped::HTML
    def empty?
      noko.text.include? 'Vacant'
    end

    field :item do
      name_link.attr('wikidata')
    end

    field :itemLabel do
      name_link.attr('title').gsub(/\(.*?\)/, '').tidy
    end

    field :party do
      noko.xpath('preceding::th[1]').css('a/@wikidata')
    end

    field :partyLabel do
      noko.xpath('preceding::th[1]').css('a').text.tidy
    end

    private

    def name_link
      noko.css('a').last
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: RepList).csv
