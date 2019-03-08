# frozen_string_literal: true

class Api::SortOptionSerializer
  def initialize(fields)
    @fields = fields
  end

  def to_hash
    {
      sortOptions: @fields
    }
  end
end