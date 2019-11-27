require 'spec_helper'

describe SchoolAssociationPreloading do
    
  describe '.extend' do
    class Foo
      include Enumerable

      def state
        "state"
      end

      def school_id
        "school_id"
      end
    end

    it 'does not work for ActiveRecord relations without the state method' do
        expect { Country.unscoped.extend(SchoolAssociationPreloading) }.to raise_error(/Country does not respond to \.state/)
    end

    it 'works for ActiveRecord relations that have a state and school_id method' do
      expect { Review.has_comment.extend(SchoolAssociationPreloading) }.not_to raise_error
    end

    it 'does not work for non ActiveRecord relations' do 
      expect { Foo.extend(SchoolAssociationPreloading) }.to raise_error(ArgumentError, /must be mixed into an ActiveRecord relation/)
    end

    it 'does not work for ActiveRecord relations without the state method' do
      expect { Country.unscoped.extend(SchoolAssociationPreloading) }.to raise_error(ArgumentError, /Country does not respond to \.state/)
    end

    it 'does not work for ActiveRecord relations without the school_id method' do
      expect { City.unscoped.extend(SchoolAssociationPreloading) }.to raise_error(ArgumentError, /City does not respond to \.school_id/)
    end
  end

end