require 'spec_helper'

def configure_expectations(model_type, attrs)
  before do
    if :compare == model_type
      allow(model).to receive(:school_cache).and_return(SchoolCacheDecorator.new(model))
      allow_any_instance_of(SchoolCacheDecorator).to receive(:programs).and_return(programs_map(attrs))
    else
      attrs.each { |k,v| allow(model).to receive(k).and_return(v) }
    end
    model.calculate_fit_score!(params)
    model.sort_breakdown_by_match_status!
  end
end

# Transforms {a: [b]} to {a: {b: 1}}, which is how the programs info comes out of school_cache
def programs_map(hash)
  hash.inject({}) do |rval, (k,v)|
    rval[k.to_s] = [*v].inject({}) { |inner_hash, e| inner_hash[e.to_s] = 1; inner_hash }
    rval
  end
end

#visual_media_arts matches arts_visual=['painting']
def expect_matches_true(options)
  it "#{options[:filter_value]} if #{options[:model_key].to_s}=#{options[:model_value]}" do
    allow(model).to receive(options[:model_key]).and_return(options[:model_value])
    expect(model.send('matches_soft_filter?', options[:filter_key], options[:filter_value])).to eq(:yes)
  end
end

#visual_media_arts if arts_visual is ['none']
def expect_matches_false(options)
  it "#{options[:filter_value]} if #{options[:model_key].to_s} is #{options[:model_value]}" do
    allow(model).to receive(options[:model_key]).and_return(options[:model_value])
    expect(model.send('matches_soft_filter?', options[:filter_key], options[:filter_value])).to eq(:no)
  end
end

#vouchers if school.type is public/charter
def expect_matches_not_applicable(options)
  it "#{options[:filter_value]} if #{options[:model_key].to_s} is #{options[:model_value]} for school type #{options[:type]}" do
    allow(model).to receive(:type).and_return(options[:type])
    allow(model).to receive(options[:model_key]).and_return(options[:model_value])
    expect(model.send('matches_soft_filter?', options[:filter_key], options[:filter_value])).to eq(:not_applicable)
  end
end

#visual_media_arts if arts_visual is not defined
def expect_matches_nil(options)
  it "#{options[:filter_value]} if #{options[:model_key].to_s} is not defined" do
    expect(model.send('matches_soft_filter?', options[:filter_key], options[:filter_value])).to eq(:no_data)
  end
end

def expect_not_to_raise_error(options)
  it "#{options[:filter_value]}" do
    expect { model.send('matches_soft_filter?', options[:filter_key], options[:filter_value]) }.not_to raise_error
  end
end

def fit_score_model_assertions(options)
  it "sets max_fit to #{options[:max_fit]}" do
    expect(model.max_fit_score).to eq(options[:max_fit])
  end
  it "sets fit_score to #{options[:fit]}" do
    expect(model.fit_score).to eq(options[:fit])
  end
  if options[:breakdown].nil? || options[:breakdown].empty?
    it 'sets fit_score_breakdown to empty array' do
      expect(model.fit_score_breakdown).to be_empty
    end
  else
    it "populates a breakdown with #{options[:breakdown].size} #{(options[:breakdown].size) == 1 ? 'entry' : 'entries'}" do
      expect(model.fit_score_breakdown).not_to be_empty
      expect(model.fit_score_breakdown.size).to eq(options[:breakdown].size)
    end
    options[:breakdown].each_index do |x|
      expected_breakdown = options[:breakdown][x] # must be var for usage inside "it"
      describe "for breakdown #{x+1}" do
        let (:actual_breakdown) {model.fit_score_breakdown[x]}
        it "sets category to #{expected_breakdown[:category]}" do
          expect(actual_breakdown[:category]).to eq(expected_breakdown[:category])
        end
        it "sets filter to #{expected_breakdown[:filter]}" do
          expect(actual_breakdown[:filter]).to eq(expected_breakdown[:filter])
        end
        it "sets match_status to #{expected_breakdown[:match_status].to_s}" do
          expect(actual_breakdown[:match_status]).to eq(expected_breakdown[:match_status])
        end
      end
    end
  end
end

