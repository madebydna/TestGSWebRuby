import { copyParam, copyParams, getHref } from '../../../util/uri';

export default function(url) {
  return copyParams(['newsearch', 'lang'], getHref(), url);
}