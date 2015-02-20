require 'spec_helper'

describe String do

  describe '#gs_capitalize_first' do
    it 'should handle empty string' do
      expect(''.gs_capitalize_first).to eq('')
    end

    it 'should capitalize the first word' do
      expect('washington'.gs_capitalize_first).to eq('Washington')
    end

    it 'should capitalize the first word of multi-word string' do
      expect('washington, dc'.gs_capitalize_first).to eq('Washington, dc')
    end
  end

  describe '#gs_capitalize_first!' do
    it 'should handle empty string' do
      string = ''
      expect { string.gs_capitalize_first! }.to_not change { string }
    end

    it 'should capitalize the first word' do
      string = 'washington'
      expect { string.gs_capitalize_first! }.to change { string }.from('washington').to('Washington')
    end

    it 'should capitalize the first word of multi-word string' do
      string = 'washington, dc'
      expect { string.gs_capitalize_first! }.to change { string }.from('washington, dc').to('Washington, dc')
    end
  end
end
