class Admin::Api::PlansController < ApplicationController
  include Api::ErrorHelper

  layout 'admin'

  def index
    @plans = Api::Plan.all
  end

end