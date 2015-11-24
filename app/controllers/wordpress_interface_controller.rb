class WordpressInterfaceController < ApplicationController

  layout false
  skip_before_filter :verify_authenticity_token, :only => [:call_from_wordpress]

  # These arrays are for white listing
  SUPPORTED_ACTIONS = ['newsletter_signup', 'email_friend', 'message_signup']
  SUPPORTED_GRADES = ['PK', 'KG', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']

  def call_from_wordpress
    wp_action = params[:wp_action]
    # white list the possible actions
    if !SUPPORTED_ACTIONS.include?(wp_action)
      respond_to do |format|
        format.json { render json: {'error' => 'Action Unsupported'} }
      end
    else
      wp_params = params[:wp_params]
      response = send(wp_action, wp_params)
      respond_to do |format|
        format.json { render json: response }
      end
    end
  end

  def newsletter_signup(wp_params)
    if (wp_params['state'].present?)
      state = state_abbreviate (wp_params['state'])
    end

    # find or create user
    user_id = member_creation(wp_params['email'], 'wp_newsletter')

    # remove duplicates
    grades = wp_params['grade'].uniq
    # grade association to user is in the student table
    student_creation(user_id, grades, state)

    # sign up for these lists
    lists = ['greatnews', 'greatkidsnews']
    subscribe_to_lists(user_id, lists, state)

    # found_user.id
    return {'member_id' => user_id}
  end

  def email_friend

  end

  def message_signup

  end

  def state_abbreviate (state)
    state.gsub '-', ' ' if state.length > 2
    state_abbreviation = States.abbreviation(state)
    state_abbreviation.upcase! if state_abbreviation.present?
    state_abbreviation
  end

  def subscribe_to_lists(user_id, list_arr, state)
    list_arr.each do |list_name|
      s = Subscription.find_by_member_id_and_list(user_id, list_name)
      if (s.blank?)
        s = Subscription.new
        s.member_id = user_id
        s.list = list_name
        if (state.present?)
          s.state = state
        end
        unless s.save!
          GSLogger.error(:messaging, nil, message: 'WP Newsletter subscription failed to save', vars: {
                                       user_id: user_id,
                                       list_name: list_name,
                                       state: state
                                   })
        end
      end
    end
  end

  def student_creation(user_id, grades, state)
    # add grades to this user in student table
    if grades.present?
      grades.each do |grade|
        if grade.present? && SUPPORTED_GRADES.include?(grade)
          student = StudentGradeLevel.where("member_id = ? AND grade = ?", user_id, grade)
          if (student.blank?)
            student = StudentGradeLevel.new
            student.member_id = user_id
            student.grade = grade
            if (state.present?)
              student.state = state
            end
            unless student.save!
              GSLogger.error(:messaging, nil, message: 'WP Newsletter student failed to save', vars: {
                                           user_id: user_id,
                                           grade: grade,
                                           state: state
                                       })

            end
          end
        end
      end
    end
  end

  def member_creation(email, how)
    user = User.find_by_email(email)
    if (user.blank?)
      user = User.new
      user.email = email
      user.password = User.generate_password
      user.how = how
      unless user.save!
        GSLogger.error(:messaging, nil, message: 'WP Newsletter user failed to save', vars: {
                                     email: email,
                                     how: how
                                 })
      end
    end
    user.id
  end

end