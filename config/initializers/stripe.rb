Rails.configuration.stripe = {
  publishable_key:  ENV_GLOBAL['stripe_publishable_key'],
  secret_key:      ENV_GLOBAL['stripe_secret_key']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]