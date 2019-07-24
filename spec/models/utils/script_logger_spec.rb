require 'spec_helper'

describe ScriptLogger do
  after(:all) do
    do_clean_models(:gs_schooldb, ScriptLogger)
  end

  context "ScriptLogger::record_log_instance" do
    it "should save the instance to the database" do
      ScriptLogger.record_log_instance("NewCachePopulator", {"params" => "some params"})
      expect(ScriptLogger.where(script_name: "NewCachePopulator").first.arguments).to eq({"params" => "some params"}.to_s)
    end

    it "should return the ActiveRecord object after successful initialization" do
      log = ScriptLogger.record_log_instance("SomeOtherCachePopulator", {"params" => "new params"})
      expect(ScriptLogger.where(script_name: "SomeOtherCachePopulator").first).to eq(log)
    end
  end
end