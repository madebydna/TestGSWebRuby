class Admin::FirstActiveSchoolUrlPerStateController < ApplicationController
  def show
    urls = States.abbreviations.map do |state|
      s = School.on_db(state).active.first
      school_path(s)
    end
    render plain: urls.join("\n")
  end
end
