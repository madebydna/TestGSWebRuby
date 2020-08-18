module Api
  # This class organizes the credit card details for the front end
  class CreditCardDetails

    attr_reader :card, :billing

    def self.call(card, billing)
      new(card, billing)
    end

    def initialize(card, billing)
      @card = card
      @billing = billing
    end

    def last_four
      card[:last4]
    end

    def brand
      card[:brand]
    end

    def name
      billing[:name]
    end

    def address
      [billing[:address][:line1], billing[:address][:line2]].compact.join(' ')&.strip
    end

    def locality
      [city, state].join(', ')
    end

    def zipcode
      billing[:address][:postal_code]
    end

    private

    def city
      billing[:address][:city].split(' ').map(&:capitalize).join(' ')
    end

    def state
      billing[:address][:state]&.upcase
    end

  end

end