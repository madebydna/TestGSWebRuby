require 'spec_helper'

describe UrlHelper do
  let(:url_helper) { Object.new.extend UrlHelper }
  let(:helper) { url_helper }

  describe '.add_query_params_to_url' do
    let(:url) { 'http://test.com/'}
    let(:params) { {} }
    let(:result) { url_helper.send :add_query_params_to_url, url, true, params }

    it 'should return same value if no params provided' do
      expect(result).to eq url
    end

    it 'should correctly add a single param' do
      params[:cool] = true
      expect(result).to eq 'http://test.com/?cool=true'
    end

    it 'should correctly add two params' do
      params[:one] = 1
      params[:two] = 2
      expect(result).to eq 'http://test.com/?one=1&two=2'
    end

    it 'should overwrite an existing param' do
      url = 'http://test.com/?school_id=1&state=ca'
      params[:state] = 'dc'
      result = url_helper.send :add_query_params_to_url, url, true, params
      expect(result).to eq 'http://test.com/?school_id=1&state=dc'
    end

    it 'should append params when overwrite is false' do
      url = 'http://test.com/?school_id=1&state=ca'
      params[:state] = 'dc'
      result = url_helper.send :add_query_params_to_url, url, false, params
      expect(result).to eq 'http://test.com/?school_id=1&state[]=ca&state[]=dc'
    end

    it 'should correctly set params that are already an array' do
      url = 'http://test.com/?filters[]=one&filters[]=two'
      params[:filters] = 'three'
      result = url_helper.send :add_query_params_to_url, url, false, params
      expect(result).to eq url =
        'http://test.com/?filters[]=one&filters[]=two&filters[]=three'
    end

    it 'should correctly create an array when merging params' do
      url = 'http://test.com/?filters=one'
      params[:filters] = 'two'
      result = url_helper.send :add_query_params_to_url, url, false, params
      expect(result).to eq url = 'http://test.com/?filters[]=one&filters[]=two'
    end

  end

  describe '.remove_query_params_from_url' do
    let(:url) { 'http://test.com/'}
    let(:value) { nil }
    let(:param_names) { [] }
    let(:result) { url_helper.send :remove_query_params_from_url,
                                    url,
                                    param_names,
                                    nil
    }

    it 'should return same value if no params provided' do
      expect(result).to eq url
    end

    it 'should remove a single param' do
      url.replace 'http://test.com/?cool=false'
      param_names << :cool
      expect(result).to eq 'http://test.com/'
    end

    it 'should remove two params' do
      url.replace 'http://test.com/?one=1&two=2'
      param_names << :one << :two
      expect(result).to eq 'http://test.com/'
    end

    it 'should remove a param that is an array' do
      url.replace 'http://test.com/?filters[]=one&filters[]=two'
      param_names << :filters
      expect(result).to eq 'http://test.com/'
    end

    it 'should remove a single param from array if value provided' do
      url.replace 'http://test.com/?filters[]=one&filters[]=two'
      value = 'two'
      param_names << :filters
      result = url_helper.send :remove_query_params_from_url,
                                url,
                                param_names,
                                value
      expect(result).to eq 'http://test.com/?filters[]=one'
    end

    it 'should remove a param if value provided' do
      url.replace 'http://test.com/?state=ca'
      value = 'ca'
      param_names << :state
      result = url_helper.send :remove_query_params_from_url,
                                url,
                                param_names,
                                value
      expect(result).to eq 'http://test.com/'
    end

    it 'should not remove param from array if value does not match' do
      url.replace 'http://test.com/?filters[]=one&filters[]=two'
      value = 'blah'
      param_names << :filters
      result = url_helper.send :remove_query_params_from_url,
                                url,
                                param_names,
                                value
      expect(result).to eq 'http://test.com/?filters[]=one&filters[]=two'
    end
  end

  describe '#prepend_http' do
    let(:url) { 'www.test.com'}
    it 'should add http:// to the url when http and/or https do not already exist' do
      result = url_helper.send :prepend_http, url
      expect(result).to eq 'http://www.test.com'
    end
    it 'should not add it to the url when https exists' do
      url.replace  'https://www.test.com'
      result = url_helper.send :prepend_http, url
      expect(result).to eq 'https://www.test.com'
    end
    it 'should not add it to the url when http exists' do
      url.replace 'http://www.test.com'
      result = url_helper.send :prepend_http, url
      expect(result).to eq 'http://www.test.com'
    end
  end

  describe '#gs_legacy_url_encode' do
    it 'should replace hyphens with underscores' do
      expect(url_helper.send :gs_legacy_url_encode, '-paramname').to eq '_paramname'
      expect(url_helper.send :gs_legacy_url_encode, '-paramname-').to eq '_paramname_'
    end

    it 'should replace spaces with hyphens' do
      expect(url_helper.send :gs_legacy_url_encode, ' paramname').to eq '-paramname'
      expect(url_helper.send :gs_legacy_url_encode, ' param name ').to eq '-param-name-'
    end

    it 'should not replace periods' do
      # PT-1347 We removed the period substitution to handle city and district names with periods in them.
      expect(url_helper.send :gs_legacy_url_encode, '.paramname').to eq '.paramname'
      expect(url_helper.send :gs_legacy_url_encode, '.param.name').to eq '.param.name'
    end

    it 'should return nil if provided nil' do
      expect(url_helper.send :gs_legacy_url_encode, nil).to be_nil
    end
  end

  describe '.parse_array_query_string' do
    it 'should put duplicate params into array' do
      result = url_helper.send :parse_array_query_string, 'a=b&a=c&f=g'
      expect(result).to include('a','f')
      expect(result['a']).not_to be_empty
      expect(result['a']).to be_instance_of(Array)
      expect(result['a']).to include('b', 'c')
      expect(result['f']).to eq('g')
    end
    it 'should put duplicate params into array dropping square brackets' do
      result = url_helper.send :parse_array_query_string, 'a[]=b&a[]=c&f=g'
      expect(result).to include('a','f')
      expect(result['a']).not_to be_empty
      expect(result['a']).to be_instance_of(Array)
      expect(result['a']).to include('b', 'c')
      expect(result['f']).to eq('g')
    end
    it 'should put duplicate params into array dropping encoded square brackets' do
      result = url_helper.send :parse_array_query_string, 'a%5B%5D=b&a%5B%5D=c&f=g'
      expect(result).to include('a','f')
      expect(result['a']).not_to be_empty
      expect(result['a']).to be_instance_of(Array)
      expect(result['a']).to include('b', 'c')
      expect(result['f']).to eq('g')
    end
    it 'should allow encoded square brackets as values' do
      result = url_helper.send :parse_array_query_string, 'a%5B%5D=%5B%5D%3Db&a%5B%5D=c&f=g'
      expect(result).to include('a','f')
      expect(result['a']).not_to be_empty
      expect(result['a']).to be_instance_of(Array)
      expect(result['a']).to include('[]=b', 'c')
      expect(result['f']).to eq('g')
    end
    it 'should put put single params into strings' do
      result = url_helper.send :parse_array_query_string, 'a=b&c=5'
      expect(result).to include('a','c')
      expect(result['a']).to eq('b')
      expect(result['c']).to eq('5')
    end
    it 'should handle url encoding correctly' do
      result = url_helper.send :parse_array_query_string, 'q=%25+a%20b+%2525c+%5B%5D%3D+%26foo%3Dbar'
      expect(result['q']).to eq('% a b %25c []= &foo=bar')
    end
  end

  describe '#encode_school_name' do
    it 'should transliterate the input' do
      input = "Ca\u00F1ada"
      expect(url_helper.send(:encode_school_name, input)).to eq('Canada')
    end

    {
      ' ' => '-',
      '/' => '-',
      '#' => '',
      '`' => '',
      '[' => ''   # Character [ will get url-encoded, and then removed
    }.each_pair do |match, replacement|
      it "should replace '#{match}' with '#{replacement}'" do
        input = "Foo#{match}Bar"
        expect(url_helper.send(:encode_school_name, input)).
          to eq("Foo#{replacement}Bar")
      end
    end

    it "should capitalize each word of the input" do
      input = "la canada"
      expect(url_helper.send(:encode_school_name, input)).to eq('La-Canada')
    end

    it 'should remove transliterated accent marks' do
      input = "N\u00E0auao"
      expect(url_helper.send(:encode_school_name, input)).
        to eq('Naauao')
    end
  end
  describe '#school_hash_to_url_for_profile' do
    context "when hash with a school's id, name, state abbreviation, and city" do
      context 'with a lang param set' do
        let(:params) { {lang: 'es'} }
        before do
          allow(url_helper).to receive(:params).and_return(params) 
        end
        it "should return a url to a school profile with lang param" do
          input = {"id"=>213, "name"=>"Bret Harte Middle School", "city"=>"Oakland", "state"=>"CA"}
          expect(url_helper.send(:school_hash_to_url_for_profile, input)).
            to eq('/california/oakland/213-Bret-Harte-Middle-School/?lang=es')
        end
        context "when hash missing one of the school hash attributes" do
          it "should return nil" do
            input = {"id"=>213, "name"=>"Bret Harte Middle School", "state"=>"CA"}
            expect(url_helper.send(:school_hash_to_url_for_profile, input)).
                to eq(nil)
          end
        end
      end
      context 'without a lang param set' do
        let(:params) { {} }
        before do
          allow(url_helper).to receive(:params).and_return(params) 
        end
        it "should return a url to a school profile without lang param" do
          input = {"id"=>213, "name"=>"Bret Harte Middle School", "city"=>"Oakland", "state"=>"CA"}
          expect(url_helper.send(:school_hash_to_url_for_profile, input)).
            to eq('/california/oakland/213-Bret-Harte-Middle-School/')
        end
        context "when hash missing one of the school hash attributes" do
          it "should return nil" do
            input = {"id"=>213, "name"=>"Bret Harte Middle School", "state"=>"CA"}
            expect(url_helper.send(:school_hash_to_url_for_profile, input)).
                to eq(nil)
          end
        end
      end
    end
  end
  describe '#catalog_path' do
    ['path', 'path/'].each do |env_path|
      ['path', '/path'].each do |var_path|
        it "should handle env path #{env_path} and var path #{var_path}" do
          ENV_GLOBAL['catalog_server'] = env_path
          expect(url_helper.catalog_path(var_path)).to eq 'path/path'
        end
      end
    end
  end

  describe '#create_reset_password_url' do
    # Ran out of time trying to make this more elegant
    let(:fake_controller) do
      Class.new do
        def url_options
          {
            host: 'localhost',
            trailing_slash: false
          }
        end
      end.send(:include, UrlHelper).send(:include, Rails.application.routes.url_helpers)
    end
    let(:url_helper) do
      fake_controller.new
    end

    let(:user) { FactoryBot.build(:new_user) }
    let(:parsed_url) { URI.parse(url_helper.create_reset_password_url(user)) }
    subject { parsed_url }

    describe 'params' do
      subject { Rack::Utils.parse_nested_query(parsed_url.query) }
      it 'should generate a URL with correct s_cid param' do
        expect(subject['s_cid']).to eq('eml_passwordreset')
      end
      it 'should add the appropriate token to the url' do
        hash, date = EmailVerificationToken.token_and_date(user)
        expect(subject['id']).to eq(CGI.escape(hash))
      end
      it 'should add the appropriate date to the url' do
        hash, date = EmailVerificationToken.token_and_date(user)
        expect(subject['date']).to eq(date)
      end
      context 'with a caller-specified s_cid' do
        let(:parsed_url) { URI.parse(url_helper.create_reset_password_url(user, s_cid: 'baz')) }
        subject { Rack::Utils.parse_query(parsed_url.query) }
        it 'should use the overridden s_cid param' do
          expect(subject['s_cid']).to eq('baz')
        end
      end
    end

    its(:path) { is_expected.to eq('/gsr/authenticate-token') }
  end

  shared_examples_for 'produces a correct zillow campaign code' do
    {
        unknown: 'gstrackingpagefail'
    }.each do |action, default_campaign|
      it "should use #{default_campaign} for #{action} action" do
        allow(helper).to receive(:action_name).and_return(action.to_s)
        expect(subject).to eq("#{expected_url}#{default_campaign}")
      end
    end

    describe 'with a campaign parameter' do
      let (:campaign) { 'spec' }
      subject { helper.zillow_url(state, zipcode, campaign) }

      it 'should use provided campaign parameter regardless of action' do
        allow(helper).to receive(:action_name).and_return('show')
        expect(subject).to eq("#{expected_url}#{campaign}")
      end
    end
  end

  describe '#zillow_url' do
    subject { helper.zillow_url(state, zipcode) }
    let(:state) { 'ca' }
    let(:zipcode) { '94611-1234' }

    describe 'without a state' do
      it_behaves_like 'produces a correct zillow campaign code' do
        let (:state) { nil }
        let (:expected_url) { 'https://www.zillow.com/?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=' }
      end
    end

    describe 'without a zip' do
      it_behaves_like 'produces a correct zillow campaign code' do
        let (:zipcode) { nil }
        let (:expected_url) { 'https://www.zillow.com/?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=' }
      end
    end

    describe 'with a state and zip' do
      it_behaves_like 'produces a correct zillow campaign code' do
        let (:expected_url) { 'https://www.zillow.com/CA-94611?cbpartner=Great+Schools&utm_source=GreatSchools&utm_medium=referral&utm_campaign=' }
      end
    end
  end

  describe '#email_send_link_no_admin' do
    subject { helper.email_send_link_no_admin(url) }

    context 'when provided admin within reset password url' do
      let(:url) {'https://admin.greatschools.org/gsr/authenticate-token/?date=983839&id=kasjdfkajsfkal&redirect=https%3A%2F%2Fadmin.greatschools.org%2Faccount%2Fpassword%2F&s_cid=eml_passwordreset'}
      let(:expected_url) {'https://www.greatschools.org/gsr/authenticate-token/?date=983839&id=kasjdfkajsfkal&redirect=https%3A%2F%2Fwww.greatschools.org%2Faccount%2Fpassword%2F&s_cid=eml_passwordreset'}
      it 'should see admin changed to www' do
        expect(subject).to eq(expected_url)
      end
    end

    context 'when provided admin within osp url' do
      let(:url) {'https://admin.greatschools.org/school/esp/form.page?page=1&schoolId=2244&state=ca'}
      let(:expected_url) {'https://www.greatschools.org/school/esp/form.page?page=1&schoolId=2244&state=ca'}
      it 'should see admin changed to www' do
        expect(subject).to eq(expected_url)
      end
    end

    context 'when provided admin in url only should change one' do
      let(:url) {'https://admin.greatschools.org/school/esp/form.page?page=1&schoolId=2244&state=caadmin'}
      let(:expected_url) {'https://www.greatschools.org/school/esp/form.page?page=1&schoolId=2244&state=caadmin'}
      it 'should see admin changed to www when part of url' do
        expect(subject).to eq(expected_url)
      end
    end

    context 'when provided sw3 within reset password url should not change' do
      let(:url) {'https://sw3.greatschools.org/gsr/authenticate-token/?date=983839&id=kasjdfkajsfkal&redirect=https%3A%2F%2Fsw3.greatschools.org%2Faccount%2Fpassword%2F&s_cid=eml_passwordreset'}
      it 'should see no change' do
        expect(subject).to eq(url)
      end
    end

    context 'when provided sw3 in url for osp url' do
      let(:url) {'http://sw3.greatschools.org/school/esp/form.page?page=1&schoolId=2244&state=ca'}
      it 'should see no change' do
        expect(subject).to eq(url)
      end
    end

  end

end
