# frozen_string_literal: true

module Omni
  class Source < ActiveRecord::Base
    db_magic connection: :omni

    has_many :data_sets

  end
end
