require 'spec_helper'

describe CommunityTabConcerns do

  let(:controller) { FakeController.new }
  before(:all) do
    class FakeController
      include CommunityTabConcerns
    end
  end

  after(:all) { Object.send :remove_const, :FakeController }

  describe '#get_community_tab_from_request_path' do
    [true, false].each do |show_tabs| 
      context "when show_tabs is #{show_tabs}" do
        let(:show_tabs) { show_tabs }
        context 'when request path is /education-community/education' do
          subject { controller.send(:get_community_tab_from_request_path, "/education-community/education", show_tabs) }
          it { is_expected.to eq('Education') }
        end
        context 'when request path is /education-community/funders' do
          subject { controller.send(:get_community_tab_from_request_path, "/education-community/funders", show_tabs) }
          it { is_expected.to eq('Funders') }
        end
      end
    end
    context 'when request path is /education-community' do
      context "when show_tabs is false" do
        let(:show_tabs) { false }
        subject { controller.send(:get_community_tab_from_request_path, "/education-community", show_tabs) }
        it { is_expected.to eq('') }
      end
      context "when show_tabs is true" do
        let(:show_tabs) { true}
        subject { controller.send(:get_community_tab_from_request_path, "/education-community", show_tabs) }
        it { is_expected.to eq('Community') }
      end
    end
  end

end

