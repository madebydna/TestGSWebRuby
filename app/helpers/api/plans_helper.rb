module Api
  module PlansHelper

    def plan_name(plan_name)
      plan_name.split("_").join(" ")
    end

    def action_url(plan_name)
      return '/api/signup/#' if plan_name == 'enterprise'
      '/api/registration'
    end

    def button_txt(plan_name)
      return 'Contact Us' if plan_name == 'enterprise'
      'Start Now'
    end

    def demo_icon(plan)
      return 'icons/blue-check-circle.svg' if plan.demographics_included?
      'icons/gray-check-circle.svg'
    end

    def subratings_icon(plan)
      return 'icons/blue-check-circle.svg' if plan.subratings_included?
      'icons/gray-check-circle.svg'
    end

    def price_secondary(price)
      price.divmod(1).second.round(2)
    end

    def price_primary(price)
      price.divmod(1).first
    end

    def dataset_partial(plan)
      plan.enterprise? ? 'enterprise_dataset' : 'dataset'
    end

  end
end