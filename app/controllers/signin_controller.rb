class SigninController < ApplicationController
  include ReviewControllerConcerns

  protect_from_forgery

  layout 'application'

  # gets the reg / sigin form page
  def new

  end

  # handles registration and login
  def create
    # url_string = 'http://omega.greatschools.org/community/registration/socialRegistrationAndLogin.json'
    # make call to java to register or sign in

    # is response code 200 and got a success from java json response?
    if true
      log_user_in
      process_pending_actions
      #redirect_back_or_default('/index.page') # should not go to index page
    else
      # calculate error based on whether there was a registration validation error or if a login attempt failed
      flash[:error] = '[Error message goes here]'
      redirect_to :new
    end
  end

  def process_pending_actions
    review_params = get_review_params
    if review_params
      # session[:review].delete
      if save_review(review_params)
        clear_review_params
        redirect_back_or_default('/california/alameda/1-alameda-high-school') # should not go to index page
      else
        ap 'COULD NOT SAVE REVIEW ---------'
        redirect_back_or_default('/california/alameda/1-alameda-high-school') # should not go to index page
        # TODO: what to do here?
      end
    else
      redirect_back_or_default('/california/alameda/1-alameda-high-school') # TODO: where do we redirect if no cookie set?
    end
  end

  def destroy
    reset_session
    self.current_user = nil
    flash[:notice] = 'Signed out'
    redirect_to(signin_url)
  end

  def register
    # worst code ever, will rewrite

    url_string = 'http://omega.greatschools.org/community/registration/socialRegistrationAndLogin.json'

    res = Net::HTTP.post_form(URI.parse(url_string), params)

    #response.headers = res.header.to_hash
    c = res.get_fields('Set-Cookie')

    c.each do |cookie|

      parts = cookie.split(';')
      hash = {}
      parts.each do |part|
        n = part.split('=')[0]
        v = part.split('=')[1]
        hash[n]=v
      end

      name = hash.keys.first
      value = hash.values.first
      hash.delete(name)

      new_hash = {}
      hash.each_pair do |k,v|
        new_hash.merge!({k.downcase => v})
      end
      hash = new_hash
      hash.symbolize_keys!

      cookies[name.to_sym] = {
        :value => value,
        :expires => hash[:expires],
        :domain => hash[:domain]
      }
    end

    respond_to do |format|
      format.json  { render :json => res.body.to_json }
    end

  end

end
