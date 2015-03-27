require 'spec_helper'

describe OspQuestion do
  after(:each) { clean_dbs :gs_schooldb }

  describe '#answers' do
    context 'when default config is malformed' do
      before do
        subject.default_config = 'sdsdsdsd'
      end

      it 'returns nil' do
        expect(subject.answers).to be_nil
      end
    end

    context 'when default config specifies some answers' do
      before do
        subject.default_config = '{ "answers":{"AFTER":"V1"} }'
      end

      it 'returns a hash with one answer' do
        expect(subject.answers).to be_a(Hash)
        expect(subject.answers.size).to eq(1)

      end
    end

  end

end
