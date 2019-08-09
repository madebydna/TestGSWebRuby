# frozen_string_literal: true

module Omni
  class Breakdown < ActiveRecord::Base
    db_magic connection: :omni

    NOT_APPLICABLE = "Not Applicable"

    has_many :breakdown_tags

  end
end