class Admin::HeldSchoolsController < Admin::AdminController
  include AdminSortable

  layout 'deprecated_application_with_webpack'

  PAGE_SIZE = 50
  SORT_OPTIONS = {
    "hold_date" => "placed_on_hold_at",
    "held_school" => "school_name",
    "default" => "school_name"
  }
  DEFAULT_DIRECTION = "asc"

  def index
    @held_schools = HeldSchool.all_active_with_school(
      order_by: sort_column,
      order_dir: sort_direction,
      page: params[:page],
      per_page: PAGE_SIZE)
  end

  def create
    hold = HeldSchool.where(state: params[:held_school][:state], id: params[:held_school][:school_id]).first
    if hold
      if hold.update(active: 1, notes: params[:held_school][:notes])
        flash_notice 'School has been put on hold.'
      else
        flash_error 'Sorry, there was an error putting the school on hold.'
      end
    else
      hold = HeldSchool.new params[:held_school]
      if hold.save
        flash_notice 'School has been put on hold.'
      else
        flash_error 'Sorry, there was an error putting the school on hold.'
      end
    end

    redirect_back
  end

  def update
    held_school = HeldSchool.where(id: params[:id]).first

    if held_school
      if held_school.update_attributes(params[:held_school])
        flash_notice 'Held school info has been updated.'
      else
        flash_error 'Sorry, there was an error updating the held school info.'
      end
    end

    redirect_back
  end

  def remove_hold
    hold = HeldSchool.where(id: params[:id]).first

    if hold
      if hold.remove_hold
        flash_notice 'School is no longer on held list.'
      else
        flash_error 'Sorry, there was a problem removing school from the held list'
      end
    end

    redirect_back
  end

  def destroy
    held_school = HeldSchool.find(params[:id]) rescue nil

    if held_school
      if held_school.destroy
        flash_notice 'School is no longer on held list.'
      else
        flash_error 'Sorry, there was a problem removing school from the held list'
      end
    else
      flash_error 'The school you chose is not currently held.'
    end

    redirect_back
  end

end
