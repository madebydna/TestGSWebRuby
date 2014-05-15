class Admin::DataLoadSchedulesController < ApplicationController

  def index
    sort_by = params[:sort_by] || 'live_by'
    @list_view = params[:list_view] || nil
    @loads = Admin::DataLoadSchedule.all.sort_by {|load| load[sort_by]}
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
    @load.released = "#{p['released(1i)']}-#{p['released(2i)'].to_s.rjust(2, '0')}-#{p['released(3i)'].to_s.rjust(2, '0')}"
    @load.acquired = "#{p['acquired(1i)']}-#{p['acquired(2i)'].to_s.rjust(2, '0')}-#{p['acquired(3i)'].to_s.rjust(2, '0')}"
    @load.live_by = "#{p['live_by(1i)']}-#{p['live_by(2i)'].to_s.rjust(2, '0')}-#{p['live_by(3i)'].to_s.rjust(2, '0')}"
    @load.updated_by = p['updated_by']
    if @load.save
      redirect_to '/admin/gsr/data-planning'
    end
  end

end
