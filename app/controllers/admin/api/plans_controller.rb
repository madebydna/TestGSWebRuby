class Admin::Api::UsersController < ApplicationController
  include Api::ErrorHelper

  layout 'admin'

  def index
    @plans = Api::Plan.all
  end

end