# frozen_string_literal: true 

describe SearchController do
  describe '#entity_types' do
    subject { controller.entity_types }

    ['st', 'type'].each do |key|
      context "with multiple of the same #{key} param, where key doesnt have square brackets" do
        before { controller.request = double(query_string: "#{key}=public&#{key}=charter") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['public','charter'])
        end
      end

      context "with multiple of the same #{key} param, where key has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=private&#{key}[]=charter") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['private','charter'])
        end
      end

      context "with a single #{key} param" do
        before { controller.request = double(query_string: "#{key}=charter") }
        it 'returns an array with one value' do
          expect(subject).to eq(['charter'])
        end
      end

      context "with a single #{key} param that has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=charter") }
        it 'returns an array with one value' do
          expect(subject).to eq(['charter'])
        end
      end
    end
  end

  describe '#level_codes' do
    subject { controller.level_codes }

    ['gradeLevels', 'level_code'].each do |key|
      context "with multiple of the same #{key} param, where key doesnt have square brackets" do
        before { controller.request = double(query_string: "#{key}=p&#{key}=e") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['p','e'])
        end
      end

      context "with multiple of the same #{key} param, where key has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=p&#{key}[]=e") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['p','e'])
        end
      end

      context "with a single #{key} param" do
        before { controller.request = double(query_string: "#{key}=p") }
        it 'returns an array with one value' do
          expect(subject).to eq(['p'])
        end
      end

      context "with a single #{key} param that has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=p") }
        it 'returns an array with one value' do
          expect(subject).to eq(['p'])
        end
      end

      context 'when no params given' do
        before { controller.request = double(query_string: '') }
        it 'defaults to empty array' do
          expect(subject).to eq([])
        end
      end
    end
  end

end