const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id, party, startdate, enddate) => {
  qualifier = { }
  if(meta.term) qualifier['P2937'] = meta.term.id
  if(party)     qualifier['P4100'] = party
  if(startdate) qualifier['P580']  = startdate
  if(enddate)   qualifier['P582']  = enddate

  refs = { }
  if(meta.source) {
    var wpref = /wikipedia.org/;
    if (wpref.test(meta.source)) {
      refs['P4656'] = meta.source
    } else {
      refs['P854'] = meta.source
    }
  }

  return {
    id,
    claims: {
      P39: {
        value: meta.position,
        qualifiers: qualifier,
        references: refs,
      }
    }
  }
}
