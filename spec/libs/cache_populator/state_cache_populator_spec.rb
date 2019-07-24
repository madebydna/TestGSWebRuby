require "spec_helper"

describe CachePopulator::StateCachePopulator do
    after(:each) do
        do_clean_models(:gs_schooldb, ScriptLogger)
    end

    context "validations" do
        it "validates correct states" do
            populator = CachePopulator::StateCachePopulator.new(values: 'ca,foo', cache_keys: 'gsdata,ratings')
            expect(populator).not_to be_valid
            expect(populator.errors[:states]).to include("must have the value 'all' or be a list of valid states")
        end
    end

    context "#run" do
        subject { CachePopulator::StateCachePopulator.new(values: 'ca,hi', cache_keys: 'gsdata,ratings') }

        it "calls StateCacher.create_cache for each state and key combination" do
            state_cacher = class_double("StateCacher").as_stubbed_const
            expect(state_cacher).to receive(:create_cache).with('ca', 'gsdata')
            expect(state_cacher).to receive(:create_cache).with('ca', 'ratings')
            expect(state_cacher).to receive(:create_cache).with('hi', 'gsdata')
            expect(state_cacher).to receive(:create_cache).with('hi', 'ratings')
            subject.run
        end
        
    end

    context "logs correctly" do
        argument = {"states"=>"ca", "cache_keys"=>"district_largest"}.to_s

        it "should initialize a record during cache built" do
            populator_instance = CachePopulator::StateCachePopulator.new(values: 'ca', cache_keys: 'district_largest')
            expect(ScriptLogger.all.count).to eq(1)
            expect(ScriptLogger.where(script_name: "StateCachePopulator").first.arguments).to eq(argument)
        end

        it "should log a successfully finished script" do
            populator = CachePopulator::StateCachePopulator.new(values: 'ca', cache_keys: 'district_largest')
            populator.run
            expect(ScriptLogger.all.count).to eq(1)
            expect(ScriptLogger.where(script_name: "StateCachePopulator").first.arguments).to eq(argument)
            expect(ScriptLogger.where(script_name: "StateCachePopulator").where.not(end: nil).first.succeeded).to eq(true)
        end
    end
end