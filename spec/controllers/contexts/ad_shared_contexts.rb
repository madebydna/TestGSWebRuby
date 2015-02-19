require 'spec_helper'

shared_context 'when ads are enabled' do
  before do
    allow(controller).to receive(:show_ads?).and_return(true)
  end
end

shared_context 'when ads are not enabled' do
  before do
    allow(controller).to receive(:show_ads?).and_return(false)
  end
end