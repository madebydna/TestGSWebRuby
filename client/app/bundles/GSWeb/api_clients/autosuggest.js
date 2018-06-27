const { $ } = window;

export default function suggest(q, { limit = 25 } = {}) {
  const data = {
    q,
    limit
  };
  return $.ajax({
    url: '/gsr/api/autosuggest/',
    data,
    type: 'GET',
    dataType: 'json',
    timeout: 6000
  });
}
