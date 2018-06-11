# frozen_string_literal: true 

describe NewSearchController do
  describe '#entity_types' do
    subject { controller.entity_types }

    ['st', 'type'].each do |key|
      context "with multiple of the same #{key} param, where key doesnt have square brackets" do
        before { controller.request = double(query_string: "#{key}=a&#{key}=b") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['a','b'])
        end
      end

      context "with multiple of the same #{key} param, where key has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=a&#{key}[]=b") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['a','b'])
        end
      end

      context "with a single #{key} param" do
        before { controller.request = double(query_string: "#{key}=a") }
        it 'returns an array with one value' do
          expect(subject).to eq(['a'])
        end
      end

      context "with a single #{key} param that has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=a") }
        it 'returns an array with one value' do
          expect(subject).to eq(['a'])
        end
      end
    end
  end

  describe '#level_codes' do
    subject { controller.level_codes }

    ['gradeLevels', 'level_code'].each do |key|
      context "with multiple of the same #{key} param, where key doesnt have square brackets" do
        before { controller.request = double(query_string: "#{key}=a&#{key}=b") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['a','b'])
        end
      end

      context "with multiple of the same #{key} param, where key has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=a&#{key}[]=b") }
        it 'returns an array with the correct values' do
          expect(subject).to eq(['a','b'])
        end
      end

      context "with a single #{key} param" do
        before { controller.request = double(query_string: "#{key}=a") }
        it 'returns an array with one value' do
          expect(subject).to eq(['a'])
        end
      end

      context "with a single #{key} param that has square brackets" do
        before { controller.request = double(query_string: "#{key}[]=a") }
        it 'returns an array with one value' do
          expect(subject).to eq(['a'])
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