require 'spec_helper'

describe WidgetLog do
  context 'with malformed email' do
    subject do
      WidgetLog.new.tap do |widget_log|
        widget_log.email = 'foo'
      end
    end

    it { is_expected.to be_invalid }
  end

  context 'with nil email' do
    it { is_expected.to be_invalid }
  end

  context 'with valid email' do
    subject do
      WidgetLog.new.tap do |widget_log|
        widget_log.email = 'foo@bar.com'
      end
    end

    it { is_expected.to be_valid }
  end
end

