require 'spec_helper'
require 'controllers/modules/favorite_schools_concerns_shared'

describe FavoriteSchoolsController do
  it_behaves_like 'a controller that can save a favorite school'
end
