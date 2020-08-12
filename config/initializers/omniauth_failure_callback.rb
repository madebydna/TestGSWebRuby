OmniAuth.config.on_failure = Proc.new do |env|
    SigninController.action(:omniuth_failure).call(env)
end