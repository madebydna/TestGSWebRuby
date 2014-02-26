namespace :gsweb do

  task :install do
    if Rails.env == 'development'
      sh 'bundle install'
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      sh 'touch config/database-local.yml'
    end
  end

end