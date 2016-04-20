require 'spec_helper'

describe SharedCache do
  after(:each) do
    clean_models(:gs_schooldb, SharedCache)
  end
  let(:default_expiration) {'3000-01-01 12:00:00.000000000 -0800'}
  describe '.set_cache_value' do
    let(:quay) { 'cache_key' }
    let(:value) { 'blah' }
    let(:expiration) { Time.parse('1/1/2000','8:00') }
    context 'with valid shared cache' do
      context 'with no shared cached with key in database' do
        context 'with expiration time set' do
          subject { SharedCache.set_cache_value(quay, value, Time.parse('7:00')) }
          it 'should start with no SharedCache' do
            expect(SharedCache.where(quay:'cache_key').count).to eq(0)
          end
          it 'should save new cache' do
            subject
            expect(SharedCache.where(quay:'cache_key').count).to eq(1)
          end
        end
        context 'with expiration time not set' do
          subject { SharedCache.set_cache_value(quay, value) }
          it 'should save new save cache' do
            subject
            expect(SharedCache.where(quay:'cache_key').count).to eq(1)
          end
          it 'should save new cache with default expiration time' do
            subject
            expect(SharedCache.find_by_quay('cache_key').expiration).
              to eq(default_expiration)
          end
        end
      end
      context 'with shared cached key already in database' do
        let!(:shared_cache) { FactoryGirl.create(:shared_cache) }
        context 'with expiration time set' do
          subject { SharedCache.set_cache_value(quay, value, expiration) }
          it 'should already have shared cache with key in database' do
            expect(SharedCache.where(quay:'cache_key').count).to eq(1)
          end
          it 'should update values for cache with cache_key in database' do
            subject
            expect(SharedCache.where(quay:'cache_key').count).to eq(1)
            expect(SharedCache.find_by_quay('cache_key').value).to eq(value)
            expect(SharedCache.find_by_quay('cache_key').expiration).to eq(expiration)
          end
        end
        context 'with expiration time not set' do
          subject { SharedCache.set_cache_value(quay, value) }
          it 'should already have shared cache with key in database' do
            expect(SharedCache.where(quay:'cache_key').count).to eq(1)
          end
          it 'should update values for cache with cache_key in database' do
            subject
            expect(SharedCache.where(quay:'cache_key').count).to eq(1)
            expect(SharedCache.find_by_quay('cache_key').value).to eq(value)
            expect(SharedCache.find_by_quay('cache_key').expiration).to eq(default_expiration)
          end
        end
      end
    end
    context 'shared cache not saved' do
      subject { SharedCache.set_cache_value(nil, value, expiration) }
      let(:gs_logger) { class_double('GSLogger') }
      it 'should log shared cache failed to save error' do
        error_message = "shared cache failed to save: Mysql2::Error: Field 'quay' doesn't have a default value: INSERT INTO `shared_cache` (`expiration`, `value`) VALUES ('2000-01-01 00:00:00', 'blah')"
        stub_const('GSLogger', gs_logger)
        expect(gs_logger).to receive(:error).
          with(:shared_cache, nil, message: error_message,
               vars: {
            quay: nil,
            value: 'blah',
            expiration: expiration
        })
        subject
      end
    end
  end
end
