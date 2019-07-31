# frozen_string_literal: true

module Omni
  class DataSet < ActiveRecord::Base
    db_magic connection: :omni

    has_many :test_data_values
    has_many :data_type_tags
    belongs_to :data_type
    belongs_to :source

    scope :feeds, -> { where(configuration: 'feeds') }
    scope :web, -> { where(configuration: 'web') }

    scope :by_state, -> (state) { where('state = ?', state) }
    scope :feeds_by_state, -> (state) { feeds.by_state(state) }
  end
end