shared_examples_for 'model with favorite schools association' do

  it { is_expected.to respond_to(:add_favorite_school!) }
  it { is_expected.to respond_to(:favorited_school?) }

  describe '#add_favorite_school!' do
    subject(:user) { FactoryGirl.create(:new_user) }
    after { clean_dbs :gs_schooldb }
    let(:school) { FactoryGirl.create(:alameda_high_school) }
    it 'should save the given school as a favorite' do
      subject.add_favorite_school!(school)
      favorite_school = FavoriteSchool.find_by(member_id: user.id, state: school.state, school_id: school.id)
      expect(favorite_school).to be_present
    end
  end

  describe '#favorited_school?' do
    subject(:user) { FactoryGirl.create(:new_user) }
    after { clean_dbs :gs_schooldb }
    let(:school) { FactoryGirl.create(:alameda_high_school) }
    context 'when user has favorited the school' do
      before { FactoryGirl.create(:favorite_school, school_id: school.id, state: school.state, member_id: user.id) }
      it { is_expected.to be_favorited_school(school) }
    end
    context 'when user has not favorited the school' do
      it { is_expected.to_not be_favorited_school(school) }
    end
  end

end