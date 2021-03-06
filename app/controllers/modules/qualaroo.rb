module Qualaroo

  QUALAROO_MODULE_KEY = {
      :test_scores => '1547acf4-6133-4d98-b2e0-5eb28ca1ec04',
      :college_readiness => '34aea707-ec71-4130-b6bb-2864e0528c64',
      :college_success => 'cb0e676f-324a-4a74-bc02-72ddf1a2ddd6',
      :advanced_coursework => 'd8fa4702-59cd-435c-a922-9409acaf81c8',
      :advanced_stem => '6a8ccb75-0c22-4433-a220-97db8fd509df',
      :race_ethnicity => 'a0e5e5a5-d6d6-45c6-99e4-4e1e06863f89',
      :low_income_students => '6bb9534f-6abf-4feb-b262-db8059ba49ee',
      :students_with_disabilities => '2cfa01ac-bd57-44a3-abb8-0684737688f1',
      :student_progress => 'c68711f4-5670-45d5-9221-c69b117c7f78',
      :general_information_public => '13cc9732-4b35-4092-b986-358c71d5b7fe',
      :general_information_private => '228904ba-a897-4581-8bf1-c49be0a3f259',
      :teachers_staff => '32af259e-27ef-44ae-a9e0-5b37ab9064ff',
      :students => '2daad497-0079-46c5-822d-5bf15f1aeff3',
      :neighborhood => 'e0d8fc09-ff65-44d3-940f-935b31143df6',
      :equity_overview => 'cdfc875c-df4c-4183-bcf9-f832a9238831',
      :equity_overview_no_data => '86bf250b-a12f-455c-9a32-5c356fd94da0',
      :academic_progress => 'ddbbd6fd-9ef6-4213-8925-cb342c3c36fe',
      :summary_narration => '97b3505a-16c7-4b57-a737-b090f1880b47',
      :summary_narration_test_only => '738d4a1d-54c3-4b94-80e0-79e355753e42'
  }

  def qualaroo_link(module_sym, state, school_id)
    'https://s.qualaroo.com/45194/' + QUALAROO_MODULE_KEY[module_sym] + '?state=' + state + '&school=' + school_id.to_s
  end

  def qualaroo_iframe(module_sym, state, school_id)
    # '<iframe src="' + qualaroo_link(module_sym, state, school_id) + '" frameborder="0" width="100%" height="350px"></iframe>'
    qualaroo_link(module_sym, state, school_id)
  end
end
