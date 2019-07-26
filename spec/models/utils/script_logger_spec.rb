require 'spec_helper'

describe ScriptLogger do
  after(:all) do
    do_clean_models(:gs_schooldb, ScriptLogger)
  end

  context ".record_log_instance" do
    before(:all) do
      ScriptLogger.record_log_instance([{"params" => "some params"}])
      ScriptLogger.record_log_instance([{"params" => "new params"}])
    end

    it "should save the instance to the database" do
      expect(ScriptLogger.where(output: nil).length).to eq(2)
    end

    it "should return the ActiveRecord object after successful initialization" do
      arr = [{"params" => "new params"}].to_s
      log = ScriptLogger.find_by(arguments: arr)
      expect(log).to be_truthy
    end
  end

  context "#finish_logging_session" do
    before(:all) do
      ScriptLogger.record_log_instance("test finishing log")
    end
    it "update the instance" do
      log = ScriptLogger.find_by_output(nil)
      log.finish_logging_session(1,"Great Output!")
      expect(ScriptLogger.find_by_output("Great Output!").succeeded).to eq(true)
    end
  end
end