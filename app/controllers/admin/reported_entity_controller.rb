class Admin::ReportedEntityController < ApplicationController

  def deactivate
    reported_entity = ReportedEntity.find params[:id].to_i rescue nil

    if reported_entity
      reported_entity.active = false

      if reported_entity.save
        flash_notice "Reported #{reported_entity.type} has been deactivated"
      else
        flash_error "#{reported_entity.type} could not be deactivated due to \
  an unexpected error. Please try again later."
      end
    else
      flash_error "The reported entity you requested could not be found"
    end

    redirect_to moderation_admin_reviews_path
  end

end