require 'spec_helper'
require 'support/shared_examples_for_generic_crud_controllers'

describe Admin::HeldSchoolController do
  it_behaves_like 'controller with generic create method', HeldSchool
  it_behaves_like 'controller with generic update method', HeldSchool
  it_behaves_like 'controller with generic destroy method', HeldSchool
end
