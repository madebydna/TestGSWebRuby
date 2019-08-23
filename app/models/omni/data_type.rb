# frozen_string_literal: true

module Omni
  class DataType < ActiveRecord::Base
    db_magic connection: :omni

    has_many :data_type_tags
    has_many :data_sets

  end
end