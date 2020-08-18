module Api
  module ViewHelper
    def capitalize_words(text)
      return 'N/A' if text.nil?

      text.split(' ').map(&:capitalize).join(' ')
    end

    def format_plan(subscription)
      return 'No Plan Selected' if subscription.nil?
      plan = subscription.plan

      "#{plan.name.split('_').map(&:capitalize).join(' ')} #{number_to_currency(plan.price)}/month"
    end

    def display_credit_card(card_details)
      cards = {
        'mastercard' => 'icons/credit-card-1.svg',
        'visa' => 'icons/credit-card-2.svg',
        'discover' => 'icons/credit-card-3.svg',
      }

      image_tag cards[card_details.brand]
    end

    def display_card_information(card_details)
      return 'N/A' if card_details.nil?

      "#{card_details.brand&.capitalize} ending in #{card_details.last_four}"
    end
  end
end