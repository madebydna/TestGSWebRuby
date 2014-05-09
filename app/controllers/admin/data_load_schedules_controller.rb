class Admin::DataLoadSchedulesController < ApplicationController

  def index
    @loads = Admin::DataLoadSchedule.all
  end

  def new
    @load = Admin::DataLoadSchedule.new
  end

  def create
    p = params[:admin_data_load_schedule]
    @load = Admin::DataLoadSchedule.new
    @load.state = p[:state]
    @load.description = p[:description]
    @load.load_type = p[:load_type]
    @load.year_to_load = p['year_to_load(1i)']
    @load.released = "#{p['released(1i)']}-0#{p['released(2i)']}-0#{p['released(3i)']}"
    @load.acquired = "#{p['acquired(1i)']}-0#{p['acquired(2i)']}-0#{p['acquired(3i)']}"
    @load.live_by = "#{p['live_by(1i)']}-0#{p['live_by(2i)']}-#{p['live_by(3i)']}"
    @load.updated_by = p['updated_by']
    if @load.save
      redirect_to '/admin/gsr/data-planning'
    end
  end

end
