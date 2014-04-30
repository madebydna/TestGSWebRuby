class ResponseValue < ActiveRecord::Base
  attr_accessible :response_label, :response_key, :response_value, :category_id, :category
  db_magic :connection => :profile_config

  include BelongsToCollectionConcerns

  belongs_to :category

  def self.all_keys
    Rails.cache.fetch('response_value/all_keys', expires_in: 5.minutes) do
      ResponseValue.all.map(&:response_key).uniq
    end
  end

  # TODO: add collection support to this method
  def self.lookup_table
    cached_all_values = Rails.cache.fetch('response_value/all_values', expires_in: 5.minutes) do
      hash = {}
      ResponseValue.all.each do |row|
        key = [row['response_key'], row['response_value']]
        hash[key] = row['response_label']
      end
      hash
    end

    return cached_all_values
  end

  def self.all_values
    default_values = {}
    collection_values = {}
    category_values = {}

    ResponseValue.all.each do |response_value|

      if response_value.collection.nil?
        default_values[response_value.response_value] = response_value
      else
        collection_values[response_value.collection] ||= {}
        collection_values[response_value.collection].merge!({response_value.response_value => response_value})
      end

      if response_value.category
        category_values[response_value.category] ||= {}
        category_values[response_value.category].merge!({response_value.response_value => response_value})
      end

    end

    return {default_values: default_values, collection_values: collection_values, category_values: category_values}
  end

end
