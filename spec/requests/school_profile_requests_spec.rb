require 'spec_helper'

describe 'School profile requests' do

    describe 'old style overview page should redirect to the correct profile URI' do
      it 'it handles state and id params' do
        get '/school/overview.page?id=1&state=ca', state: 'ca'
        expect(response.headers['Location']).to eq 'http://www.example.com/california/city/1-school-name/'
      end

      describe 'it handles state and id params and is case-sensitive' do
        [
          {'Id' => '1', 'state' => 'ca'},
          {'ID' => '1', 'state' => 'ca'},
          {'id' => '1', 'STATE' => 'ca'},
          {'id' => '1', 'State' => 'ca'}
        ].each do |params|
          params_string = '?'
          params.each_pair do |key, value|
            params_string << "#{key}=#{value}"
            params_string << '&'
          end
          params_string = params_string[0..-2]
          it "when given /school/overview.page#{params_string} it redirects to /status/error404.page" do
            get "/school/overview.page#{params_string}"
            expect(response.headers['Location']).to eq 'http://www.example.com/status/error404.page'
          end
        end
      end
    end

end