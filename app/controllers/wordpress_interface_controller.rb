class WordpressInterfaceController < ApplicationController

  layout false
  skip_before_filter :verify_authenticity_token, :only => [:call_from_wordpress]

  # These arrays are for white listing
  SUPPORTED_ACTIONS = ['newsletter_signup', 'email_testguide', 'message_signup']
  SUPPORTED_GRADES = ['PK', 'KG', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12']
  TEST_TYPE = ['parcc', 'sbac']
  NEWSLETTER_HOW = 'wp_newsletter'
  LINK_URL_STARTS_WITH = 'http://www.greatschools.org/gk/common-core-test-guide/'

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
    user_id = create_member(wp_params['email'], NEWSLETTER_HOW)

    # grade association to user is in the student table
    create_students(user_id, wp_params['grade'], state)

    # sign up for these lists
    lists = ['greatnews', 'greatkidsnews']
    create_subscriptions(user_id, lists, state)

    # found_user.id
    return {'member_id' => user_id}
  end

  def email_testguide(wp_params)
    if (wp_params['state'].present?)
      state = state_abbreviate (wp_params['state'])
    end
    if SUPPORTED_GRADES.include?(wp_params['grade'])
      grade = wp_params['grade']
    end
    if TEST_TYPE.include?(wp_params['test_type'])
      test_type = wp_params['test_type']
    end

    if wp_params['link_url'].start_with? LINK_URL_STARTS_WITH
      link_url = wp_params['link_url']
    end

    EmailTestGuide.deliver_to_user(wp_params['email_to'],
                                   wp_params['email_from'],
                                   state,
                                   grade,
                                   link_url,
                                   test_type)
  end

  def message_signup(wp_params)

  end

  def state_abbreviate (state)
    state.gsub '-', ' ' if state.length > 2
    state_abbreviation = States.abbreviation(state)
    state_abbreviation.upcase! if state_abbreviation.present?
    state_abbreviation
  end

  def create_subscriptions(user_id, list_arr, state)
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
          GSLogger.error(:gk_action, nil, message: 'WP Newsletter subscription failed to save', vars: {
                                       user_id: user_id,
                                       list_name: list_name,
                                       state: state
                                   })
        end
      end
    end
  end

  def create_students(user_id, grades, state)
    # add grades to this user in student table
    if grades.present?
      # remove duplicates
      grades_uniq = grades.uniq
      grades_uniq.each do |grade|
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
              GSLogger.error(:gk_action, nil, message: 'WP Newsletter student failed to save', vars: {
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

  def create_member(email, how)
    user = User.find_by_email(email)
    if (user.blank?)
      user = User.new
      user.email = email
      user.password = User.generate_password
      user.how = how
      unless user.save!
        GSLogger.error(:gk_action, nil, message: 'WP Newsletter user failed to save', vars: {
                                     email: email,
                                     how: how
                                 })
      end
    end
    user.id
  end

end