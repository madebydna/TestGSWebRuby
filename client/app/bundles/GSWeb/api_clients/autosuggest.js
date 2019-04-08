const { $ } = window;

export default function suggest(q, { limit = 25, types = [] } = {}) {
  const data = {
    q,
    limit,
    types
  };
  return $.ajax({
    url: '/gsr/api/autosuggest/',
    data,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}
