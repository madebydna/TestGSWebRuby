class Admin::OspDemigodController < ApplicationController
  protect_from_forgery
  layout 'admin'

  def show

  end

  def create
    @errors = errors
    if @errors.present?
      @previous_ids = school_ids
      @member_id = member_id
      @state = state
    else
      duplicate_memberships
      @success = 'Operation successful'
    end
    render 'show'
  end

  private

  def errors
    # Do validations and return if any fail
    error_array = []

    error_array << 'Invalid state' unless States.abbreviations.include?(state)

    if school_ids.present?
      school_ids.split(',').each do |id_str|
        error_array << "Invalid school id '#{id_str}'" unless id_str.to_i.to_s == id_str
      end
    else
      error_array << 'Missing school ids'
    end

    # Don't bother checking for active schools if there were issues parsing the state/school_ids
    if error_array.empty?
      school_ids_array.each do |id|
        school = School.find_by_state_and_id(state,id)
        if school.present?
          error_array << "School #{id} is inactive" unless school.active?
        else
          error_array << "Cannot find school with id #{id}"
        end
      end
    end

    if user.present?
      error_array << 'Unverified email' unless user.email_verified?
      if existing_membership.present?
        if school_ids.present? && school_ids_array.include?(existing_membership.school_id)
          error_array << "Member has existing membership to school #{existing_membership.school_id}"
        end
      else
        error_array << 'Member does not have existing, approved OSP membership'
      end
    else
      error_array << "User #{member_id} not found"
    end

    error_array
  end

  def member_id
    params[:member_id].to_i
  end

  def state
    params[:state].downcase if params[:state]
  end

  def school_ids
    params[:school_ids]
  end

  def school_ids_array
    school_ids.split(',').map(&:to_i)
  end

  def existing_membership
    return @_existing_membership if defined?(@_existing_membership)
    @_existing_membership ||= EspMembership.where(member_id: member_id, active: true).first
  end

  def duplicate_memberships
    school_ids_array.each do |id|
      EspMembership.create(
        member_id: member_id,
        state: state.upcase,
        school_id: id,
        status: 'approved',
        active: true,
        job_title: existing_membership.job_title,
        created: Time.now,
        updated: Time.now
      )
    end
  end

  def user
    return @_user if defined?(@_user)
    @_user ||= User.find_by_id(member_id)
  end
end