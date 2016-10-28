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
      ['reviews', 'reviews/', 'school_reviews'],
      ['quality', 'quality/', 'school_quality'],
      ['details', 'details/', 'school_details'],
    ].each do |(action, path, path_helper)|
      describe "#{action} tab" do
        [
            ['one-word state', 'minnesota', 'mn'],
            ['two-word state', 'new-jersey', 'nj']
        ].each do |(state_description, state, state_abbr)|
          describe "In a #{state_description}" do
          before do
            route_params.merge!({state: state})
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
                  route_params.merge!({city: city.sub('%23',"#")})
                end
                describe "for a school without new profile flag" do
                  before do
                    @school = FactoryGirl.build(:school,
                                                state: state_abbr,
                                                city: city.sub('%23', '#').sub('-', ' '),
                                                id: 1,
                                                name: 'alameda high school',
                                                level_code: 'e,m,h'
                                               )
                    expect(@school).not_to be_preschool
                    allow_any_instance_of(Constraint::NewSchoolProfile)
                      .to receive(:matches?).and_return(false)
                  end
                  it "has a route for #{action}" do
                    expect( get "/#{state}/#{city}/1-Alameda-High-School/#{path}" ).
                        to route_to("school_profile_#{action}##{action}", route_params)
                  end

                  it "has a path helper for #{action}" do
                    expect( get(send("#{path_helper}_path", @school)) ).
                        to route_to("school_profile_#{action}##{action}", route_params)
                  end

                  it "has a url helper for #{action}" do
                    expect( get(send("#{path_helper}_url", @school)) ).
                        to route_to("school_profile_#{action}##{action}", route_params)
                  end
                end
                describe "for a school with a new profile flag" do
                  before do
                    @school = FactoryGirl.build(:school_with_new_profile,
                                                state: state_abbr,
                                                city: city.sub('%23', '#').sub('-', ' '),
                                                id: 1,
                                                name: 'alameda high school',
                                                level_code: 'e,m,h',
                                                new_profile_school: 5
                                               )
                    allow_any_instance_of(Constraint::NewSchoolProfile)
                      .to receive(:matches?).and_return(true)
                    expect(@school).not_to be_preschool
                    root_path = ''
                    unless path == root_path
                      route_params.merge!({path: path.gsub("/","")})
                    end
                  end

                  it "has a route for #{action}" do
                    expect( get "/#{state}/#{city}/1-Alameda-High-School/#{path}" ).
                      to route_to("school_profiles#show", route_params)
                  end

                  it "has a path helper for #{action}" do
                      expect( get(send("#{path_helper}_path", @school)) ).
                        to route_to("school_profiles#show", route_params )
                  end

                  it "has a url helper for #{action}" do
                    expect( get(send("#{path_helper}_url", @school)) ).
                      to route_to("school_profiles#show", route_params)
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  describe 'pk school scope' do
    [
        ['overview', '', 'school'],
        ['reviews', 'reviews/', 'school_reviews'],
        ['quality', 'quality/', 'school_quality'],
        ['details', 'details/', 'school_details'],
    ].each do |(action, path, path_helper)|
      describe "#{action} tab" do
        [
            ['one-word state', 'minnesota', 'mn'],
            ['two-word state', 'new-jersey', 'nj']
        ].each do |(state_description, state, state_abbr)|
          describe "In a #{state_description}" do
            {
                'one-word city' => 'minneapolis',
                'two-word city' => 'maple-grove',
                'city with a period in it' => 'st.-paul',
                'city with a # in it' => 'st.-%23aul',
                'city starting with a number' => '12th-city'
            }.each do |city_description, city|
              describe "In a #{city_description}" do
                before do
                  @school = FactoryGirl.build(:school, state: state_abbr, city: city.sub('%23', '#').sub('-', ' '), id: 1, name: 'alameda high school', level_code: 'p')
                  expect(@school).to be_preschool
                end
                it "has a route for #{action}" do
                  expect( get "/#{state}/#{city}/preschools/Alameda-High-School/1/#{path}" ).
                      to route_to("school_profile_#{action}##{action}", state: state, city: city.sub('%23', '#'), schoolId: '1', school_name: 'Alameda-High-School' )
                end

                it "has a path helper for #{action}" do
                  expect( get(send("#{path_helper}_path", @school)) ).
                      to route_to("school_profile_#{action}##{action}", state: state, city: city.sub('%23', '#'), schoolId: '1', school_name: 'Alameda-High-School' )
                end

                it "has a url helper for #{action}" do
                  expect( get(send("#{path_helper}_url", @school)) ).
                      to route_to("school_profile_#{action}##{action}", state: state, city: city.sub('%23', '#'), schoolId: '1', school_name: 'Alameda-High-School' )
                end
              end
            end
          end
        end
      end
    end
  end
end