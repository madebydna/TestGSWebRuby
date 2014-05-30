class Admin::DataLoadSchedulesController < ApplicationController

  before_filter :get_params
  before_filter :get_load_types

  def index
    @statuses = [:all, :complete, :incomplete, :acquired, :available].sort
    @sorts = [:state,:released,:live_by, :priority]
    @loads = filter_and_sort_data_loads
    @outstanding_loads = get_outstanding_loads if @view_type == 'calendar'
  end

  def new
    @load = Admin::DataLoadSchedule.new
  end

  def edit
    @load = Admin::DataLoadSchedule.find(params[:id])
  end

  def update
    @load = Admin::DataLoadSchedule.find(params[:id])
    update_or_create_data_load(@load,params[:admin_data_load_schedule])
  end

  def create
    @load = Admin::DataLoadSchedule.new
    update_or_create_data_load(@load,params[:admin_data_load_schedule])
  end

  protected

  def get_outstanding_loads

  end

  def filter_and_sort_data_loads
    where_clause = ''
    if @status == 'incomplete'
      where_clause += "status != 'complete' and "
    elsif @status == 'available'
      where_clause += "released < '#{Time.now.strftime("%Y-%m-%d")}' and status <> 'complete' and "
    else
      where_clause += "status = '#{@status}'" if @status and @status != 'all'
    end
    where_clause += "load_type = '#{@load_type}' and " if @load_type and @load_type != 'All'
    where_clause = where_clause.gsub(/^and /, '').gsub(/ and $/, '')
    #TODO For priority, do it by release, not live by exact date
    sort_by = @sort_by == 'priority' ? 'live_by,local, tier' : @sort_by
    @loads = Admin::DataLoadSchedule.joins('left outer join state ON state.state = data_load_schedule.state'
                                          ).where(where_clause).order(sort_by)
  end

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
      redirect_to action: 'index'
    end
  end

  def get_params
    @sort_by = params[:sort_by] || 'live_by'
    @status = params[:status] || 'complete'
    @load_type = params[:type] || nil
    @view_type = params[:view_type] || 'calendar'
  end

  def get_load_types
    @load_types = Admin::DataLoadSchedule.all.inject([]) { |types,h| types << h[:load_type] unless types.include?(h[:load_type]); types}
    @load_types.unshift 'All'
    @load_types.sort!
  end

end
