require 'spec_helper'

describe ScriptLogger do
  after(:all) do
    do_clean_models(:gs_schooldb, ScriptLogger)
  end

  context ".record_log_instance" do
    it "should save the instance to the database" do
      ScriptLogger.record_log_instance({"params" => "some params"})
      expect(ScriptLogger.where(output: nil).first.arguments).to eq({"params" => "some params"}.to_s)
    end

    it "should return the ActiveRecord object after successful initialization" do
      hash = {"params" => "new params"}
      log = ScriptLogger.record_log_instance(hash)
      expect(ScriptLogger.find_by_arguments(hash.to_s)).to eq(log)
    end
  end

  context "#finish_logging_session" do
    it "update the instance" do
      log = ScriptLogger.find_by_output(nil)
      log.finish_logging_session(1,"Great Output!")
      expect(ScriptLogger.where(output: "Great Output!").first.succeeded).to eq(true)
    end
  end
end