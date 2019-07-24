require 'etc'

class ScriptLogger < ActiveRecord::Base
  self.table_name = 'script_logs'

  db_magic :connection => :gs_schooldb

  validates :username, presence: {message: 'Must provide a username'}
  validates :pid, :script_name, presence: true
  validates :start, presence: {message: 'Must provide start for script'}

  def self.record_log_instance(script_name, params)
    log = new
    log.username = ScriptLogger.username
    log.pid = ScriptLogger.pid
    log.script_name = script_name
    log.filename = ScriptLogger.filename
    log.start = Time.now.utc
    log.arguments = params

    log.save
    log
  end

  def self.username
    Etc.getpwuid(ScriptLogger.uid).name
  end

  def self.uid
    Process.uid
  end

  def self.pid
    Process.pid
  end

  def self.filename
    File.basename($PROGRAM_NAME)
  end
  
end