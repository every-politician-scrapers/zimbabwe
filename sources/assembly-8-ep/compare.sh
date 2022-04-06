#!/bin/bash

cd $(dirname $0)

# curl https://raw.githubusercontent.com/everypolitician/everypolitician-data/master/data/Zimbabwe/Assembly/term-8.csv | qsv select wikidata,name,wikidata_group,group,wikidata_area,area,start_date,end_date,gender | qsv rename item,name,party,partyLabel,area,areaLabel,startDate,endDate,gender > scraped.csv

wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid | qsv sort -s name,startDate > wikidata.csv
bundle exec ruby diff.rb | qsv sort -s name,startdate | qsv select 1,item,name,party,gender | tee diff.csv

cd -
