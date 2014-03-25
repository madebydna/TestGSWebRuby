class Admin::HeldSchoolController < ApplicationController

  layout 'application'

  def create
    held_school = HeldSchool.new params[:held_school]
    if held_school.save
      flash_notice 'School has been put on hold.'
    else
      flash_error 'Sorry, there was an error putting the school on hold.'
    end

    redirect_back
  end

  def update
    held_school = HeldSchool.find(params[:id]) rescue nil

    if held_school
      if held_school.update_attributes(params[:held_school])
        flash_notice 'Held school info has been updated.'
      else
        flash_error 'Sorry, there was an error updating the held school info.'
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
