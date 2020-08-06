class Admin::Api::PlansController < ApplicationController
  include Api::ErrorHelper
  include Api::PlansHelper

  layout 'admin'

  def index
    @plans = Api::Plan.all
  end

end