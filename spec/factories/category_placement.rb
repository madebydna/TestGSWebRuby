require 'rspec/mocks/standalone'

FactoryGirl.define do
  factory :category_placement do
    sequence :id do |n|
      n
    end

    sequence :position do |n|
      n
    end

    factory :section_category_placement, class: CategoryPlacement do
      title 'root, section, has_children'
      layout 'section'

      after(:create) do |section_placement, evaluator|
        FactoryGirl.create(:group_category_placement_no_parent, title: 'has parent, group, has children', layout: 'group', parent: section_placement)
      end
    end

    factory :group_category_placement_no_parent, class: CategoryPlacement do
      factory :group_category_placement, class: CategoryPlacement do
        title 'has parent, group, has children'
        before(:create) do |group_placement, evaluator|
          group_placement.parent = FactoryGirl.create :category_placement, title: 'root, section, has_children', layout: 'section'
        end
      end

      title 'root, group, has children'
      layout 'group'

      after(:create) do |group_placement, evaluator|
        FactoryGirl.create(:leaf_category_placement_no_parent, title: 'has parent, leaf', layout: 'default_two_column_table', parent: group_placement)
      end
    end

    factory :leaf_category_placement_no_parent, class: CategoryPlacement do
      factory :leaf_category_placement, class: CategoryPlacement do
        title 'has parent, leaf'
        before(:create) do |group_placement, evaluator|
          group_placement.parent = FactoryGirl.create :category_placement, title: 'root, section, has_children', layout: 'section'
        end
      end

      title 'root, leaf'
      association :category, factory: :category, strategy: :create
      layout 'default_two_column_table'
    end

  end

end