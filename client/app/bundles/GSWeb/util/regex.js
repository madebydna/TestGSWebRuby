
const escapeRegexChars = (str) => {
  return str.replace(/([-()\[\]{}+?*.$\^|,:#<!\\])/g, '\\$1').
  replace(/\x08/g, '\\x08');
}

const everythingButHTML = (str) => {
  let match = str.match(/(?<!<[^>]*).*/)
  return (match ? match[0] : undefined)
}

export {
  escapeRegexChars,
  everythingButHTML
}