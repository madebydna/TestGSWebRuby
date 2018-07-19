import { copyParam } from 'util/uri';

export const href = (url) => {
  return url
    ? copyParam(
        'newsearch',
        window.location.href,
        copyParam('lang', window.location.href, url)
      )
    : undefined;
}

