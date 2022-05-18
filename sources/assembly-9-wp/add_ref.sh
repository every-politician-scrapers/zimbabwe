#!/bin/zsh

wd_rows=$(qsv search -i $1 wikidata.csv)
wd_count=$(printf "%s" "$wd_rows" | grep -c "^")
if [[ $wd_count != 2 ]]
then
  echo "No unique match to wikidata.csv:"
  echo $wd_rows | tail +2 | sed -e 's/^/	/g'
  return
fi

off_rows=$(qsv search -i $1 scraped.csv)
off_count=$(printf "%s" "$off_rows" | grep -c "^")
if [[ $off_count != 2 ]]
then
  echo "No unique match to scraped.csv:"
  echo $off_rows | tail +2 | sed -e 's/^/	/g'
  return
fi

statementid=$(echo $wd_rows | qsv select psid | qsv behead)
claims=$(echo $off_rows | qsv select name| qsv behead | qsv fmt --out-delimiter " ")

echo "$statementid $claims"
echo "$statementid $claims" | xargs wd ar --maxlag 20 add-source-name.js > /dev/null

