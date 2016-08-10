require 'spec_helper'

def expect_redirect_to(path)
  expect(response.status).to eq(301)
  expect(response.headers['Location']).to eq("http://www.example.com#{path}")
end

describe 'Old prefiltered browse URLs' do
  {
      :'one-word state' => 'minnesota',
      :'two-word state' => 'new-jersey'
  }.each do |state_description, state|
    describe "in a #{state_description}" do
      {
          :'one-word city' => 'minneapolis',
          :'two-word city with junk in it' => '12th-st.-%23paul',
          :'city starting with public' => 'public-township-of-roy'
      }.each do |city_description, city|
        describe "in a #{city_description}" do
          {
              :'normal district' => 'Alameda-School-District',
              :'district with junk in it' => '12th-district-12-%2312',
              :'district starting with public' => 'public-schools-of-petoskey'
          }.each do |district_description, district|
            describe "in district browse with a #{district_description}" do
              {
                  :'preschools' => 'p',
                  :'elementary-schools' => 'e',
                  :'middle-schools' => 'm',
                  :'high-schools' => 'h'
              }.each do |level_path_component, level_code|
                it "should redirect the path component #{level_path_component} to the query param gradeLevels=#{level_code}" do
                  get "/#{state}/#{city}/#{district}/#{level_path_component}/"
                  expect_redirect_to("/#{state}/#{city}/#{district}/schools/?gradeLevels=#{level_code}")
                end
              end
              {
                  :'public' => 'public',
                  :'public-charter' => 'charter',
                  :'private' => 'private'
              }.each do |type_path_component, school_type|
                it "should redirect the path component #{type_path_component} to the query param st=#{school_type}" do
                  get "/#{state}/#{city}/#{district}/#{type_path_component}/schools/"
                  expect_redirect_to("/#{state}/#{city}/#{district}/schools/?st=#{school_type}")
                end
                describe "with prefiltered school type #{school_type}" do
                  {
                      :'preschools' => 'p',
                      :'elementary-schools' => 'e',
                      :'middle-schools' => 'm',
                      :'high-schools' => 'h'
                  }.each do |level_path_component, level_code|
                    it "and level #{level_path_component} should redirect to the query param gradeLevels=#{level_code}&st=#{school_type}" do
                      get "/#{state}/#{city}/#{district}/#{type_path_component}/#{level_path_component}/"
                      expect_redirect_to("/#{state}/#{city}/#{district}/schools/?gradeLevels=#{level_code}&st=#{school_type}")
                    end
                  end
                end
              end
            end
          end
          describe 'in city browse' do
            {
                :'preschools' => 'p',
                :'elementary-schools' => 'e',
                :'middle-schools' => 'm',
                :'high-schools' => 'h'
            }.each do |level_path_component, level_code|
              it "should redirect the path component #{level_path_component} to the query param gradeLevels=#{level_code}" do
                get "/#{state}/#{city}/#{level_path_component}/"
                expect_redirect_to("/#{state}/#{city}/schools/?gradeLevels=#{level_code}")
              end
            end
            {
                :'public' => 'public',
                :'public-charter' => 'charter',
                :'private' => 'private'
            }.each do |type_path_component, school_type|
              it "should redirect the path component #{type_path_component} to the query param st=#{school_type}" do
                get "/#{state}/#{city}/#{type_path_component}/schools/"
                expect_redirect_to("/#{state}/#{city}/schools/?st=#{school_type}")
              end
              describe "with prefiltered school type #{school_type}" do
                {
                    :'preschools' => 'p',
                    :'elementary-schools' => 'e',
                    :'middle-schools' => 'm',
                    :'high-schools' => 'h'
                }.each do |level_path_component, level_code|
                  it "and level #{level_path_component} should redirect to the query param gradeLevels=#{level_code}&st=#{school_type}" do
                    get "/#{state}/#{city}/#{type_path_component}/#{level_path_component}"
                    expect_redirect_to("/#{state}/#{city}/schools/?gradeLevels=#{level_code}&st=#{school_type}")
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end