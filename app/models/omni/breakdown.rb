# frozen_string_literal: true

module Omni
  class Breakdown < ActiveRecord::Base
    db_magic connection: :omni

    has_many :breakdown_tags

  end
end