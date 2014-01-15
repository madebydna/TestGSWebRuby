class ResponseValue < ActiveRecord::Base
  attr_accessible :collection_id, :collection, :response_label, :response_value,:category_id, :category
  has_paper_trail
  db_magic :connection => :profile_config

  belongs_to :collection
  belongs_to :category

  def self.lookup_table(collections = [], categories = [])
    hash = {}

    cached_all_values = Rails.cache.fetch('response_value/all_values', expires_in: 5.minutes) do
      all_values
    end

    default_values = cached_all_values[:default_values]
    collection_values = cached_all_values[:collection_values]
    category_values = cached_all_values[:category_values]
    hash.merge! default_values

    Array(collections).each do |collection|
      if collection && collection_values[collection]
        hash.merge! collection_values[collection]
      end
    end


    Array(categories).each do |category|
      if category && category_values[category]
        hash.merge! category_values[category]
      end
    end

    hash
  end


  def self.all_values
    default_values = {}
    collection_values = {}
    category_values = {}

    ResponseValue.all.each do |response_value|

      if response_value.collection.nil?
        default_values[response_value.response_value] = response_value.response_label
      else
        collection_values[response_value.collection] ||= {}
        collection_values[response_value.collection].merge!({response_value.response_value => response_value.response_label})
      end

      if response_value.category
        category_values[response_value.category] ||= {}
        category_values[response_value.category].merge!({response_value.response_value => response_value.response_label})
      end

    end

    return {default_values: default_values, collection_values: collection_values, category_values: category_values}
  end

end
