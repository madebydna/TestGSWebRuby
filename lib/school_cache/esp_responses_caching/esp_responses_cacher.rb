class EspResponsesCaching::EspResponsesCacher < Cacher

  CACHE_KEY = 'esp_responses'

  def query_results
    @query_results ||= (
    EspResponse.on_db(school.shard).where(school_id: school.id).active
    )
  end

  def build_hash_for_cache
    hash = {}
    query_results.each do |data_set_and_value|
      hash.deep_merge!(build_esp_response_hash(data_set_and_value))
    end

    hash
  end

  def build_esp_response_hash(esp_response)
    {
        esp_response.response_key => {
            esp_response.response_value => {
                member_id: esp_response.member_id,
                source: esp_response.esp_source,
                created: esp_response.created
            }
        }
    }
  end

  def self.listens_to?(data_type)
    :esp_response == data_type
  end

end