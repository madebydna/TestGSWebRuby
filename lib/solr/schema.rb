module Solr
  class Schema

    def self.with_url(url)
      new(RSolr.connect(url: url))
    end

    def self.with_rw_client
      new(Client.rw)
    end

    def initialize(client)
      @client = client
    end

    def add_field(field)
      @client.post(
        "/solr/main/schema",
        headers: {
          "Content-Type" => "application/json",
        },
        data: {
          "add-field" => field.to_h,
        }.to_json,
      )
      @_solr_fields = nil
    end

    def solr_fields
      @_solr_fields ||= @client.get("/solr/main/schema/fields")["fields"]
    end

    def solr_field_names
      solr_fields.map { |h| h["name"] }
    end

    def field_exists?(field)
      solr_field_names.include?(field.name.to_s)
    end
  end
end