require 'open-uri'

module ApplicationHelper
  include CookieConcerns
  include GsI18n
  include HandlebarsHelper

  # Hack: Remove /assets/ prefix since it is set that way in hub_config
  # And needs to remain until hubs are off of Java
  def image_tag(path, *args, &blk)
    path = path.gsub('/assets/', '') if path.match(/hubs/i)
    super(path, *args, &blk)
  end

  # In this method, capitalize means to uppercase the first letter of a phrase and leave the rest untouched.
  # Default implementation of capitalize in rails will uppercase first letter and downcase the rest of the string
  def capitalize_if_string(object)
    if object.is_a? String
      object.gs_capitalize_first
    else
      object
    end
  end

  def log_view_error(message, e)
    Rails.logger.debug "#{message}: #{e}"
    if Rails.application.config.consider_all_requests_local
      render inline: '<div class="row"><strong>' + message + '</strong></div>'
    end
  end

  def render_array_horizontally(input_array, max_array)
    min_size = 12 / input_array.size
    size_str = ''
    max_array.each do |key, value|
      sizing_str = min_size
      if min_size < value
        sizing_str = value
      end
      size_str << ' col-'+key.to_s+'-'+sizing_str.to_s
    end
    output = ""
    input_array.each_with_index do | value, index |
      output << "<div class='"+size_str+"'>"+value+"</div>"
    end
    output
  end

  # When passed a content string or a block, adds that content to an array, which will get uniqued before being
  # displayed
  # If the layout erb file asks for unique_content_for(:blah) without passing content or block, then the uniqued
  # content will be returned
  def unique_content_for(name, content = nil, &block)
    @content_array ||= {}
    if content || block_given?
      content = capture(&block) if block_given?
      @content_array[name] ||= []
      @content_array[name] << content if content
      nil
    else
      raw (@content_array[name] || []).uniq.join
    end
  end

  def remote_ip
     request.env['X_Forwarded_For'] || request.env['X_CLUSTER_CLIENT'] || request.remote_ip
  end

  def div_tag(*args, &block)
    content_tag_with_sizing :div, *args, &block
  end

  def topnav(school, hub = nil)
    TopNav.new(school, cookies, hub)
  end

  def db_t(key, *args)
    default = args.first[:default] if args.first.is_a?(Hash) && args.first[:default]
    if key.blank?
      GSLogger.warn(:i18n, nil, vars: [key] + args, message: 'db_t received blank key')
      return default || key
    end
    cleansed_key = key.to_s.gsub('.', '').strip
    cleansed_key = cleansed_key.to_sym if key.is_a?(Symbol)
    t(cleansed_key, *args)
  end

  def current_partial
    @virtual_path.split("/").last.sub(/^_/, "")
  end

  #####################################################################################################################
  #
  #   supporting functions only used in this helper
  #
  #####################################################################################################################
  def column_sizing_classes(xs, sm, md, lg)
    " col-xs-#{xs} col-sm-#{sm} col-md-#{md} col-lg-#{lg}"
  end

  def content_tag_with_sizing(name, *args, &block)
    # The inner content of the tag depends on whether or not a block is given.
    # If content of the tag is the first item, the options will be second
    args.unshift nil if args.first && args.first.is_a?(Hash)
    options = args.second || {}

    if options[:sizes]
      default_sizing = {xs: 12, sm: 12, md: 12, lg: 12}
      sizing = (options[:sizes] || {}).reverse_merge! default_sizing
      options.delete :sizes
      sizing_class = self.column_sizing_classes(sizing[:xs], sizing[:sm], sizing[:md], sizing[:lg])
      options[:class] ||= ''
      options[:class] << sizing_class
    end

    content_tag name, *args, &block
  end


end
