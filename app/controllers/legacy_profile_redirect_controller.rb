class LegacyProfileRedirectController < ApplicationController
  def show
    if school
      redirect_to school_path(school), :status => 301
    elsif state_abbr
      redirect_to state_path(state_name), :status => 302
    else
      redirect_to '/', :status => 302
    end
  end

  private

  def id
    params[:id].present? ? params[:id].to_i : nil
  end

  def state_abbr
    return @_state_abbr if defined?(@_state_abbr)
    @_state_abbr ||= begin
      state = params[:state].present? ? params[:state].downcase : nil
      if state && States.abbreviations.include?(state)
        state
      end
    end
  end

  def state_name
    States.state_path(state_abbr)
  end

  def school
    return @_school if defined?(@_school)
    @_school ||= begin
      if id && state_abbr
        School.on_db(state_abbr.to_sym).find_by_id(id)
      end
    end
  end
end