const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (label,party,start) => {
  mem = {
    value: meta.position,
    qualifiers: {
      P2937: meta.term.id,
      P4100: party,
    },
    references: {
      P4656: meta.source,
      P813: new Date().toISOString().split('T')[0],
      P1810: label,
    }
  }
  if(start) mem['qualifiers']['P580']  = start

  claims = {
    P31: { value: 'Q5' }, // human
    P106: { value: 'Q82955' }, // politician
    P39: mem,
  }

  return {
    type: 'item',
    labels: { en: label },
    descriptions: { en: 'Zimbabwean politician' },
    claims: claims,
  }
}
