# frozen_string_literal: true

module Omni
  class Breakdown < ActiveRecord::Base
    db_magic connection: :omni

    NOT_APPLICABLE = "Not Applicable"

    has_many :breakdown_tags

    def self.unique_ethnicity_names
      [
        'African American',
        'Asian',
        'Asian or Pacific Islander',
        'Filipino',
        'Hawaiian',
        'Hispanic',
        'Native American',
        'Native Hawaiian or Other Pacific Islander',
        'Other ethnicity',
        'Pacific Islander',
        'Race Unspecified',
        'Two or more races',
        'White'
      ]
    end

    def self.economically_disadvantaged_name
      'Economically disadvantaged'
    end

  end
end