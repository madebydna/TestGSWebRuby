describe CommunityConcerns do

  describe '#school_levels' do
    class WithSchoolLevels
      include CommunityConcerns

      def school_count(key)
        school_counts_hash[key]
      end

      private 
      def school_counts_hash
        {'all' => 100, 'public' => 80, 'charter' => 30, 'private' => 15, 'middle' => 30, 'high' => 30, 'elementary' => 40, 'preschool' => 20}
      end
    end

    class WithoutSchoolLevels
      include CommunityConcerns

      def school_count(key)
        school_counts_hash[key]
      end

      private
      def school_counts_hash
        {}
      end
    end

    it 'should return nil if there are no school counts' do
      expect(WithoutSchoolLevels.new.school_levels).to be nil
    end

    it 'should return a hash with symbolized keys if there are school levels' do
      expect(WithSchoolLevels.new.school_levels).to eq({all: 100, public: 80, charter: 30, private: 15, middle: 30, high: 30, elementary: 40, preschool: 20})
    end
  end

end