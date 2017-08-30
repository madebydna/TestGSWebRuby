class Admin::OspDemigodController < ApplicationController
  layout 'no_header_and_footer'

  def show

  end

  def create
    # params[:member_id]
    # params[:state]
    # params[:school_ids]

    # 1) validate params
    #   if errors
    #     @errors = errors
    #     render 'create'
    #     return
    #   end
    # 2) duplicate memberships
    #   school_ids.each do |id|
    #     EspMembership.create(member_id: member_id, state: state, school_id: id, status: 'approved', active: true, job_title: existing_membership.job_title)
    #   end
  end

  private

  def errors
    # Do validations and return if any fail
    error_array = []

    error_array << 'Invalid state' unless States.abbreviations.include?(state)

    if school_ids.present?
      school_ids.split(',').each do |id_str|
        id = id_str.to_i
        error_array << "Invalid school id '#{id_str}'" unless id.to_s == id_str
      end
    else
      error_array << 'Missing school ids'
    end

    if error_array.empty?
      if user.present?
        error_array << 'Unverified email' unless email_verified?
      else
        error_array << 'User not found'
      end

      school_ids_array.each do |id|
        school = School.find_by_state_and_id(state,id)
        if school.present?
          error_array << "School #{id} is inactive" unless school.active?
        else
          error_array << "Cannot find school with id #{id}"
        end
      end
    end


    error_array
  end

  def member_id
    params[:member_id].to_i
  end

  def state
    params[:state]
  end

  def school_ids
    params[:school_ids]
  end

  def school_ids_array
    school_ids.split(',').map(&:to_i).reject(&:zero?)
  end

  def existing_membership
    return @_existing_membership if defined?(@_existing_membership)
    @_existing_membership ||= EspMembership.where(member_id: member_id, active: true).first
  end

  def duplicate_memberships
    school_ids_array.each do |id|
      EspMembership.create(
        member_id: member_id,
        state: state,
        school_id: id,
        status: 'approved',
        active: true,
        job_title: existing_membership.job_title
      )
    end
  end

  def user
    return @_user if defined?(@_user)
    @_user ||= User.find_by_id(member_id)
  end

  def email_verified?
    user.email_verified?
  end

  def valid_school?

  end

end