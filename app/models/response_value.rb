class ResponseValue < ActiveRecord::Base
  attr_accessible :collection_id, :collection, :response_label, :response_value
  belongs_to :collection

  def self.pretty_value(value, collection = nil)
    default_values = all_values{:default_values}
    collection_values = all_values{:collection_values}
    result = nil

    if collection
      result =  collection_values[collection][value]
    end

    result = result || default_values[value]

    return result
  end


  def self.all_values
    default_values = {}
    collection_values = {}

    ResponseValue.all.each do |response_value|

      if response_value.collection.nil?
        puts 'assigning default_values'
        default_values[response_value.response_value] = response_value.response_label
      else
        puts 'assigning collection_values'
        collection_values[response_value.collection] ||= {}
        collection_values[response_value.collection].merge!({response_value.response_value => response_value.response_label})
      end

    end

    return {default_values: default_values, collection_values: collection_values}
  end




end
