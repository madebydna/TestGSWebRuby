namespace :gsweb do

  task :install do
    if Rails.env == 'development'
      sh 'touch config/database_local.yml'
      sh 'touch config/env_global_local.yml'

      sh 'bundle install'
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke

      # Note this only creates one state db - CA
      dbs_to_create = 'gs_schooldb', '_ca', 'community', 'surveys', 'us_geo'

      Rake::Task['db:legacy:schema'].invoke(false, *dbs_to_create)

      Rake::Task['gsweb:load_alameda_high_school_profile_data'].invoke
    end
  end

  task :load_alameda_high_school_profile_data do
    require 'sample_data_helper'
    load_sample_data 'alameda_high_school_profile', Rails.env
  end

end