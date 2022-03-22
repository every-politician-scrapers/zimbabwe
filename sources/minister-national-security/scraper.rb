#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  # TODO: make this easier to override
  def holder_entries
    noko.xpath('.//h2[contains(.,"ministers")]/following::ul[1]//li[a]')
  end

  class Officeholder < OfficeholderBase
    def raw_combo_date
      noko.text.scan(/\((.*?)\)/).flatten.last
    end

    def raw_combo_dates
      sdate,edate = super
      edate.prepend(sdate[0,2]) if edate.length == 2
      [sdate, edate]
    end

    def combo_date?
      true
    end

    def item
      name_cell.attr('wikidata')
    end

    def name
      nake_cell.text.tidy
    end

    def name_cell
      noko.css('a').first
    end

    def empty?
      noko.text.include? 'unknown'
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
