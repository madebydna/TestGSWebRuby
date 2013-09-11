class ResponseValue < ActiveRecord::Base
  attr_accessible :collection_id, :collection, :response_label, :response_value
  has_paper_trail

  belongs_to :collection

  def self.pretty_value(value, collections = [])
    cached_all_values = Rails.cache.fetch('response_value/all_values', expires_in: 5.minutes) do
      all_values
    end

    default_values = cached_all_values[:default_values]
    collection_values = cached_all_values[:collection_values]

    result = nil

    Array(collections).each do |collection|
      if collection && collection_values[collection]
        result =  collection_values[collection][value]
      end
    end

    result = default_values[value] if result.nil?
    result = value if result.nil?

    return result
  end

  def self.lookup_table(collections = [])
    hash = {}

    cached_all_values = Rails.cache.fetch('response_value/all_values', expires_in: 5.minutes) do
      all_values
    end

    default_values = cached_all_values[:default_values]
    collection_values = cached_all_values[:collection_values]
    hash.merge! default_values

    Array(collections).each do |collection|
      if collection && collection_values[collection]
        hash.merge! collection_values[collection]
      end
    end

    hash
  end


  def self.all_values
    default_values = {}
    collection_values = {}

    ResponseValue.all.each do |response_value|

      if response_value.collection.nil?
        default_values[response_value.response_value] = response_value.response_label
      else
        collection_values[response_value.collection] ||= {}
        collection_values[response_value.collection].merge!({response_value.response_value => response_value.response_label})
      end

    end

    return {default_values: default_values, collection_values: collection_values}
  end

end
