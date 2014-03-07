module SpecForModelWithCustomConnection
  extend ActiveSupport::Concern

  included do
    before(:suite) do
      DatabaseCleaner[:active_record, { model: described_class }].strategy = :truncation
      DatabaseCleaner[:active_record, { model: described_class }].clean_with(:truncation)
    end
    before(:each) do
      DatabaseCleaner[:active_record, { model: described_class }].strategy = :truncation
      DatabaseCleaner[:active_record, { model: described_class }].start
    end
    after(:each) do
      DatabaseCleaner[:active_record, { model: described_class }].strategy = :truncation
      DatabaseCleaner[:active_record, { model: described_class }].clean
    end
    after(:suite) do
      DatabaseCleaner[:active_record, { model: described_class }].strategy = :truncation
      DatabaseCleaner[:active_record, { model: described_class }].clean_with(:truncation)
    end
  end

end