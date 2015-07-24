require 'spec_helper'



describe TestScoresCaching::QueryResultDecorator do

  def decorator(hash, state = 'CA')
    hash = hash.stringify_keys
    TestScoresCaching::QueryResultDecorator.new(state, Hashie::Mash.new(hash))
  end

  [:school_value, :state_value].each do |field|
    method = field.to_s
    describe "##{method}" do
      it 'should prefer value_text over value_float' do
        expect(
          decorator("#{field}_text" => '10', "#{field}_value" => 20).send(method)
        ).to eq('10')
      end

      it 'should use value_float when there is no value_text' do
        expect(decorator("#{field}_float" => 20).send(method)).to eq(20)
      end
    end
  end

  describe '#grade_label' do
    it 'should handle "School-wide"' do
      expect(decorator(grade: 'All', level_code: 'e,m,h').grade_label)
        .to eq('School-wide')
    end

    it 'should handle "Elementary"' do
      expect(decorator(grade: 'Alle', level_code: 'e').grade_label)
        .to eq('Elementary school')
    end

    it 'should handle "Elementary"' do
      expect(decorator(grade: 'Allem', level_code: 'e,m').grade_label)
        .to eq('Elementary and Middle school')
    end

    it 'should handle grade 8' do
      expect(decorator(grade: '8', level_code: 'm').grade_label)
        .to eq('GRADE 8')
    end

    it 'should handle preschool' do
      pending('does it matter?')
      expect(decorator(grade: 'PK', level_code: 'p').grade_label)
        .to eq('Preschool')
    end
  end

end