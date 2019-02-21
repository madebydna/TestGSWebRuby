module Solr
  class Client
    def self.ro
      @_ro ||= connect(ENV_GLOBAL['solr7.ro.server.url'] || ENV_GLOBAL['solr.ro.server.url'])
    end

    def self.rw
      @_rw ||= connect(ENV_GLOBAL['solr7.rw.server.url'] || ENV_GLOBAL['solr.rw.server.url'])
    end

    def self.connect(url)
      RSolr.connect(url: url)
    end

    def self.ro_up?
      ro.get('admin/ping')&.response&.fetch(:status) == 200
    end
  end
end