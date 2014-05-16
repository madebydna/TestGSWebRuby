FactoryGirl.define do
  factory :category do
    ignore do
      page nil
      layout nil
    end

    sequence :id do |n|
      n
    end

    name 'Test category'
    category_datas { FactoryGirl.build_list(:category_data, 1, response_key: 'a_key', label: 'a label' ) }

    after(:create) do |category, evaluator|
      if evaluator.page
        if evaluator.page.is_a?(String)
          p = FactoryGirl.create(:page, name: evaluator.page)
        else
          p = evaluator.page 
        end

        params = {
          page: p,
          category: category
        }
        params[:layout] = evaluator.layout if evaluator.layout

        FactoryGirl.create(:category_placement, params)
      end
    end
  end
end