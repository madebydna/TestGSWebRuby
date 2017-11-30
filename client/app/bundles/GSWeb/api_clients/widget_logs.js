export function logWidgetCodeRequest(email, targetUrl) {
  var uri = '/gsr/api/widget_logs/';
  return $.post(
    uri,
    {
      widget: {
        email: email,
        target_url: targetUrl
      }
    },
    null,
    'json'
  );
}
