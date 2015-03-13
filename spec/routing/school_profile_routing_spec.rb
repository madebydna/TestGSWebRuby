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

  it 'ruby should route to new district home page' do
    expect( get '/california/alameda/Alameda-High-School/' ).to route_to(
      'districts#show',
      state: 'california',
      city: 'alameda',
      district: 'Alameda-High-School'
    )
  end

  it 'should route to the school when the city has a period in it' do
    expect( get '/minnesota/st.-paul/3692-St-Paul-Conservatory-Performing-Art/' ).to route_to(
      'school_profile_overview#overview',
      state: 'minnesota',
      city: 'st.-paul',
      schoolId: '3692',
      school_name: 'St-Paul-Conservatory-Performing-Art'
    )
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

    it 'has a route for overview' do
      expect( get '/california/alameda/1-Alameda-High-School/' ).
          to route_to('school_profile_overview#overview', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for overview' do
      expect( get school_path(@school) ).
          to route_to('school_profile_overview#overview', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )

      expect( get school_url(@school) ).
          to route_to('school_profile_overview#overview', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for  reviews' do
      expect( get '/california/alameda/1-Alameda-High-School/reviews/' ).
          to route_to('school_profile_reviews#reviews', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for reviews' do
      expect( get school_reviews_path(@school) ).
          to route_to('school_profile_reviews#reviews', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_reviews_url(@school) ).
          to route_to('school_profile_reviews#reviews', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for details' do
      expect( get '/california/alameda/1-Alameda-High-School/details/' ).
          to route_to('school_profile_details#details', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for details' do
      expect( get school_details_path(@school) ).
          to route_to('school_profile_details#details', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_details_url(@school) ).
          to route_to('school_profile_details#details', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for quality' do
      expect( get '/california/alameda/1-Alameda-High-School/quality/' ).
          to route_to('school_profile_quality#quality', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for quality' do
      expect( get school_quality_path(@school) ).
          to route_to('school_profile_quality#quality', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_quality_url(@school) ).
          to route_to('school_profile_quality#quality', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for write a review' do
      expect( get '/california/alameda/1-Alameda-High-School/reviews/write/' ).
          to route_to('reviews#new', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for write a review' do
      expect( get school_review_form_path(@school) ).
          to route_to('reviews#new', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_review_form_url(@school) ).
          to route_to('reviews#new', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

  end



  describe 'pk school scope' do

    before do
      @school = FactoryGirl.build(:school, state: 'ca', city: 'alameda', id: 1, name: 'alameda high school', level_code: 'p')
      expect( @school).to be_preschool
    end

    it 'has a route for overview' do
      expect( get '/california/alameda/preschools/Alameda-High-School/1/' ).
          to route_to('school_profile_overview#overview', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for overview' do
      expect( get school_path(@school) ).
          to route_to('school_profile_overview#overview', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )

      expect( get school_url(@school) ).
          to route_to('school_profile_overview#overview', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for reviews' do
      expect( get '/california/alameda/preschools/Alameda-High-School/1/reviews/' ).
          to route_to('school_profile_reviews#reviews', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for reviews' do
      expect( get school_reviews_path(@school) ).
          to route_to('school_profile_reviews#reviews', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_reviews_url(@school) ).
          to route_to('school_profile_reviews#reviews', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for details' do
      expect( get '/california/alameda/preschools/Alameda-High-School/1/details/' ).
          to route_to('school_profile_details#details', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for details' do
      expect( get school_details_path(@school) ).
          to route_to('school_profile_details#details', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_details_url(@school) ).
          to route_to('school_profile_details#details', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for quality' do
      expect( get '/california/alameda/preschools/Alameda-High-School/1/quality/' ).
          to route_to('school_profile_quality#quality', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for quality' do
      expect( get school_quality_path(@school) ).
          to route_to('school_profile_quality#quality', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_quality_url(@school) ).
          to route_to('school_profile_quality#quality', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end


    it 'has a route for write a review' do
      expect( get '/california/alameda/preschools/Alameda-High-School/1/reviews/write/' ).
          to route_to('reviews#new', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

    it 'has a url helper for write a review' do
      expect( get school_review_form_path(@school) ).
          to route_to('reviews#new', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
      expect( get school_review_form_url(@school) ).
          to route_to('reviews#new', state: 'california', city: 'alameda', schoolId: '1', school_name: 'Alameda-High-School' )
    end

  end


end
