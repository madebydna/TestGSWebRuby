require 'spec_helper'

def hash_to_query_string(hash)
  hash.present? ? ('?' + hash.sort.collect {|(k,v)| "#{k}=#{[*v].first}"}.join('&')) : ''
end

shared_examples_for 'by location with city meta tags' do
  before do
    controller.instance_variable_set(:@params_hash, local_config[:params].merge({'city' => local_config[:city_name]}))
  end
  [:canonical, :title].each do |key|
    it "Serves up the correct #{key}" do
      if local_config[key].nil?
        expect(controller.search_by_location_meta_tag_hash[key]).to be_nil
      else
        expect(controller.search_by_location_meta_tag_hash[key]).to eq(local_config[key])
      end
    end
  end
end

shared_examples_for 'by location with no city meta tags' do
  it 'Has rel canonical to state home' do
    expect(controller.search_by_location_meta_tag_hash[:canonical]).to eq(state_home_url)
  end
  it 'Has correct title' do
    expect(controller.search_by_location_meta_tag_hash[:title]).to eq("GreatSchools.org Search, #{page_range}")
  end
end

shared_examples_for 'by name with city meta tags' do
  before do
    controller.instance_variable_set(:@params_hash, local_config[:params].merge({'state' => state_short, 'q' => local_config[:q]}))
  end
  [:canonical, :title].each do |key|
    it "Serves up the correct #{key}" do
      if local_config[key].nil?
        expect(controller.search_by_name_meta_tag_hash[key]).to be_nil
      else
        expect(controller.search_by_name_meta_tag_hash[key]).to eq(local_config[key])
      end
    end
  end
end

shared_examples_for 'by name with no city meta tags' do
  it 'Has rel canonical to state home' do
    expect(controller.search_by_name_meta_tag_hash[:canonical]).to eq(state_home_url)
  end
  it 'Has correct title' do
    expect(controller.search_by_name_meta_tag_hash[:title]).to eq("GreatSchools.org Search: #{query}, #{page_range}")
  end
end

shared_examples_for 'search by name national meta tags' do
  it 'Has rel canonical to home page' do
    expect(controller.search_by_name_meta_tag_hash[:canonical]).to eq('http://localhost/')
  end
  it 'Has correct title' do
    expect(controller.search_by_name_meta_tag_hash[:title]).to eq("GreatSchools.org Search: #{query}, #{page_range}")
  end
end

def search_city_browse_meta_tag_hash_tests(context_config)
  before do
    controller.instance_variable_set(:@params_hash, params)
    allow(controller).to receive(:request).and_return(Struct.new(:url).new(url))
  end
  {
      canonical: context_config[:canonical],
      description: "View and map all #{context_config[:city_name]}, #{context_config[:state_long]} schools. Plus, compare or save schools",
      title: context_config[:title],
      prev: context_config[:prev_url],
      next: context_config[:next_url]
  }.each do |key, value|
    it "Serves up the correct #{key}" do
      expect(controller.search_city_browse_meta_tag_hash[key]).to (value.nil? ? be_nil : eq(value))
    end
  end
end

def search_district_browse_meta_tag_hash_tests(context_config)
  before do
    controller.instance_variable_set(:@params_hash, params)
    allow(controller).to receive(:request).and_return(Struct.new(:url).new(url))
  end
  {
      canonical: context_config[:canonical],
      description: "Ratings and parent reviews for all elementary, middle and high schools in the #{context_config[:district_name]}, #{context_config[:state_long]}",
      keywords: context_config[:keywords],
      title: context_config[:title],
      prev: context_config[:prev_url],
      next: context_config[:next_url]
  }.each do |key, value|
    it "Serves up the correct #{key}" do
      expect(controller.search_district_browse_meta_tag_hash[key]).to (value.nil? ? be_nil : eq(value))
    end
  end
end