describe FitScoreConcerns do
  before(:all) do
    class FakeModel
      include FitScoreConcerns
    end
  end
  after(:all) { Object.send :remove_const, :FakeModel }
  let(:model) { FakeModel.new }

  describe '#calculate_fit_score!' do
    describe 'when no filters applied' do
      before do
        model.calculate_fit_score!({})
      end
      fit_score_model_assertions max_fit:0, fit:0
    end
    [:search, :compare].each do |model_type|
      describe "on a school in #{model_type}" do
        describe 'when vouchers are specified' do
          let (:params) {{'enrollment'=>'vouchers'}}
          describe 'it checks students_vouchers for private schools, matching on yes' do
            before {allow(model).to receive(:type).and_return 'private'}
            configure_expectations model_type, students_vouchers: 'yes'
            fit_score_model_assertions max_fit:1, fit:1,
              breakdown: [{category:'enrollment',filter:'vouchers',match_status: :yes}]
          end
          describe 'it checks students_vouchers for private schools, returning no for any value not yes' do
            before {allow(model).to receive(:type).and_return 'private'}
            configure_expectations model_type, students_vouchers: 'no'
            fit_score_model_assertions max_fit:1, fit:0,
              breakdown: [{category:'enrollment',filter:'vouchers',match_status: :no}]
          end
          describe 'it checks students_vouchers for private schools, returning no_data when not defined' do
            before {allow(model).to receive(:type).and_return 'private'}
            configure_expectations model_type, something_else: 'no'
            fit_score_model_assertions max_fit:1, fit:0,
              breakdown: [{category:'enrollment',filter:'vouchers',match_status: :no_data}]
          end
          describe 'it returns not_applicable for charter schools' do
            before {allow(model).to receive(:type).and_return 'charter'}
            configure_expectations model_type, students_vouchers: 'no'
            fit_score_model_assertions max_fit:1, fit:1,
              breakdown: [{category:'enrollment',filter:'vouchers',match_status: :not_applicable}]
          end
          describe 'it returns not_applicable for public schools' do
            before {allow(model).to receive(:type).and_return 'public'}
            configure_expectations model_type, students_vouchers: 'no'
            fit_score_model_assertions max_fit:1, fit:1,
              breakdown: [{category:'enrollment',filter:'vouchers',match_status: :not_applicable}]
          end
        end
        describe 'when basketball is specified' do
          let (:params) {{'boys_sports'=>'basketball'}}
          describe 'and it is there among others' do
            configure_expectations model_type, boys_sports: %w(baseball football basketball)
            fit_score_model_assertions max_fit:1, fit:1,
                breakdown: [{category:'boys_sports',filter:'basketball',match:true,match_status: :yes}]
          end
          describe 'and it is not there but other boys_sports are' do
            configure_expectations model_type, boys_sports: %w(baseball football)
            fit_score_model_assertions max_fit:1, fit:0,
                breakdown: [{category:'boys_sports',filter:'basketball',match:false,match_status: :no}]
          end
          describe 'and boys_sports is set to none' do
            configure_expectations model_type, boys_sports: %w(none)
            fit_score_model_assertions max_fit:1, fit:0,
                breakdown: [{category:'boys_sports',filter:'basketball',match:false,match_status: :no}]
          end
          describe 'and it is not there and boys_sports is empty' do
            configure_expectations model_type, boys_sports:[]
            fit_score_model_assertions max_fit:1, fit:0,
                breakdown: [{category:'boys_sports',filter:'basketball',match:false,match_status: :no_data}]
          end
          describe 'and it is not there and boys_sports is undefined' do
            configure_expectations model_type, {}
            fit_score_model_assertions max_fit:1, fit:0,
                breakdown: [{category:'boys_sports',filter:'basketball',match:false,match_status: :no_data}]
          end
        end
        describe 'when visual_media_arts is specified' do
          let (:params) {{'class_offerings'=>'visual_media_arts'}}
          {
              arts_visual: {arts_visual:%w(painting photography)},
              arts_media: {arts_media:%w(animation graphics)}
          }.each do |k,v|
            describe "it checks #{k.to_s}" do
              configure_expectations model_type, v
              fit_score_model_assertions max_fit:1, fit:1,
                  breakdown: [{category:'class_offerings',filter:'visual_media_arts',match:true,match_status: :yes}]
            end
          end
          [:arts_visual,:arts_media].each do |e|
            describe "it does not count none in #{e}" do
              configure_expectations model_type, e => 'none'
              fit_score_model_assertions max_fit:1, fit:0,
                  breakdown: [{category:'class_offerings',filter:'visual_media_arts',match:false,match_status: :no}]
            end
          end
          describe "it does not count none in both" do
            configure_expectations model_type, arts_visual: %w(none), arts_media: %w(none)
            fit_score_model_assertions max_fit:1, fit:0,
                breakdown: [{category:'class_offerings',filter:'visual_media_arts',match:false,match_status: :no}]
          end
          describe "it handles if arts_visual has none but arts_media is populated" do
            configure_expectations model_type, arts_visual: %w(none), arts_media: %w(animation graphics)
            fit_score_model_assertions max_fit:1, fit:1,
                breakdown: [{category:'class_offerings',filter:'visual_media_arts',match:true,match_status: :yes}]
          end
          describe 'it does not check arts_music' do
            configure_expectations model_type, arts_music: %w(band chorus)
            fit_score_model_assertions max_fit:1, fit:0,
                breakdown: [{category:'class_offerings',filter:'visual_media_arts',match:false,match_status: :no_data}]
          end
        end
        describe 'when career_tech and arts are specified' do
          let (:params) {{'school_focus'=> %w(career_tech arts)}}
          describe 'and both are there' do
            configure_expectations model_type, academic_focus: %w(vocational visual_arts)
            fit_score_model_assertions max_fit:2, fit:2,
                breakdown: [{category:'school_focus',filter:'arts',match:true,match_status: :yes},
                {category:'school_focus',filter:'career_tech',match:true,match_status: :yes}]
          end
          describe 'and only career_tech is there' do
            configure_expectations model_type, academic_focus: %w(vocational)
            fit_score_model_assertions max_fit:2, fit:1,
                breakdown: [{category:'school_focus',filter:'career_tech',match:true,match_status: :yes},
                {category:'school_focus',filter:'arts',match:false,match_status: :no}]
          end
          describe 'and only arts is there' do
            configure_expectations model_type, academic_focus: %w(visual_arts)
            fit_score_model_assertions max_fit:2, fit:1,
                breakdown: [{category:'school_focus',filter:'arts',match:true,match_status: :yes},
                {category:'school_focus',filter:'career_tech',match:false,match_status: :no}]
          end
          describe 'and academic_focus is none' do
            configure_expectations model_type, academic_focus: %w(none)
            fit_score_model_assertions max_fit:2, fit:0,
                breakdown: [{category:'school_focus',filter:'arts',match:false,match_status: :no},
                {category:'school_focus',filter:'career_tech',match:false,match_status: :no}]
          end
          describe 'and academic_focus has not been responded to' do
            configure_expectations(model_type, {})
            fit_score_model_assertions max_fit:2, fit:0,
                breakdown: [{category:'school_focus',filter:'arts',match:false,match_status: :no_data},
                {category:'school_focus',filter:'career_tech',match:false,match_status: :no_data}]
          end
        end
      end
    end
  end

  describe '#matches_soft_filter?' do
    describe 'returns :yes' do
      describe 'for class_offerings equals' do
        expect_matches_true filter_key:'class_offerings', filter_value:'visual_media_arts',
                            model_key: :arts_visual, model_value: %w(painting)
        expect_matches_true filter_key:'class_offerings', filter_value:'performance_arts',
                            model_key: :arts_performing_written, model_value: %w(drama)
        expect_matches_true filter_key:'class_offerings', filter_value:'music',
                            model_key: :arts_music, model_value: %w(band)
      end
      describe 'for school_focus equals' do
        %w(all_arts visual_arts performing_arts music).each do |var|
          expect_matches_true filter_key:'school_focus', filter_value:'arts',
                              model_key: :academic_focus, model_value: [var]
        end
        expect_matches_true filter_key:'school_focus', filter_value:'career_tech',
                            model_key: :academic_focus, model_value: ['vocational']
        %w(AP_courses ib college_prep).each do |var|
          expect_matches_true filter_key:'school_focus', filter_value:'college_focus',
                              model_key: :instructional_model, model_value: [var]
        end
        expect_matches_true filter_key:'school_focus', filter_value:'montessori',
                            model_key: :instructional_model, model_value: ['montessori']
        expect_matches_true filter_key:'school_focus', filter_value:'montessori',
                            model_key: :instructional_model, model_value: %w(AP_courses ib college_prep montessori)
        expect_matches_true filter_key:'school_focus', filter_value:'college_focus',
                            model_key: :instructional_model, model_value: %w(AP_courses ib college_prep montessori)
      end
      describe 'for boys_sports equals' do
        expect_matches_true filter_key:'boys_sports', filter_value:'basketball',
                            model_key: :boys_sports, model_value: %w(baseball football basketball)
        expect_matches_true filter_key:'boys_sports', filter_value:'basketball',
                            model_key: :boys_sports, model_value: %w(none basketball none)
      end
      describe 'for before_after_care equals' do
        expect_matches_true filter_key:'before_after_care', filter_value:'before',
                            model_key: :before_after_care, model_value: %w(before)
        expect_matches_true filter_key:'before_after_care', filter_value:'after',
                            model_key: :before_after_care, model_value: %w(after)
      end
      describe 'for enrollment equals' do
        before do
          allow(model).to receive(:type).and_return('private')
        end
        expect_matches_true filter_key:'enrollment', filter_value:'vouchers',
                            model_key: :students_vouchers, model_value: %w(yes)
      end
    end

    describe 'returns :no' do
      describe ' for class_offerings equals' do
        expect_matches_false filter_key:'class_offerings', filter_value:'visual_media_arts',
                             model_key: :arts_visual, model_value: ['none']
        expect_matches_false filter_key:'class_offerings', filter_value:'visual_media_arts',
                             model_key: :arts_visual, model_value: ['None']
        expect_matches_false filter_key:'class_offerings', filter_value:'performance_arts',
                             model_key: :arts_performing_written, model_value: ['none']
        expect_matches_false filter_key:'class_offerings', filter_value:'performance_arts',
                             model_key: :arts_performing_written, model_value: ['None']
        expect_matches_false filter_key:'class_offerings', filter_value:'music',
                             model_key: :arts_music, model_value: ['none']
        expect_matches_false filter_key:'class_offerings', filter_value:'music',
                             model_key: :arts_music, model_value: ['None']
      end
      describe 'for school_focus equals' do
        expect_matches_false filter_key:'school_focus', filter_value:'arts',
                             model_key: :academic_focus, model_value: ['none']
        expect_matches_false filter_key:'school_focus', filter_value:'arts',
                             model_key: :academic_focus, model_value: ['business']
        expect_matches_false filter_key:'school_focus', filter_value:'college_focus',
                             model_key: :instructional_model, model_value: ['none']
      end
      describe 'for boys_sports equals' do
        expect_matches_false filter_key:'boys_sports', filter_value:'basketball',
                             model_key: :boys_sports, model_value: ['none']
        expect_matches_false filter_key:'boys_sports', filter_value:'basketball',
                             model_key: :boys_sports, model_value: %w(baseball football)
      end
      describe 'for before_after_care equals' do
        expect_matches_false filter_key:'before_after_care', filter_value:'before',
                             model_key: :before_after_care, model_value: %w(after)
        expect_matches_false filter_key:'before_after_care', filter_value:'before',
                             model_key: :before_after_care, model_value: %w(neither)
        expect_matches_false filter_key:'before_after_care', filter_value:'after',
                             model_key: :before_after_care, model_value: %w(before)
        expect_matches_false filter_key:'before_after_care', filter_value:'after',
                             model_key: :before_after_care, model_value: %w(neither)
      end
      describe 'for enrollment equals' do
        before do
          allow(model).to receive(:type).and_return('private')
        end
        expect_matches_false filter_key:'enrollment', filter_value:'vouchers',
                             model_key: :students_vouchers, model_value: ['no']
      end
    end

    describe 'returns :no_data' do
      describe 'for class_offerings equals' do
        expect_matches_nil filter_key:'class_offerings', filter_value:'visual_media_arts', model_key: :arts_visual
        expect_matches_nil filter_key:'class_offerings', filter_value:'performance_arts', model_key: :arts_performing_written
        expect_matches_nil filter_key:'class_offerings', filter_value:'music', model_key: :arts_music
      end
      describe 'for school_focus equals' do
        expect_matches_nil filter_key:'school_focus', filter_value:'arts', model_key: :academic_focus
        expect_matches_nil filter_key:'school_focus', filter_value:'college_focus', model_key: :instructional_model
      end
      describe 'for boys_sports equals' do
        expect_matches_nil filter_key:'boys_sports', filter_value:'basketball', model_key: :boys_sports
      end
      describe 'for before_after_care equals' do
        expect_matches_nil filter_key:'before_after_care', filter_value:'before', model_key: :before_after_care
      end
      describe 'for enrollment equals' do
        before do
          allow(model).to receive(:type).and_return('private')
        end
        expect_matches_nil filter_key:'enrollment', filter_value:'vouchers', model_key: :students_vouchers
      end
    end

    describe 'returns :not_applicable' do
      describe 'for vouchers equals' do
        expect_matches_not_applicable filter_key:'enrollment', filter_value:'vouchers',
                                      model_key: :students_vouchers, model_value: %w(yes), type: 'public'
        expect_matches_not_applicable filter_key:'enrollment', filter_value:'vouchers',
                                      model_key: :students_vouchers, model_value: %w(yes), type: 'charter'
        expect_matches_not_applicable filter_key:'enrollment', filter_value:'vouchers',
                                      model_key: :students_vouchers, model_value: %w(no), type: 'public'
        expect_matches_not_applicable filter_key:'enrollment', filter_value:'vouchers',
                                      model_key: :students_vouchers, model_value: %w(no), type: 'charter'
      end
    end

    context 'properly escapes fit score values when there are regexp special characters and' do
      describe 'doesnt raise an error' do
        describe 'for class_offerings equals' do
          expect_not_to_raise_error filter_key:'class_offerings', filter_value:'visual_media_arts]', model_key: :arts_visual
          expect_not_to_raise_error filter_key:'class_offerings', filter_value:'performance_arts[]', model_key: :arts_performing_written
          expect_not_to_raise_error filter_key:'class_offerings', filter_value:'music[', model_key: :arts_music
        end
      end

      #matching values that have escaped values proves that regexp special characters are escaped
      describe 'returns true' do
        describe 'for class_offerings equals' do
          expect_matches_true filter_key:'arts_visual', filter_value:'visual_media_arts]',
                              model_key: :arts_visual, model_value: %w(visual_media_arts])
          expect_matches_true filter_key:'arts_visual', filter_value:'performance_arts[]',
                              model_key: :arts_visual, model_value: %w(performance_arts[])
          expect_matches_true filter_key:'arts_visual', filter_value:'music[',
                              model_key: :arts_visual, model_value: %w(music[)
          expect_matches_true filter_key:'arts_visual', filter_value:'/visual_media_arts/',
                              model_key: :arts_visual, model_value: %w(/visual_media_arts/)
          expect_matches_true filter_key:'arts_visual', filter_value:'performance_arts...',
                              model_key: :arts_visual, model_value: %w(performance_arts...)
          expect_matches_true filter_key:'arts_visual', filter_value:'^music?',
                              model_key: :arts_visual, model_value: %w(^music?)
          expect_matches_true filter_key:'arts_visual', filter_value:'{visual_media_arts}',
                              model_key: :arts_visual, model_value: %w({visual_media_arts})
          expect_matches_true filter_key:'arts_visual', filter_value:'performance_arts++',
                              model_key: :arts_visual, model_value: %w(performance_arts++)
          expect_matches_true filter_key:'arts_visual', filter_value:'mus|ic',
                              model_key: :arts_visual, model_value: %w(mus|ic)
        end
      end

      #returns nil in the normal case when they are not matched
      describe 'returns nil' do
        describe 'for class_offerings equals' do
          expect_matches_nil filter_key:'class_offerings', filter_value:'[visual_media_arts]', model_key: :arts_visual
          expect_matches_nil filter_key:'class_offerings', filter_value:'/performance_arts/', model_key: :arts_performing_written
          expect_matches_nil filter_key:'class_offerings', filter_value:'{music}', model_key: :arts_music
        end
        describe 'for school_focus equals' do
          expect_matches_nil filter_key:'school_focus', filter_value:'college_focus...', model_key: :instructional_model
        end
        describe 'for boys_sports equals' do
          expect_matches_nil filter_key:'boys_sports', filter_value:'^basketball?', model_key: :boys_sports
        end
        describe 'for before_after_care equals' do
          expect_matches_nil filter_key:'before_after_care', filter_value:'before++', model_key: :before_after_care
        end
      end
    end
  end
end
