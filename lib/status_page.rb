# rack middleware for handling the status page (as rails chokes internally if the DB is down)

class StatusPage
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    unless env['PATH_INFO'] == '/gsr/admin/status'
      @app.call(env)
    else
      db_status_local = db_status
      solr_status_local = solr_status

      db_text = "DB: #{db_status_local ? 'OK' : 'FAILED'}"
      solr_text = "Solr: #{solr_status_local ? 'OK' : 'FAILED'}"
      version_text = version_string

      [ ( (db_status_local && solr_status_local) ? 200 : 503),
        {'Content-Type' => 'text/plain'},
        [ [db_text, solr_text, version_text].join("\n\n")]
      ]
    end
  end

  def version_string
    File.read(Rails.root.join("version.txt")) rescue 'VERSION UNKNOWN'
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
    solr_status = false
    begin
      solr_status = (Solr.new.ping.response[:status] == 200)
    rescue Exception => e
      Rails.logger.error(e.message)
    end
    solr_status
  end
end
