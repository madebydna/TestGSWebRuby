# rack middleware for handling the status page (as rails chokes internally if the DB is down)

class StatusPage
  def initialize(app, options={})
    @app = app
  end

  def call(env)
    unless env['PATH_INFO'] == '/gsr/admin/status'
      @app.call(env)
    else
      redis_status_local = redis_status
      db_status_local = db_status
      [ (redis_status_local && db_status_local ? 200 : 500),
        {'Content-Type' => 'text/plain'},
        ["DB: #{db_status_local ? 'OK' : 'FAILED'}\nRedis: #{redis_status_local ? 'OK' : 'FAILED'}\n\n#{version_string}"]
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
end