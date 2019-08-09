require 'spec_helper'

describe SchoolAssociationPreloading do
    
    describe '.extend' do
        it 'works for ActiveRecord relations that have a state and school_id method' do
            expect { Review.has_comment.extend(SchoolAssociationPreloading) }.not_to raise_error
        end

        it 'works for Enumerables whose objects have a state and school_id method' do
            expect { [Review.new, Review.new].extend(SchoolAssociationPreloading) }.not_to raise_error
        end

        it 'does not work for non ActiveRecord relations or Enumerables' do 
            expect { OpenStruct.new(school_id: 123, state: "CA").extend(SchoolAssociationPreloading) }.to raise_error(/must be mixed into an ActiveRecord relation or an Enumerable object/)
        end

        it 'does not work for ActiveRecord relations without the state method' do
            expect { Country.unscoped.extend(SchoolAssociationPreloading) }.to raise_error(/Country does not respond to \.state/)
        end

        it 'does not work for ActiveRecord relations without the school_id method' do
            expect { City.unscoped.extend(SchoolAssociationPreloading) }.to raise_error(/City does not respond to \.school_id/)
        end

        it 'does not work for Enumerable objects whose members don\'t have the state method' do
            expect { [ OpenStruct.new(school_id: 123) ].extend(SchoolAssociationPreloading) }.to raise_error(/OpenStruct does not respond to \.state/)
        end

        it 'does not work for Enumerable objects whose members don\'t have the school_id method' do
            expect { [ OpenStruct.new(state: "CA") ].extend(SchoolAssociationPreloading) }.to raise_error(/OpenStruct does not respond to \.school_id/)
        end

        it 'works for empty Enumerable objects' do
            expect { [].extend(SchoolAssociationPreloading) }.not_to raise_error
        end
    end

end