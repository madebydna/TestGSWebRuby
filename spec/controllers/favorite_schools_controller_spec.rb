require 'spec_helper'
require 'controllers/concerns/favorite_schools_concerns_spec'

describe FavoriteSchoolsController do
  it_behaves_like 'a controller that can save a favorite school'
end
