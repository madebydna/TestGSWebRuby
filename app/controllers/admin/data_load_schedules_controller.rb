class Admin::DataLoadSchedulesController < ApplicationController

  before_action :get_params
  before_action :get_load_types
  before_action :get_states

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
    attributes = format_attributes(params[:admin_data_load_schedule])
    if @load.update_attributes attributes
      redirect_to action: 'index'
    else
      flash_error 'Sorry, something went wrong updating this load.'
      redirect_to action: 'edit'
    end
  end

  def create
    @load = Admin::DataLoadSchedule.new
    attributes = format_attributes(params[:admin_data_load_schedule])
    if @load.update_attributes attributes
      redirect_to action: 'index'
    else
      flash_error 'Sorry, something went wrong updating this load.'
      redirect_to action: 'new'
    end
  end

  protected

  def get_outstanding_loads
    # Feature to come later.
    # Show a list-vew style list of loads that should have been completed and have not yet been.
    # This will make sure we don't lose loads as they disappear from calendar view.
  end

  def filter_and_sort_data_loads
    where_clause = construct_filter_where_clause(@status,@load_type)

    #TODO For priority, do it by release, not live by exact date
    sort_by = @sort_by == 'priority' ? 'live_by,local, tier' : @sort_by

    @loads = Admin::DataLoadSchedule.joins('left outer join state
                                           ON state.state = data_load_schedule.state'
                                          ).where(where_clause).order(sort_by)
  end

  def construct_filter_where_clause(status,load_type)
    where_clause = ''

    # Statuses
    if status == 'incomplete'
      where_clause += "status != 'complete' and "
    elsif status == 'available'
      where_clause += "released < '#{Time.now.strftime("%Y-%m-%d")}' and status != 'complete' and "
    elsif status and status != 'all'
      where_clause += "status = '#{status}' and "
    end

    # Load types
    if load_type and load_type != 'All'
      where_clause += "load_type = '#{load_type}' and "
    end

    # Clean up and return
    where_clause = where_clause.gsub(/^and /, '').gsub(/ and $/, '')
    where_clause
  end

  def format_attributes(p)
    updated_attributes = Hash.new
    updated_attributes['state'] = p[:state]
    updated_attributes['description'] = p[:description]
    updated_attributes['load_type'] = p[:load_type]
    updated_attributes['year_to_load'] = p['year_to_load(1i)']
    updated_attributes['released'] = "#{p['released(1i)']}-#{p['released(2i)'].to_s.rjust(2, '0')}-#{p['released(3i)'].to_s.rjust(2, '0')}"
    updated_attributes['acquired'] = "#{p['acquired(1i)']}-#{p['acquired(2i)'].to_s.rjust(2, '0')}-#{p['acquired(3i)'].to_s.rjust(2, '0')}"
    updated_attributes['live_by'] = "#{p['live_by(1i)']}-#{p['live_by(2i)'].to_s.rjust(2, '0')}-#{p['live_by(3i)'].to_s.rjust(2, '0')}"
    updated_attributes['updated_by'] = p['updated_by']
    updated_attributes['complete'] = p['complete']
    status = get_load_status(updated_attributes)
    updated_attributes['status'] = status
    puts updated_attributes
    updated_attributes
  end

  def get_load_status(attributes)
    if attributes['complete'] == '1'
      return 'complete'
    elsif !attributes['acquired'].blank?
      return 'acquired'
    else
      return 'none'
    end
  end

  def get_params
    @sort_by = params[:sort_by] || 'live_by'
    @status = params[:status] || 'complete'
    @load_type = params[:type] || nil
    @view_type = params[:view_type] || 'calendar'
  end

  def get_load_types
    @load_types = Admin::DataLoadSchedule.all.inject([]) {
      |types,h| types << h[:load_type] unless types.include?(h[:load_type]); types
    }
    @load_types.unshift 'All'
    @load_types.sort!
  end

  def get_states
    @states = States.state_hash.values.sort.map { |state| state.upcase }
    @states.unshift 'All'
  end
end
