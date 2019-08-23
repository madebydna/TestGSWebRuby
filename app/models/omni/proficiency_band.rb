# frozen_string_literal: true

module Omni
  class ProficiencyBand < ActiveRecord::Base
    db_magic connection: :omni

    has_many :test_data_values

  end
end