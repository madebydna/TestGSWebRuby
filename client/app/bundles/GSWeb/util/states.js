// TODO: Import lodash functions
import { invert, values, isString, keys } from 'lodash';
import { titleize } from 'util/i18n';

const statesHash = {
  alabama: 'al',
  alaska: 'ak',
  arizona: 'az',
  arkansas: 'ar',
  california: 'ca',
  colorado: 'co',
  connecticut: 'ct',
  delaware: 'de',
  'district of columbia': 'dc',
  'washington dc': 'dc',
  florida: 'fl',
  georgia: 'ga',
  hawaii: 'hi',
  idaho: 'id',
  illinois: 'il',
  indiana: 'in',
  iowa: 'ia',
  kansas: 'ks',
  kentucky: 'ky',
  louisiana: 'la',
  maine: 'me',
  maryland: 'md',
  massachusetts: 'ma',
  michigan: 'mi',
  minnesota: 'mn',
  mississippi: 'ms',
  missouri: 'mo',
  montana: 'mt',
  nebraska: 'ne',
  nevada: 'nv',
  'new hampshire': 'nh',
  'new jersey': 'nj',
  'new mexico': 'nm',
  'new york': 'ny',
  'north carolina': 'nc',
  'north dakota': 'nd',
  ohio: 'oh',
  oklahoma: 'ok',
  oregon: 'or',
  pennsylvania: 'pa',
  'rhode island': 'ri',
  'south carolina': 'sc',
  'south dakota': 'sd',
  tennessee: 'tn',
  texas: 'tx',
  utah: 'ut',
  vermont: 'vt',
  virginia: 'va',
  washington: 'wa',
  'west virginia': 'wv',
  wisconsin: 'wi',
  wyoming: 'wy'
};

const abbreviationHash = invert(statesHash);

const stateAbbreviations = values(statesHash);

const anyStateNameRegex = function() {
  const components = keys(statesHash).map(stateName => `^${stateName}$`);

  return new RegExp(components.join('|'), 'i');
};

const anyStateNamePartialRegex = keys(statesHash).map(name => name.replace(/\s/g,'-')).join('|');

const isStateName = function(str) {
  return anyStateNameRegex().test(str);
};

const abbreviation = function(str) {
  if (!isString(str)) {
    return undefined;
  }

  str = str.toLowerCase();

  if (str.length === 2 && _(stateAbbreviations).contains(str)) {
    return str;
  }
  return statesHash[str];
};

const name = function(str) {
  if(!str) {
    return undefined;
  }
  if (!isString(str) || str.length !== 2) {
    str = str.replace('-', ' ');
    if (isStateName(str)) {
      return str;
    }
    return undefined;
  }

  return abbreviationHash[str.toLowerCase()];
};

const titleizedName = str => {
  const n = name(str);
  if(!n) {
    return;
  }
  return titleize(name(str)).replace(/dc$/i, s => s.toUpperCase());
}


export { anyStateNameRegex, anyStateNamePartialRegex, isStateName, abbreviation, name, titleizedName, stateAbbreviations };
