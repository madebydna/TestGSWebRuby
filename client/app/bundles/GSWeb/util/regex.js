
const escapeRegexChars = (str) => {
  return String(s).replace(/([-()\[\]{}+?*.$\^|,:#<!\\])/g, '\\$1').
  replace(/\x08/g, '\\x08');
}

const boldSubstring = (string, subString) => {

}

export {
  escapeRegexChars,
  boldSubstring
}