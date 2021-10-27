const fs = require('fs');
let rawmeta = fs.readFileSync('meta.json');
let meta = JSON.parse(rawmeta);

module.exports = (id,start,replaces) => {
  qualifier = {
    P2937: meta.legislature.term.id,
  }

  source = {
    P143:  'Q1975217', // hywiki
    P4656: 'https://hy.wikipedia.org/w/index.php?title=%D4%BF%D5%A1%D5%B2%D5%A1%D5%BA%D5%A1%D6%80:%D5%80%D5%A1%D5%B5%D5%A1%D5%BD%D5%BF%D5%A1%D5%B6%D5%AB_%D5%80%D5%A1%D5%B6%D6%80%D5%A1%D5%BA%D5%A5%D5%BF%D5%B8%D6%82%D5%A9%D5%B5%D5%A1%D5%B6_%D4%B1%D5%A6%D5%A3%D5%A1%D5%B5%D5%AB%D5%B6_%D4%BA%D5%B8%D5%B2%D5%B8%D5%BE%D5%AB_8-%D6%80%D5%A4_%D5%A3%D5%B8%D6%82%D5%B4%D5%A1%D6%80%D5%B8%D6%82%D5%B4&oldid=8033239',
    P813:  new Date().toISOString().split('T')[0],
  }

  return {
    id,
    claims: {
      P39: {
        value:      meta.legislature.member,
        qualifiers: qualifier,
        references: source,
      }
    }
  }
}
