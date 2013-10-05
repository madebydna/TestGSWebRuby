# ----------------------------------------------------------------------------------
# monkey patch functionality of SitePrism
# Gain public access to element_exists?
# And create a build method that will register element definitions onto a hash
# ----------------------------------------------------------------------------------
class SitePrism::Page

  raise 'SitePrism::Page not defined' if not defined? SitePrism::Page

  public :element_exists?
  ElementData = Struct.new(:regex, :symbol, :selector, :find_args)

  def self.build(regex, name, *find_args)
    if !regex.instance_of? Regexp
      find_args = Array(name) + find_args
      name = regex
      regex = nil
    end

    selector = find_args[0] if (find_args.any? && find_args[0].instance_of?(String))

    element_data = Hashie::Mash.new(
      regex: regex,
      symbol: name,
      selector: selector,
      find_args: find_args
    )

    @@element_lookup ||= {}
    @@element_lookup[name] = element_data
    @@element_lookup[regex] = element_data unless regex.nil?

    super name, *find_args
  end

  def element(element_name)
    element_data = lookup_element element_name

    raise "Element '#{element_name}' not defined for page #{self.class}" if element_data.nil?

    if element_data.captures
      self.send element_data.symbol, *element_data.captures
    else
      self.send element_data.symbol
    end
  end

  def lookup_element(element_name)
    element_data ||= @@element_lookup[element_name.to_sym]

    return element_data unless element_data.nil?

    @@element_lookup.each do |key, value|
      if key.is_a? Regexp
        match = key.match element_name.to_s
        return value.clone.merge(captures: match.captures) unless match.nil?
      end
    end

    raise "Element '#{element_name}' not defined for page #{self.class}" if element_data.nil?
  end

  def lookup_selector(element_name)
    (lookup_element element_name).selector
  end

  def lookup_element_name(element_name)
    (lookup_element element_name).symbol
  end

end
