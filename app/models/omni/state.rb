module Omni
  class State < ActiveRecord::Base
    db_magic connection: :omni
  end
end