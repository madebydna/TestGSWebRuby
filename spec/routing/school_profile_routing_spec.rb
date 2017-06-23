require 'spec_helper'

describe 'school profile routing' do

  def request
    return double().as_null_object
  end

  before do
    # By default, the request used for the route will have domain of 'example.org', which will cause
    # RegularSubdomain constraint to not match
    allow_any_instance_of(ActionDispatch::Request).to receive(:subdomain).and_return('www')

    default_url_options[:host] = 'greatschools.org'

    @school = FactoryGirl.build(:school, state: 'ca', city: 'alameda', id: 1, name: 'alameda high school')

    @trailing_slash =
      Rails.application.routes.default_url_options[:trailing_slash]
    Rails.application.routes.default_url_options[:trailing_slash] = false
  end

  after(:each) do
    Rails.application.routes.
      default_url_options[:trailing_slash] = @trailing_slash
  end

  it 'should route to 404 page if state is invalid' do
    expect( get '/sldkfj/alameda/1-Alameda-High-School/' ).to route_to('error#page_not_found', path:'sldkfj/alameda/1-Alameda-High-School')
  end

  it 'should route to 404 page if state is numeric' do
    expect( get '/1/alameda/1-Alameda-High-School/' ).to route_to('error#page_not_found', path:'1/alameda/1-Alameda-High-School')
  end

  it 'should not handle old style overview URL with invalid params: /school/overview.page?id=1&state=ZZ' do
    expect( get '/school/overview.page?id=1&state=ZZ' ).to(
      route_to('error#page_not_found', path: 'school/overview', format: 'page', id: '1', state: 'ZZ')
    )
    expect( get '/school/overview.page?id=1' ).to(
      route_to('error#page_not_found', path: 'school/overview', format: 'page', id: '1')
    )
    expect( get '/school/overview.page' ).to(
      route_to('error#page_not_found', path: 'school/overview', format: 'page')
    )
  end

  describe 'non-pk school scope' do

    let(:route_params) do
      {
        school_name: "Alameda-High-School",
        schoolId: "1",
      }
    end
    [
      ['overview', '', 'school'],
      ['reviews', 'reviews/', 'school'],
      ['quality', 'quality/', 'school'],
      ['details', 'details/', 'school'],
    ].each do |(action, path, path_helper)|
      describe "#{action} tab" do
        [
            ['one-word state', 'minnesota', 'mn'],
            ['two-word state', 'new-jersey', 'nj']
        ].each do |(state_description, state, state_abbr)|
          describe "In a #{state_description}" do
          before do
            route_params[:state] = state
          end
            {
                'one-word city' => 'minneapolis',
                'two-word city' => 'maple-grove',
                'city with a period in it' => 'st.-paul',
                'city with a # in it' => 'st.-%23aul',
                'city starting with a number' => '12th-city'
            }.each do |city_description, city|
              describe "In a #{city_description}" do
                before do
                  route_params[:city] = city.sub('%23','#')
                  @school = FactoryGirl.build(:school_with_new_profile,
                                              state: state_abbr,
                                              city: city.sub('%23', '#').sub('-', ' '),
                                              id: 1,
                                              name: 'alameda high school',
                                              level_code: 'e,m,h',
                                              new_profile_school: 5
                                             )
                  expect(@school).not_to be_preschool
                end

                it "has a route for #{action}" do
                  unless path == ''
                    route_params[:path] = path.gsub('/','')
                  end
                  expect( get "/#{state}/#{city}/1-Alameda-High-School/#{path}" ).
                    to route_to('school_profiles#show', route_params)
                end

                it "has a path helper for #{action}" do
                    expect( get(send("#{path_helper}_path", @school)) ).
                      to route_to('school_profiles#show', route_params )
                end

                it "has a url helper for #{action}" do
                  expect( get(send("#{path_helper}_url", @school)) ).
                    to route_to('school_profiles#show', route_params)
                end
              end
            end
          end
        end
      end
    end
  end

  describe 'pk school scope' do
    let(:route_params) do
      {
          school_name: "Alameda-High-School",
          schoolId: "1",
      }
    end
    [
        ['overview', '', 'school'],
        ['reviews', 'reviews/', 'school'],
        ['quality', 'quality/', 'school'],
        ['details', 'details/', 'school'],
    ].each do |(action, path, path_helper)|
      describe "#{action} tab" do
        [
            ['one-word state', 'minnesota', 'mn'],
            ['two-word state', 'new-jersey', 'nj']
        ].each do |(state_description, state, state_abbr)|
          describe "In a #{state_description}" do
            before do
              route_params[:state] = state
            end
            {
                'one-word city' => 'minneapolis',
                'two-word city' => 'maple-grove',
                'city with a period in it' => 'st.-paul',
                'city with a # in it' => 'st.-%23aul',
                'city starting with a number' => '12th-city'
            }.each do |city_description, city|
              describe "In a #{city_description}" do
                before do
                  route_params[:city] = city.sub('%23','#')
                  @school = FactoryGirl.build(:school, state: state_abbr, city: city.sub('%23', '#').sub('-', ' '), id: 1, name: 'alameda high school', level_code: 'p')
                  expect(@school).to be_preschool
                end
                it "has a route for #{action}" do
                  unless path == ''
                    route_params[:other] = path.gsub('/','')
                  end
                  expect( get "/#{state}/#{city}/preschools/Alameda-High-School/1/#{path}" ).
                      to route_to('school_profiles#show', route_params )
                end

                it "has a path helper for #{action}" do
                  expect( get(send("#{path_helper}_path", @school)) ).
                      to route_to('school_profiles#show', route_params )
                end

                it "has a url helper for #{action}" do
                  expect( get(send("#{path_helper}_url", @school)) ).
                      to route_to('school_profiles#show', route_params )
                end
              end
            end
          end
        end
      end
    end
  end
end