# frozen_string_literal: true

module Omni
  class DataSet < ActiveRecord::Base
    db_magic connection: :omni

    FEEDS = 'feeds'
    WEB = 'web'
    NONE = 'none'

    has_many :test_data_values
    has_many :data_type_tags
    belongs_to :data_type
    belongs_to :source

    scope :feeds, -> { where(configuration: FEEDS) }
    scope :web, -> { where(configuration: WEB) }
    scope :none_or_web, -> { where(configuration: [NONE, WEB]) }

    scope :by_state, -> (state) { where('state = ?', state) }
    scope :feeds_by_state, -> (state) { feeds.by_state(state) }
    scope :none_or_web_by_state, -> (state) { none_or_web.by_state(state) }
  end
end