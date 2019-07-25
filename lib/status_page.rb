# rack middleware for handling the status page (as rails chokes internally if the DB is down)

class StatusPage
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    if env['PATH_INFO'] == '/gsr/admin/status'
      db_status_local = db_status
      solr_status_local = solr_status

      db_text = "DB: #{db_status_local ? 'OK' : 'FAILED'}"
      solr_text = "Solr: #{solr_status_local ? 'OK' : 'FAILED'}"
      script_status =  script_status1

      version_text = version_string

      response_code = (db_status_local && solr_status_local) ? 200 : 503
      headers = {'Content-Type' => 'text/plain',
                 'cache-control' => 'private, must-revalidate, max-age=0'}
      body = [[db_text, solr_text, script_status, version_text].join("\n\n")]
      [response_code, headers, body]
    else
      @app.call(env)
    end
  end

  def version_string
    File.read(Rails.root.join("version.txt")) rescue 'VERSION UNKNOWN'
  end

  def script_status1
    current_script + last_script_ran
  end

  def current_script
    scripts = ScriptLogger.where(output: nil).order(start: :desc)
    begin
      script = scripts.first
      "Current Running Script:
        Filename: #{script.filename}
        Username: #{script.username}
        Start time: #{script.start}
        Elapse Time: #{((Time.now.utc - script.start) / 60).round(2)} minutes\n\n"
    rescue
      "Current Running Script:
        NONE RUNNING\n\n"
    end
  end

  def last_script_ran
    script = ScriptLogger.where.not(end: nil).order(end: :desc).first
      "Last Finished Script:
        Filename: #{script.filename}
        Username: #{script.username}
        Start time: #{script.start}
        End time: #{script.end}
        Success?: #{script.succeeded}
        Elapsed Time: #{((script.end - script.start) / 60).round(2)} minutes
        Output: #{script.output}
        \n"
  end

  def redis_status
    redis_status = false
    begin
      redis_status = Resque.redis.echo('test123') == 'test123'
    rescue Exception => e
      Rails.logger.error(e.message)
    end
    redis_status
  end

  def db_status
    db_status = false
    begin
      db_status = ActiveRecord::Base.connection.active?
    rescue Exception => e
      Rails.logger.error(e.message)
    end
    db_status
  end

  def solr_status
    solr_up = false
    begin
      solr_up = Solr::Client.ro_up?
    rescue Exception => e
      Rails.logger.error(e.message)
    end
    solr_up
  end
end
