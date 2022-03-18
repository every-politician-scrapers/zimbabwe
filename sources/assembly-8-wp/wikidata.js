const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = function () {
  let fromd = `"${meta.term.start}T00:00:00Z"^^xsd:dateTime`
  let until = meta.term.end ? `"${meta.term.end}T00:00:00Z"^^xsd:dateTime` : "NOW()"

  return `SELECT DISTINCT ?item ?itemLabel ?party ?partyLabel ?constituency ?constituencyLabel
                 ?startDate ?endDate ?gender (STRAFTER(STR(?ps), STR(wds:)) AS ?psid)
    WITH {
      SELECT DISTINCT ?item ?position ?startNode ?endNode ?ps
      WHERE {
          ?item wdt:P31 wd:Q5 ; p:P39 ?ps .
          ?ps ps:P39 ?position .
          ?position wdt:P279* wd:${meta.position} .
          FILTER NOT EXISTS { ?ps wikibase:rank wikibase:DeprecatedRank }
          OPTIONAL { ?item p:P570 [ a wikibase:BestRank ; psv:P570 ?dod ] }
          OPTIONAL { ?ps pqv:P580 ?p39start }
          OPTIONAL { ?ps pqv:P582 ?p39end }
          OPTIONAL {
            ?ps pq:P2937 ?term .
            OPTIONAL { ?term p:P571 [ a wikibase:BestRank ; psv:P571 ?termInception ] }
            OPTIONAL { ?term p:P580 [ a wikibase:BestRank ; psv:P580 ?termStart ] }
            OPTIONAL { ?term p:P576 [ a wikibase:BestRank ; psv:P576 ?termAbolished ] }
            OPTIONAL { ?term p:P582 [ a wikibase:BestRank ; psv:P582 ?termEnd ] }
          }
          wd:Q18354756 p:P580/psv:P580 ?farFuture .

          BIND(COALESCE(?p39start, ?termInception, ?termStart) AS ?startNode)
          BIND(COALESCE(?p39end,   ?termAbolished, ?termEnd, ?dod, ?farFuture) AS ?endNode)
          FILTER(BOUND(?startNode))
      }
    } AS %statements
    WHERE {
      INCLUDE %statements .
      ?startNode wikibase:timeValue ?startV ; wikibase:timePrecision ?startP .
      ?endNode   wikibase:timeValue ?endV   ; wikibase:timePrecision ?endP .

      FILTER (
        IF(?startV > ${fromd}, ?startV, ${fromd}) < IF(?endV < ${until}, ?endV, ${until})
      )

      BIND (
        COALESCE(
          IF(?startP = 11, SUBSTR(STR(?startV), 1, 10), 1/0),
          IF(?startP = 10, SUBSTR(STR(?startV), 1, 7), 1/0),
          IF(?startP = 9,  SUBSTR(STR(?startV), 1, 4), 1/0),
          IF(?startP = 8,  CONCAT(SUBSTR(STR(?startV), 1, 4), "s"), 1/0),
          ""
        ) AS ?startDate
      )

      BIND (
        COALESCE(
          IF(?endV > NOW(), "", 1/0),
          IF(?endP = 11, SUBSTR(STR(?endV), 1, 10), 1/0),
          IF(?endP = 10, SUBSTR(STR(?endV), 1, 7), 1/0),
          IF(?endP = 9,  SUBSTR(STR(?endV), 1, 4), 1/0),
          IF(?endP = 8,  CONCAT(SUBSTR(STR(?endV), 1, 4), "s"), 1/0),
          ""
        ) AS ?endDate
      )

      OPTIONAL {
        ?item wdt:P21 ?sog .
        OPTIONAL { ?sog rdfs:label ?gender FILTER(LANG(?gender)="en") }
      }
      OPTIONAL { ?item wdt:P21/rdfs:label ?gender FILTER (LANG(?gender)="en") }

      OPTIONAL {
        ?ps pq:P4100 ?party .
        OPTIONAL { ?party wdt:P1813 ?partyShortName }
        OPTIONAL { ?party rdfs:label ?partyName FILTER (LANG(?partyLabel)="en") }
      }
      BIND(COALESCE(?partyShortName, ?partyName) AS ?partyLabel)

      OPTIONAL {
        ?ps pq:P768 ?constituency .
        OPTIONAL { ?constituency rdfs:label ?constituencyLabel FILTER (LANG(?constituencyLabel)="en") }
      }
      BIND(COALESCE(?partyShortName, ?partyName) AS ?partyLabel)

      OPTIONAL {
        ?ps prov:wasDerivedFrom ?ref .
        ?ref pr:P4656 ?source FILTER CONTAINS(STR(?source), '${meta.lang}.wikipedia.org') .
        OPTIONAL { ?ref pr:P1810 ?sourceName }
      }
      OPTIONAL { ?item rdfs:label ?labelName FILTER(LANG(?labelName) = "${meta.lang}") }
      BIND(COALESCE(?sourceName, ?labelName) AS ?itemLabel)
    }
    # ${new Date().toISOString()}
    ORDER BY ?start ?end ?item ?psid`
}
