class WordpressInterfaceController < ApplicationController

  layout false
  skip_before_filter :verify_authenticity_token, :only => [:call_from_wordpress]

  def call_from_wordpress
    response = {}

    wp_action = params[:wp_action]
    wp_params = params[:wp_params]

    puts(wp_action)
    puts(wp_params)

    response = send(wp_action, wp_params)

    respond_to do |format|
      format.json { render json: response }
    end
  end

  def newsletter_signup(wp_params)
    puts(wp_params['email'])
    if (wp_params['state'].present?)
      state = state_abbreviate (wp_params['state'])
    end
    puts(state)
    # add user to table list_member for newsletter
    user = User.find_by_email(wp_params['email'])
    if (user.blank?)
      user = User.new
      user.email = wp_params['email']
      user.password = User.generate_password
      user.how = 'wp_newsletter'
      user.save!
    end
    user_id = user.id
    # add grades to this user in student table
    if (wp_params['grade'].present?)
      wp_params['grade'].each do |grade|
        student = StudentGradeLevel.where("member_id = ? AND grade = ?", user_id, grade)
        if (student.blank?)
          student = StudentGradeLevel.new
          student.member_id = user_id
          student.grade = grade
          if (state.present?)
            student.state = state
          end
          student.save!
        end
      end
    end

    greatnews = Subscription.find_by_member_id_and_list(user_id, 'greatnews')
    if (greatnews.blank?)
      greatnews = Subscription.new
      greatnews.member_id = user_id
      greatnews.list = 'greatnews'
      if (state.present?)
        greatnews.state = state
      end
      greatnews.save!
    end

    greatkidsnews = Subscription.find_by_member_id_and_list(user_id, 'greatkidsnews')
    if (greatkidsnews.blank?)
      greatkidsnews = Subscription.new
      greatkidsnews.member_id = user_id
      greatkidsnews.list = 'greatkidsnews'
      if (state.present?)
        greatkidsnews.state = state
      end
      greatkidsnews.save!
    end

    # found_user.id
    return {'member_id' => user_id}
  end

  def email_friend

  end

  def message_signup

  end

  def state_abbreviate (state)
    state.gsub! '-', ' ' if state.length > 2
    state_abbreviation = States.abbreviation(state)
    state_abbreviation.upcase! if state_abbreviation.present?
    state_abbreviation
  end

  # def add_to_list_active(user_id, list_name, state)
  #   s = Subscription.find_by_member_id_and_list(user_id, list_name)
  #   if(s.blank?)
  #     s = Subscription.new
  #     s.member_id = user_id
  #     s.list = 'greatkidsnews'
  #     if(state.present?)
  #       s.state = state
  #     end
  #     s.save!
  #   end
  # end

end