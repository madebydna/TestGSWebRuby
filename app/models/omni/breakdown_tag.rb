# frozen_string_literal: true

module Omni
  class BreakdownTag < ActiveRecord::Base
    db_magic connection: :omni

    belongs_to :breakdown

  end
end