class SigninController < ApplicationController
  protect_from_forgery

  layout 'application'

  def signin

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
