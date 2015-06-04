require 'spec_helper'

shared_context 'when user type has value' do |value|
  before { subject.user_type = value }
end


describe SchoolMember do
  let(:user) { FactoryGirl.build(:verified_user) }
  let(:school) { FactoryGirl.build(:alameda_high_school) }
  let(:school_member) { FactoryGirl.build(:school_member, user: user, school: school, user_type: nil) }
  subject { school_member }

  describe '#user_type' do
    context 'when user is not esp member' do
      {
        nil => :unknown,
        'unknown' => :unknown,
        'parent' => :parent,
        'community member' => :'community member',
        'foo' => :unknown
      }.each_pair do |value_from_db, expected_value|
        with_shared_context 'when user type has value', value_from_db do
          its(:user_type) { is_expected.to eq expected_value }
        end
      end
    end
    context 'when user is an esp member' do
      before do
        allow(subject).to receive(:approved_osp_user?).and_return true
      end
      {
        nil => :principal,
        'unknown' => :principal,
        'community member' => :'community member',
        'parent' => :parent,
        'foo' => :principal
      }.each_pair do |value_from_db, expected_value|
        with_shared_context 'when user type has value', value_from_db do
          its(:user_type) { is_expected.to eq expected_value }
        end
      end
    end
  end

  describe '#approved_osp_user?' do
    let(:mock_esp_memberships) { double }
    before do
      allow(user).to receive(:esp_memberships).and_return(mock_esp_memberships)
      expect(mock_esp_memberships).to receive(:for_school).with(school).and_return school_esp_memberships
    end
    context 'when there is an approved esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_approved_status) ] }
      it { is_expected.to be_approved_osp_user }
    end
    context 'when there is only a provisional esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_provisional_status) ] }
      it { is_expected.to_not be_approved_osp_user }
    end
  end

  describe '#provisional_osp_user?' do
    let(:mock_esp_memberships) { double }
    before do
      allow(user).to receive(:esp_memberships).and_return(mock_esp_memberships)
      expect(mock_esp_memberships).to receive(:for_school).with(school).and_return school_esp_memberships
    end
    context 'when there is a provisional esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_provisional_status) ] }
      it { is_expected.to be_provisional_osp_user }
    end
    context 'when there is only an approved esp membership for the user and school' do
      let(:school_esp_memberships) { [ FactoryGirl.build(:esp_membership, :with_approved_status) ] }
      it { is_expected.to_not be_provisional_osp_user }
    end
  end

  describe '#deactivate_reviews_with_comments!' do
    subject { school_member }

    context 'with review without comments' do
      let(:reviews) { FactoryGirl.build_list(:review, 2, comment: ' lorem ' * 15) }
      before do
        allow(subject).to receive(:reviews).and_return(reviews.extend ReviewScoping)
      end
      after { clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion)}
      it 'should deactivate both reviews' do
        expect{subject.deactivate_reviews_with_comments!}.to change {reviews.map(&:active)}
        expect(reviews.map(&:active)).to eq([false, false])
      end
    end

    context 'with review with comment' do
      let(:reviews) { FactoryGirl.build_list(:review, 2, comment: '') }
      before do
        allow(subject).to receive(:reviews).and_return(reviews.extend ReviewScoping)
      end
      after { clean_models(:gs_schooldb, Review, ReviewTopic, ReviewQuestion)}
      it 'should not deactivate review' do
        expect{subject.deactivate_reviews_with_comments!}.to_not change {reviews.map(&:active) }
        expect(reviews.map(&:active)).to eq([true, true])
      end
    end
  end

end