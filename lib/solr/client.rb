module Solr
  class Client
    def self.ro
      @_ro ||= connect(ENV_GLOBAL['solr.ro.server.url'])
    end

    def self.rw
      @_rw ||= connect(ENV_GLOBAL['solr.rw.server.url'])
    end

    def self.connect(url)
      RSolr.connect(url: url)
    end
  end
end