describe SearchMetaTagsConcerns do
  before(:all) do
    class FakeController < ActionController::Base
      include SearchMetaTagsConcerns
    end
  end

  after(:all) { Object.send :remove_const, :FakeController }

  let(:controller) { FakeController.new }

  describe '#canonical_url_without_params' do
    let(:city_name) { 'Dover' }
    let(:state_name_long) { 'Delaware' }
    let(:city_with_space) { 'San Francisco' }

    before do
      expect(controller).to receive(:city_params).and_return state:'delaware', city:'dover'
    end

    it 'should cut off the lang parameter if present' do
      allow(controller).to receive(:search_city_browse_url).and_return('http://localhost/delaware/dover/schools/?lang=es')
      expect(controller.canonical_url_without_params(state_name_long, city_name)).to eq 'http://localhost/delaware/dover/schools/'
    end

    it 'should return base city browse url' do
      allow(controller).to receive(:search_city_browse_url).and_return('http://localhost/delaware/dover/schools/')
      expect(controller.canonical_url_without_params(state_name_long, city_name)).to eq 'http://localhost/delaware/dover/schools/'
    end
  end

  describe '#search_city_browse_meta_tag_hash' do
    state_long = 'New Jersey'
    let(:state_long) { state_long }
    let(:state_short) { 'NJ' }
    city_name = 'Jersey City'
    let(:city_name) { city_name }

    state_url = 'new-jersey'
    let(:state_url) { state_url}
    city_url = 'jersey-city'
    let(:city_url) { city_url}

    url_prefix = "http://localhost/#{state_url}/#{city_url}/schools/"
    let(:url_prefix) { url_prefix }

    before do
      controller.instance_variable_set(:@state, {long: state_long, short: state_short})
      controller.instance_variable_set(:@city, Struct.new(:name, :state).new(city_name, state_long))
      controller.instance_variable_set(:@max_number_of_pages, 5)
      controller.instance_variable_set(:@total_results, 120)
      controller.instance_variable_set(:@page_size, 25)
      controller.instance_variable_set(:@results_offset, 0)

      allow(controller).to receive(:city_params).and_return state: state_url, city: city_url
    end

    [
            {
                params: {},
                title: "#{city_name} Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            # JUST LEVEL
            {
                params: {'gradeLevels' => 'p'},
                title: "#{city_name} Preschools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'gradeLevels' => 'e'},
                title: "#{city_name} Elementary Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'gradeLevels' => 'm'},
                title: "#{city_name} Middle Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'gradeLevels' => 'h'},
                title: "#{city_name} High Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'gradeLevels' => ['e', 'm']},
                title: "#{city_name} Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            # JUST SCHOOL TYPE
            {
                params: {'st' => 'public'},
                title: "#{city_name} Public Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'st' => 'charter'},
                title: "#{city_name} Public Charter Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'st' => 'private'},
                title: "#{city_name} Private Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'st' => ['public', 'charter']},
                title: "#{city_name} Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            # BOTH LEVEL AND SCHOOL TYPE
            {
                params: {'st' => 'private', 'gradeLevels' => 'p'},
                title: "#{city_name} Private Preschools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'st' => 'charter', 'gradeLevels' => 'm'},
                title: "#{city_name} Public Charter Middle Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'st' => 'public', 'gradeLevels' => 'h'},
                title: "#{city_name} Public High Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
            {
                params: {'st' => ['public', 'charter'], 'gradeLevels' => ['m', 'h']},
                title: "#{city_name} Schools, 1-25 - #{city_name}, #{state_long} | GreatSchools"
            },
    ].each do |context_config|
      context_description = if context_config[:params].present?
                              context_config[:params].collect {|k,v| "#{k}=#{v}"}.join(' and ')
                            else
                              'no params'
                            end
      context "with #{context_description}" do
        context 'in Spanish' do
          params_base = context_config[:params].merge({'lang' => 'es'})
          let(:params_base) {params_base}

          before do
            @old_locale = I18n.locale
            I18n.locale = :es
            allow(controller).to receive(:search_city_browse_url).and_return(url_prefix + '?lang=es') # special case
          end
          after do
            I18n.locale = @old_locale
          end

          context 'on page 1' do
            url = url_prefix + hash_to_query_string(params_base)
            prev_url = nil
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            let(:url) { url }
            let(:params) {params_base}

            local_config = context_config.merge(
                {city_name: city_name, state_long: state_long,
                 next_url: next_url, prev_url: prev_url, canonical: url}
            )

            search_city_browse_meta_tag_hash_tests(local_config)
          end

          context 'on page 2' do
            before { controller.instance_variable_set(:@results_offset, 25) }

            url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            prev_url = url_prefix + hash_to_query_string(params_base)
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '3'}))
            let(:url) { url }
            let(:params) {params_base.merge({'page' => '2'})}


            local_config = context_config.merge(
                {city_name: city_name, state_long: state_long,
                 next_url: next_url, prev_url: prev_url, canonical: url}
            )
            local_config[:title] = local_config[:title].sub('1-25', '26-50')

            search_city_browse_meta_tag_hash_tests(local_config)
          end
        end

        context 'in English' do
          params_base = context_config[:params]
          let(:params_base) {params_base}

          before do
            allow(controller).to receive(:search_city_browse_url).and_return(url_prefix)
          end

          context 'on page 1' do
            url = url_prefix + hash_to_query_string(params_base)
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            prev_url = nil
            let(:url) { url }
            let(:params) {params_base}

            local_config = context_config.merge(
                {city_name: city_name, state_long: state_long,
                 next_url: next_url, prev_url: prev_url, canonical: url}
            )

            search_city_browse_meta_tag_hash_tests(local_config)
          end

          context 'on page 2' do
            before { controller.instance_variable_set(:@results_offset, 25) }

            url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            prev_url = url_prefix +  hash_to_query_string(params_base)
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '3'}))
            let(:url) { url }
            let(:params) {params_base.merge({'page' => '2'})}

            local_config = context_config.merge(
                {city_name: city_name, state_long: state_long,
                 next_url: next_url, prev_url: prev_url, canonical: url}
            )
            local_config[:title] = local_config[:title].sub('1-25', '26-50')

            search_city_browse_meta_tag_hash_tests(local_config)
          end
        end
      end
    end
  end

  describe '#search_district_browse_meta_tag_hash' do
    state_long = 'New Jersey'
    let(:state_long) { state_long }
    let(:state_short) { 'NJ' }
    city_name = 'Jersey City'
    let(:city_name) { city_name }
    district_name = 'Jersey City School District'
    let(:district_name) { district_name }

    state_url = 'new-jersey'
    let(:state_url) { state_url }
    city_url = 'jersey-city'
    let(:city_url) { city_url }
    district_url = 'jersey-city-school-district'
    let(:district_url) { district_url }

    url_prefix = "http://localhost/#{state_url}/#{city_url}/#{district_url}/schools/"
    let(:url_prefix) { url_prefix }

    before do
      controller.instance_variable_set(:@state, {long: state_long, short: state_short})
      controller.instance_variable_set(:@city, Struct.new(:name, :state).new(city_name, state_long))
      controller.instance_variable_set(:@district, Struct.new(:name).new(district_name))
      controller.instance_variable_set(:@max_number_of_pages, 5)
      controller.instance_variable_set(:@total_results, 120)
      controller.instance_variable_set(:@page_size, 25)
      controller.instance_variable_set(:@results_offset, 0)

      allow(controller).to receive(:city_params).and_return state: state_url, city: city_url
    end

    [
        {
            params: {},
            title: "Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        # JUST LEVEL
        {
            params: {'gradeLevels' => 'p'},
            title: "Preschools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'gradeLevels' => 'e'},
            title: "Elementary Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'gradeLevels' => 'm'},
            title: "Middle Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'gradeLevels' => 'h'},
            title: "High Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'gradeLevels' => ['e', 'm']},
            title: "Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        # JUST SCHOOL TYPE
        {
            params: {'st' => 'public'},
            title: "Public Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'st' => 'charter'},
            title: "Public Charter Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'st' => 'private'},
            title: "Private Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'st' => ['public', 'charter']},
            title: "Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        # BOTH LEVEL AND SCHOOL TYPE
        {
            params: {'st' => 'private', 'gradeLevels' => 'p'},
            title: "Private Preschools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'st' => 'charter', 'gradeLevels' => 'm'},
            title: "Public Charter Middle Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'st' => 'public', 'gradeLevels' => 'h'},
            title: "Public High Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
        {
            params: {'st' => ['public', 'charter'], 'gradeLevels' => ['m', 'h']},
            title: "Schools in #{district_name}, 1-25 - #{city_name}, #{state_long} | GreatSchools"
        },
    ].each do |context_config|
      context_description = if context_config[:params].present?
                              context_config[:params].collect {|k,v| "#{k}=#{v}"}.join(' and ')
                            else
                              'no params'
                            end
      context_config.merge!(
          {
              keywords: "#{district_name} Schools, #{city_name} School District, #{city_name} #{state_long} School District, School District #{city_name}, #{district_name} Public Schools, #{district_name} Charter Schools",
              city_name: city_name,
              state_long: state_long,
              district_name: district_name
          })
      context "with #{context_description}" do
        context 'in Spanish' do
          params_base = context_config[:params].merge({'lang' => 'es'})
          let(:params_base) {params_base}

          before do
            @old_locale = I18n.locale
            I18n.locale = :es
            allow(controller).to receive(:search_city_browse_url).and_return(url_prefix + '?lang=es') # special case
          end
          after do
            I18n.locale = @old_locale
          end

          context 'on page 1' do
            url = url_prefix + hash_to_query_string(params_base)
            prev_url = nil
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            let(:url) { url }
            let(:params) {params_base}

            local_config = context_config.merge({next_url: next_url, prev_url: prev_url, canonical: url})

            search_district_browse_meta_tag_hash_tests(local_config)
          end

          context 'on page 2' do
            before { controller.instance_variable_set(:@results_offset, 25) }

            url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            prev_url = url_prefix + hash_to_query_string(params_base)
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '3'}))
            let(:url) { url }
            let(:params) {params_base.merge({'page' => '2'})}


            local_config = context_config.merge({next_url: next_url, prev_url: prev_url, canonical: url})
            local_config[:title] = local_config[:title].sub('1-25', '26-50')

            search_district_browse_meta_tag_hash_tests(local_config)
          end
        end

        context 'in English' do
          params_base = context_config[:params]
          let(:params_base) {params_base}

          before do
            allow(controller).to receive(:search_city_browse_url).and_return(url_prefix)
          end

          context 'on page 1' do
            before do
            end

            url = url_prefix + hash_to_query_string(params_base)
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            prev_url = nil
            let(:url) { url }
            let(:params) {params_base}

            local_config = context_config.merge({next_url: next_url, prev_url: prev_url, canonical: url})

            search_district_browse_meta_tag_hash_tests(local_config)
          end

          context 'on page 2' do
            before { controller.instance_variable_set(:@results_offset, 25) }

            url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
            prev_url = url_prefix +  hash_to_query_string(params_base)
            next_url = url_prefix + hash_to_query_string(params_base.merge({'page' => '3'}))
            let(:url) { url }
            let(:params) {params_base.merge({'page' => '2'})}

            local_config = context_config.merge({next_url: next_url, prev_url: prev_url, canonical: url})
            local_config[:title] = local_config[:title].sub('1-25', '26-50')

            search_district_browse_meta_tag_hash_tests(local_config)
          end
        end
      end
    end
  end

  describe '#search_by_location_meta_tag_hash' do
    state_long = 'New Jersey'
    let(:state_long) { state_long }
    let(:state_short) { 'NJ' }
    city_name = 'Jersey City'
    let(:city_name) { city_name }

    state_url = 'new-jersey'
    let(:state_url) { state_url}
    let(:state_home_url) { "http://localhost/#{state_url}/"}
    city_url = 'jersey-city'
    let(:city_url) { city_url }

    before do
      controller.instance_variable_set(:@state, {long: state_long, short: state_short})
      controller.instance_variable_set(:@max_number_of_pages, 5)
      controller.instance_variable_set(:@total_results, 120)
      controller.instance_variable_set(:@page_size, 25)
      controller.instance_variable_set(:@results_offset, 0)
    end

    context 'with a city' do
      url_prefix = "http://localhost/#{state_url}/#{city_url}/schools/"
      let(:url_prefix) { url_prefix }

      before do
        controller.instance_variable_set(:@city, Struct.new(:name, :state).new(city_name, state_long))
        allow(controller).to receive(:city_params).and_return state: state_url, city: city_url
        allow(controller).to receive(:state_params).and_return state: state_url
        FactoryGirl.create(:jersey_city)
      end

      after do
        clean_dbs :us_geo
      end

      [
          {params: {}},
          {params: {'gradeLevels' => 'p'}},
          {params: {'gradeLevels' => 'e'}},
          {params: {'gradeLevels' => 'm'}},
          {params: {'gradeLevels' => 'h'}},
          {params: {'gradeLevels' => ['m', 'h']}},
          {params: {'st' => 'public'}},
          {params: {'st' => 'charter'}},
          {params: {'st' => 'private'}},
          {params: {'st' => ['public', 'charter']}},
          {params: {'gradeLevels' => 'p', 'st' => 'private'}},
          {params: {'gradeLevels' => ['e', 'm'], 'st' => ['public', 'charter']}},
      ].each do |context_config|
        context_description = if context_config[:params].present?
                                context_config[:params].collect {|k,v| "#{k}=#{v}"}.join(' and ')
                              else
                                'no params'
                              end
        context_config.merge!(
            {
                city_name: city_name,
                state_long: state_long,
                title: 'GreatSchools.org Search, 1-25'
            })
        context "with #{context_description}" do
          context 'in Spanish' do
            params_base = context_config[:params].merge({'lang' => 'es'})
            before do
              @old_locale = I18n.locale || :en
              I18n.locale = :es
              allow(controller).to receive(:search_city_browse_url).and_return(url_prefix + '?lang=es') # special case
            end
            after do
              I18n.locale = @old_locale
            end

            context 'on page 1' do
              url = url_prefix + hash_to_query_string(params_base)
              local_config = context_config.merge({canonical: url, params: params_base})
              it_behaves_like 'by location with city meta tags' do
                let(:local_config) {local_config}
              end
            end

            context 'on page 2' do
              before {controller.instance_variable_set(:@results_offset, 25)}

              url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
              local_config = context_config.merge({canonical: url, params: params_base.merge({'page' => '2'})})
              local_config[:title] = local_config[:title].sub('1-25', '26-50')
              it_behaves_like 'by location with city meta tags' do
                let(:local_config) {local_config}
              end
            end
          end

          context 'in English' do
            before { allow(controller).to receive(:search_city_browse_url).and_return(url_prefix) }

            params_base = context_config[:params]

            context 'on page 1' do
              url = url_prefix + hash_to_query_string(params_base)
              local_config = context_config.merge({canonical: url, params: params_base})
              it_behaves_like 'by location with city meta tags' do
                let(:local_config) {local_config}
              end
            end

            context 'on page 2' do
              before {controller.instance_variable_set(:@results_offset, 25)}

              url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
              local_config = context_config.merge({canonical: url, params: params_base.merge({'page' => '2'})})
              local_config[:title] = local_config[:title].sub('1-25', '26-50')
              it_behaves_like 'by location with city meta tags' do
                let(:local_config) {local_config}
              end
            end
          end
        end
      end
    end

    context 'without a city' do
      let(:page_range) {'1-25'}

      before do
        controller.instance_variable_set(:@params_hash, {})
        allow(controller).to receive(:state_params).and_return state: state_url
        allow(controller).to receive(:state_url).and_return state_home_url
      end

      context 'on page 1' do
        it_should_behave_like 'by location with no city meta tags'
      end

      context 'on page 2' do
        it_should_behave_like 'by location with no city meta tags' do
          before { controller.instance_variable_set(:@results_offset, 25) }
          let(:page_range) {'26-50'}
        end
      end
    end
  end

  describe '#search_by_name_meta_tag_hash' do
    before do
      controller.instance_variable_set(:@max_number_of_pages, 5)
      controller.instance_variable_set(:@total_results, 120)
      controller.instance_variable_set(:@page_size, 25)
      controller.instance_variable_set(:@results_offset, 0)
    end

    context 'with a state' do
      state_long = 'New Jersey'
      let(:state_long) { state_long }
      let(:state_short) { 'NJ' }
      state_url = 'new-jersey'
      let(:state_url) { state_url}
      let(:state_home_url) { "http://localhost/#{state_url}/"}
      before do
        controller.instance_variable_set(:@state, {long: state_long, short: state_short})
        allow(controller).to receive(:state_params).and_return state: state_url
        allow(controller).to receive(:state_abbreviation).and_return state_short
      end

      context 'with a city' do
        city_name = 'Jersey City'
        let(:city_name) { city_name }
        city_url = 'jersey-city'
        let(:city_url) { city_url }
        url_prefix = "http://localhost/#{state_url}/#{city_url}/schools/"
        let(:url_prefix) { url_prefix }

        before do
          controller.instance_variable_set(:@q, city_name)
          allow(controller).to receive(:city_params).and_return state: state_url, city: city_url
          FactoryGirl.create(:jersey_city)
        end

        after do
          clean_dbs :us_geo
        end

        [
            {params: {}},
            {params: {'gradeLevels' => 'p'}},
            {params: {'gradeLevels' => 'e'}},
            {params: {'gradeLevels' => 'm'}},
            {params: {'gradeLevels' => 'h'}},
            {params: {'gradeLevels' => ['m', 'h']}},
            {params: {'st' => 'public'}},
            {params: {'st' => 'charter'}},
            {params: {'st' => 'private'}},
            {params: {'st' => ['public', 'charter']}},
            {params: {'gradeLevels' => 'p', 'st' => 'private'}},
            {params: {'gradeLevels' => ['e', 'm'], 'st' => ['public', 'charter']}},
        ].each do |context_config|
          context_description = if context_config[:params].present?
                                  context_config[:params].collect {|k,v| "#{k}=#{v}"}.join(' and ')
                                else
                                  'no params'
                                end
          context_config.merge!(
              {
                  q: city_name,
                  state_long: state_long,
                  title: "GreatSchools.org Search: #{city_name}, 1-25",
              })
          context "with #{context_description}" do
            context 'in Spanish' do
              params_base = context_config[:params].merge({'lang' => 'es'})
              before do
                @old_locale = I18n.locale || :en
                I18n.locale = :es
                allow(controller).to receive(:search_city_browse_url).and_return(url_prefix + '?lang=es') # special case
              end
              after do
                I18n.locale = @old_locale
              end

              context 'on page 1' do
                url = url_prefix + hash_to_query_string(params_base)
                local_config = context_config.merge({canonical: url, params: params_base})
                it_behaves_like 'by name with city meta tags' do
                  let(:local_config) {local_config}
                end
              end

              context 'on page 2' do
                before {controller.instance_variable_set(:@results_offset, 25)}

                url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
                local_config = context_config.merge({canonical: url, params: params_base.merge({'page' => '2'})})
                local_config[:title] = local_config[:title].sub('1-25', '26-50')
                it_behaves_like 'by name with city meta tags' do
                  let(:local_config) {local_config}
                end
              end
            end

            context 'in English' do
              before { allow(controller).to receive(:search_city_browse_url).and_return(url_prefix) }

              params_base = context_config[:params]

              context 'on page 1' do
                url = url_prefix + hash_to_query_string(params_base)
                local_config = context_config.merge({canonical: url, params: params_base})
                it_behaves_like 'by name with city meta tags' do
                  let(:local_config) {local_config}
                end
              end

              context 'on page 2' do
                before {controller.instance_variable_set(:@results_offset, 25)}

                url = url_prefix + hash_to_query_string(params_base.merge({'page' => '2'}))
                local_config = context_config.merge({canonical: url, params: params_base.merge({'page' => '2'})})
                local_config[:title] = local_config[:title].sub('1-25', '26-50')
                it_behaves_like 'by name with city meta tags' do
                  let(:local_config) {local_config}
                end
              end
            end
          end
        end
      end

      context 'without a city' do
        let(:page_range) {'1-25'}
        let(:query) {'My High School'}

        before do
          controller.instance_variable_set(:@params_hash, {'state' => state_short, 'q' => 'My High School'})
          allow(controller).to receive(:state_params).and_return state: state_url
          allow(controller).to receive(:state_url).and_return state_home_url
        end

        context 'on page 1' do
          it_should_behave_like 'by name with no city meta tags'
        end

        context 'on page 2' do
          it_should_behave_like 'by name with no city meta tags' do
            before { controller.instance_variable_set(:@results_offset, 25) }
            let(:page_range) {'26-50'}
          end
        end
      end
    end

    context 'without a state' do
      let(:page_range) {'1-25'}
      let(:query) {'My High School'}

      before do
        controller.instance_variable_set(:@params_hash, {'q' => 'My High School'})
        allow(controller).to receive(:state_abbreviation).and_return nil
        allow(controller).to receive(:home_url).and_return 'http://localhost/'
      end

      context 'on page 1' do
        it_should_behave_like 'search by name national meta tags'
      end

      context 'on page 2' do
        it_should_behave_like 'search by name national meta tags' do
          before { controller.instance_variable_set(:@results_offset, 25) }
          let(:page_range) {'26-50'}
        end
      end
    end
  end
end