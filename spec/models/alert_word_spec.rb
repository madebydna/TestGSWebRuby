require 'spec_helper'

describe AlertWord do

  describe '.search' do
    before do
      AlertWord.create!( word: 'test_really_bad_word', really_bad: true )
      AlertWord.create!( word: 'test_alert_word', really_bad: false )
      AlertWord.create!( word: 'test alert phrase', really_bad: false )
      AlertWord.create!( word: 'test-hyphen', really_bad: false )
      AlertWord.create!( word: 'test evil apostrophe\'s', really_bad: false )
      AlertWord.create!( word: 'test *other \\symbols', really_bad: false )
      AlertWord.create!( word: '@', really_bad: false )
    end

    it 'should match really bad words' do
      expect(AlertWord.search('test_really_bad_word')).to have_really_bad_words
    end

    it 'should find an alert word when there\'s an exact match' do
      expect(AlertWord.search('test_alert_word')).to have_alert_words
    end

    it 'should treat words as case-insensitive' do
      expect(AlertWord.search('TEST_REALLY_BAD_word')).to have_really_bad_words
    end

    it 'should be able to find full alert phrases' do
      expect(AlertWord.search('find the test alert phrase').alert_words).to include('test alert phrase')
    end

    it 'should not mistake a word that\'s part of a phrase' do
      expect(AlertWord.search('phrase should not be found').alert_words).to_not include('test alert phrase')
    end

    it 'should match words adjacent to punctuation' do
      expect(AlertWord.search('test_really_bad_word?')).to have_really_bad_words
      expect(AlertWord.search('a test_really_bad_word? b')).to have_really_bad_words
      expect(AlertWord.search('a --test_really_bad_word? b')).to have_really_bad_words
      expect(AlertWord.search('--test_really_bad_word? b')).to have_really_bad_words
      expect(AlertWord.search('--test_really_bad_word?')).to have_really_bad_words
      expect(AlertWord.search('--test_really_bad_word')).to have_really_bad_words
    end

    it 'should match a hyphenated word' do
      expect(AlertWord.search('test-hyphen')).to have_alert_words
      expect(AlertWord.search('a test-hyphen b')).to have_alert_words
    end

    it 'should match words with apostrophes' do
      expect(AlertWord.search('test evil apostrophe\'s')).to have_alert_words
      expect(AlertWord.search('apostrophe\'s')).to_not have_alert_words
    end

    it 'should match words with backslashes and asterisks' do
      expect(AlertWord.search('test *other \\symbols')).to have_alert_words
      expect(AlertWord.search('other')).to_not have_alert_words
      expect(AlertWord.search('symbols')).to_not have_alert_words
    end

    it 'should compress whitespace' do
      expect(AlertWord.search(' test_really_bad_word  ')).to have_really_bad_words
      expect(AlertWord.search(' test  alert  phrase ')).to have_alert_words
    end

    it 'should not find any alert words or really bad words when given nil' do
      expect(AlertWord.search(nil)).to_not have_really_bad_words
      expect(AlertWord.search(nil)).to_not have_alert_words
    end

    describe 'should handle @ signs just like java code' do
      it 'should not match an @ sign within a \'word\' of symbols' do
        expect(AlertWord.search('*@#* you')).to_not have_alert_words
      end
      it 'should match an @ sign joining two words' do
        expect(AlertWord.search('blah@example.com')).to have_alert_words
      end
    end

  end



end