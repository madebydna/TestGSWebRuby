shared_examples 'page with top rated schools section' do
  it { is_expected.to have_top_rated_schools_section }
  with_subject :top_rated_schools_section do
    its('heading.text') { is_expected.to include(heading_object.name) }
    its('top_rated_schools.size') { is_expected.to eq(4) }
    its('first_top_rated_school.rating.text') { is_expected.to eq('10') }
    it { is_expected.to have_top_rated_schools }
    its('first_top_rated_school.href') { is_expected.to match(/\d+-Nearby-School-\d/) }
  end
end