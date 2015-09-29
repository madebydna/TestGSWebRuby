class AjaxFlashMessagesMiddleware
  def initialize(app, options = {})
    @app = app
  end

  def call(env)
    status, headers, body = @app.call(env)

    if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest" && headers['Content-Type'].to_s.include?("application/json")
      flash = env['action_dispatch.request.flash_hash'].try(:to_hash)
      body_content = body.body
      if body_content[0] == '{' && body_content[-1] == '}' && flash.present?
        hash = JSON.parse(body_content)
        hash['flash'] = flash if flash
        body.body = hash.to_json
        headers['Content-Length'] = Rack::Utils.bytesize(body.body.to_s).to_s
        env['action_dispatch.request.flash_hash'] = {}
      end
    end

    [status, headers, body]
  end
end