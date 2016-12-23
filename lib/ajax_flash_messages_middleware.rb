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
        begin
          hash = JSON.parse(body_content)
          hash['flash'] = flash
          body_content = hash.to_json
          body = [hash.to_json]
          headers['Content-Length'] = Rack::Utils.bytesize(body_content).to_s
          env['action_dispatch.request.flash_hash'] = nil
        rescue => e
          GSLogger.error(:misc, e)
        end
      end
    end

    [status, headers, body]
  end
end
