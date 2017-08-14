import { copyParam, getHref } from '../../../util/uri';

export default function(url) {
  return copyParam('lang', getHref(), url);
}
