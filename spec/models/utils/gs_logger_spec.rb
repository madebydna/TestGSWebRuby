require 'spec_helper'

describe GSLogger do

  describe '.swallow_and_log_errors_unless_development' do
    let(:message) { 'Something bad happened' }
    let(:tag) { :foo }
    let(:vars) do
      {
        a: 1,
        b: 2
      }
    end
    subject { GSLogger.swallow_and_log_errors_unless_development(tag, vars, message, &block) }

    context 'when block raises an error' do
      context 'in development' do
        before { allow(Rails.env).to receive(:development?).and_return(true) }
        let(:block) do
          Proc.new { raise 'bwahaha' }
        end
        it 'logs the attributes and re-raises the error' do
          expect(GSLogger).to receive(:error).with(tag, be_a(RuntimeError), vars: vars, message: message)
          expect { subject }.to raise_error
        end
      end

      context 'in production' do
        before { allow(Rails.env).to receive(:production?).and_return(true) }
        let(:block) do
          Proc.new { raise 'bwahaha' }
        end
        it 'logs the attributes' do
          expect(GSLogger).to receive(:error).with(tag, be_a(RuntimeError), vars: vars, message: message)
          subject
        end
        it 'swallows the exception' do
          expect { subject }.to_not raise_error
        end
      end
    end

    context 'when block does not raise an error' do
      let(:block) do
        Proc.new { 'all is well' }
      end
      it 'executes the block and returns the result' do
        expect(subject).to eq('all is well')
      end
    end
  end
end
