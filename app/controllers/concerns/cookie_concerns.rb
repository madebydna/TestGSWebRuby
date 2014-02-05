module CookieConcerns
  extend ActiveSupport::Concern

  COOKIE_CONFIG = {
    _default: {
      hash: false,
      domain: :all,
      duration: nil
    },
    history: {
      hash: true,
      duration: 1.day
    },
    last_school: {
      hash: true,
      duration: 1.day,
    },
    return_to: {
      hash: false,
      duration: 1.day,
    },
    deferred_action: {
      hash: true,
      duration: 1.day,
    }
  }

  # Given a cookie name, return the cookie's configuration with possible options merged on top
  def cookie_config(cookie_name, options = {})
    if COOKIE_CONFIG[cookie_name]
      config = COOKIE_CONFIG[:_default].merge COOKIE_CONFIG[cookie_name]
    else
      config = COOKIE_CONFIG[:_default]
    end
    config.merge options
  end

  # Returns the cookie for a given name. If it's a cookie hash, parse the JSON back into a hash and return that
  def cookie(cookie_name)
    config = cookie_config cookie_name

    if config[:hash]
      begin
        JSON.parse(cookies[cookie_name], {
          :symbolize_names => true
        })
      rescue
        {}
      end
    else
      cookies[cookie_name]
    end
  end

  # For normal cookies, delete the cookie
  # For cookie dictionaries, delete only portion of cookie described by key
  def delete_cookie(cookie_name, key = nil)
    config = self.cookie_config cookie_name

    if config[:hash] && key.present?
      cookie = self.cookie cookie_name
      cookie.delete key.to_sym
    else
      cookies.delete cookie_name
    end
  end

  # Write a cookie value for normal cookies. For cookie dictionaries, write the value onto the cookie hash
  # Writes expiration and domain based on the configuration hash at top of file
  def write_cookie_value(cookie_name, value, key = nil, overwrite = true, options = {})
    config = self.cookie_config cookie_name, options

    unless overwrite
      current_value = read_cookie_value cookie_name, key, options
      return if current_value.present?
    end

    if config[:hash]
      if key.present?
        cookie = self.cookie cookie_name
        cookie[key.to_sym] = value
        new_cookie = cookie.to_json
      else
        new_cookie = value.to_json
      end
    else
      new_cookie = value
    end

    write_cookie cookie_name, new_cookie
  end

  # If the cookie is a cookie hash (hash), and key is provided, return the specific value in the hash
  # If it's a normal key=value cookie, return the value
  def read_cookie_value(cookie_name, key = nil, options = {})
    config = self.cookie_config cookie_name, options
    cookie = self.cookie cookie_name

    if config[:hash] && key.present?
      cookie[key.to_sym]
    else
      cookie
    end
  end

  private

  def write_cookie(cookie_name, value)
    config = self.cookie_config cookie_name

    cookie_hash = {}
    cookie_hash[:value] = value
    cookie_hash[:domain] = config[:domain].presence || :all
    cookie_hash[:expires] = config[:duration].from_now if config[:duration].present?

    cookies[cookie_name] = {
      value: value,
      domain: config[:domain]
    }
  end

end
