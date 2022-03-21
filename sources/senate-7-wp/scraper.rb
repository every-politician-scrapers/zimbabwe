#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class RepList < Scraped::HTML
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  field :members do
    member_items.reject(&:empty?).map(&:to_h)
  end

  private

  def member_items
    noko.css('#Candidates_for_the_Senate_election').xpath('preceding::*').remove
    noko.xpath('//table[contains(., "Candidate")]//tr[td[1][b]]').map { |ul| fragment(ul => Rep) }
  end

  class Rep < Scraped::HTML
    def empty?
      noko.text =~ /Missing|Vacant/
    end

    field :item do
      name_link.attr('wikidata')
    end

    field :name do
      name_link.text.tidy
    end

    field :party do
      party_link.attr('wikidata')
    end

    field :partyLabel do
      party_link.text.tidy
    end

    private

    def tds
      noko.css('td')
    end

    def name_link
      tds[1].css('a')
    end

    def party_link
      tds[2].css('a')
    end
  end
end



url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: RepList).csv
