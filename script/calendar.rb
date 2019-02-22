require 'net/http'
require 'open-uri'
require 'json'

# district_tandem_results | CREATE TABLE `district_tandem_results` (
#   `id` int(11) NOT NULL AUTO_INCREMENT,
#   `state` varchar(20) DEFAULT NULL,
#   `district_id` int(11) DEFAULT NULL,
#   `district_name` varchar(250) DEFAULT NULL,
#   `nces` varchar(30) DEFAULT NULL,
#   `results` mediumtext,
#   `status` varchar(40) DEFAULT NULL,
#   PRIMARY KEY (`id`)
# ) ENGINE=InnoDB AUTO_INCREMENT=19610 DEFAULT CHARSET=utf8mb4

BASE_URL = 'https://api.tandem.co/rest/index.php'

State.all.each do |state|
  puts state.state
  districts = District.on_db(state.state.downcase.to_sym).active.select(:state, :id, :name, :nces_code)

  districts.each do |district|
    district_url = "#{BASE_URL}?token=greatschoolsftw&type=calendar&sub_type=district&id=#{district.nces_code}&event_type=yearly&api_version=2017-10-01&data_type=jcal"
    uri = URI(district_url)

    district_record = DistrictTandemResults.new
    district_record.state = state.state
    district_record.district_id = district.id 
    district_record.district_name = district.name
    district_record.nces = district.nces_code 

    begin 
      response = open(uri, :read_timeout => 3).read
    rescue Net::OpenTimeout, Net::ReadTimeout
      district_record.status = "timeout"
    end 

    begin 
      district_record = JSON.parse(response)
    rescue JSON::ParserError
      district_record.status = "parser"
      district_record.results = response 
    else
      district_record.status = "success"
      district_record.results = district_record 
    end 

    district_record.save 
  end 
end