# OmniAuth.config do |config|
#   config.on_failure do
#     SigninController.action(:omniuth_failure).call(env)
#   end
# end

OmniAuth.config.on_failure = Proc.new do |env|
    SigninController.action(:omniuth_failure).call(env)
end