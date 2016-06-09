# encoding: utf-8
require 'spec_helper'

describe Latin1CharactersConcerns do

  let(:controller) { FakeController.new }
  before(:all) do
    class FakeController
      include Latin1CharactersConcerns 
    end
  end

  after(:all) { Object.send :remove_const, :FakeController }

  describe '#only_latin1_characters?' do
    it 'should reject non-latin1 characters' do
      non_latin_characters = 'ищукранрф'
      expect(controller.send(:only_latin1_characters?, non_latin_characters)).to be false
    end

    it 'should accept latin1 characters' do
      latin_characters = 'abcdefghijklmnopqrstuvwxyz1234567890-=`[]\;\'/<>?:"{}|+_)(*&^%$#@!~)"`'
      expect(controller.send(:only_latin1_characters?, latin_characters)).to be true
    end
  end

end
