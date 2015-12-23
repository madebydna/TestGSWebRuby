shared_examples 'page with top rated schools section' do

  describe 'Top rated schools' do
    before do
      CityHomePageFactory.new.create_top_rated_schools('MN', 'St. Paul')
      visit city_path('minnesota', 'st.-paul')
    end
    after { clean_dbs :gs_schooldb, :ca, :mn }
    it { is_expected.to have_top_rated_schools_section }
    with_subject :top_rated_schools_section do
      its('heading.text') { is_expected.to include('St. Paul') }
      its('top_rated_schools.size') { is_expected.to eq(4) }
      its('first_top_rated_school.rating.text') { is_expected.to eq('10') }
      it { is_expected.to have_top_rated_schools }
      its('first_top_rated_school.href') { is_expected.to match(/minnesota\/st\.-paul\/\d+-Nearby-School-\d/) }
    end
  end

end