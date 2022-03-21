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
    member_entries.map { |ul| fragment(ul => Rep) } +
    new_member_entries.map { |ul| fragment(ul => NewRep) }
  end

  def member_entries
    noko.xpath('//table[contains(., "Welshman") or contains(., "Chinamasa")]//tr[td[a]]')
  end

  def new_member_entries
    noko.xpath('//table[contains(., "Chisvuure")]//tr[td[a]]')
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

    field :startDate do
      '2005-04-12'
    end

    private

    def tds
      noko.css('td')
    end

    def name_link
      tds[0].css('a')
    end

    def party_link
      tds[2].css('a')
    end
  end

  class NewRep <Rep
    def name_link
      tds[5].css('a')
    end

    def party_link
      tds[-2].css('a')
    end

    field :startDate do
      Date.parse tds[-1].text.tidy
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: RepList).csv
