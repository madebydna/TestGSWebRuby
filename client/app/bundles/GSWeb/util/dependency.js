//TODO: import $

const URL_MAP = {};

export function getScript(url) {
  if (URL_MAP[url] === undefined) {
    URL_MAP[url] = $.getScript(url);
  }
  return URL_MAP[url];
};
