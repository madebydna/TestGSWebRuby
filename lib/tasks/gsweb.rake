namespace :gsweb do

  task :install do
    if Rails.env == 'development'
      sh 'touch config/database_local.yml'
      sh 'touch config/env_global_local.yml'

      sh 'bundle install'
      Rake::Task['db:create'].invoke

      # Note this only creates one state db - CA
      development_dbs_to_create =
        'gs_schooldb',
        '_ca',
        'community',
        'surveys',
        'us_geo'

      Rake::Task['db:legacy:schema'].invoke(false, *development_dbs_to_create)

      DatabaseTasksHelper.dump_database(
        'mysql_dev', 'localized_profiles',
        'mysql_localhost', 'LocalizedProfiles_development'
      )

      Rake::Task['gsweb:load_alameda_high_school_profile_data'].invoke
    end
  end

  task :load_alameda_high_school_profile_data do
    require 'sample_data_helper'
    load_sample_data 'alameda_high_school_profile', Rails.env
  end
  
  task :use_dev_db do
    database_local = Rails.root.join('config', 'database_local.yml')
    database_local_point_at_dev = 
    Rails.root.join('config', 'database_local.point_at_dev.yml')

    File.open(database_local, 'a') do |f|
      f << "\n" 
      f << File.read(database_local_point_at_dev)
    end
  end

  task :use_omega_db do
    database_local = Rails.root.join('config', 'database_local.yml')
    database_local_point_at_omega=
        Rails.root.join('config', 'database_local.point_at_omega.yml')

    File.open(database_local, 'a') do |f|
      f << "\n"
      f << File.read(database_local_point_at_omega)
    end
  end

  task :use_localhost_db do
    database_local = Rails.root.join('config', 'database_local.yml')
    database_local_point_at_dev = 
    Rails.root.join('config', 'database_local.point_at_dev.yml')

    new_database_local = File.read(database_local).
                              sub(
                                File.read(database_local_point_at_dev),
                                ''
                                )

    File.open(database_local, 'w') do |f|
      f << new_database_local
    end
  end

end