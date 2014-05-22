class Admin::DataLoadSchedulesController < ApplicationController

  def index
    sort_by = params[:sort_by] || 'live_by'
    @list_view = params[:list_view] || nil
    @loads = Admin::DataLoadSchedule.all.sort_by {|load| load[sort_by]}
  end

  def new
    @load = Admin::DataLoadSchedule.new
  end

  def edit
    @load = Admin::DataLoadSchedule.find(params[:id])
  end

  def update
    @load = Admin::DataLoadSchedule.find(params[:id])
    update_or_create_data_load(@load,params)
  end

  def create
    @load = Admin::DataLoadSchedule.new
    update_or_create_data_load(@load,params)
  end

  private

  def update_or_create_data_load(data_load,p)
    data_load.state = p[:state]
    data_load.description = p[:description]
    data_load.load_type = p[:load_type]
    data_load.year_to_load = p['year_to_load(1i)']
    data_load.released = "#{p['released(1i)']}-#{p['released(2i)'].to_s.rjust(2, '0')}-#{p['released(3i)'].to_s.rjust(2, '0')}"
    data_load.acquired = "#{p['acquired(1i)']}-#{p['acquired(2i)'].to_s.rjust(2, '0')}-#{p['acquired(3i)'].to_s.rjust(2, '0')}"
    data_load.live_by = "#{p['live_by(1i)']}-#{p['live_by(2i)'].to_s.rjust(2, '0')}-#{p['live_by(3i)'].to_s.rjust(2, '0')}"
    data_load.updated_by = p['updated_by']
    if data_load.save
      redirect_to '/admin/gsr/data-planning'
    end
  end

end
