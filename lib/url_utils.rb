class UrlUtils

  def self.contains_url?(string)
    !! /(https?:\/\/)?\w*\.\w+(\.\w+)*(\/\w+)*(\.\w*)?/.match(string)
  end
end