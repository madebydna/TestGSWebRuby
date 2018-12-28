  # Script to parse through the SchoolCache and look for different ethnicity breakdowns for active schools
  # 
  
  STATE_HASH = {
    'alabama' => 'al',
    'alaska' => 'ak',
    'arizona' => 'az',
    'arkansas' => 'ar',
    'california' => 'ca',
    'colorado' => 'co',
    'connecticut' => 'ct',
    'delaware' => 'de',
    'district of columbia' => 'dc',
    'washington dc' => 'dc',
    'florida' => 'fl',
    'georgia' => 'ga',
    'hawaii' => 'hi',
    'idaho' => 'id',
    'illinois' => 'il',
    'indiana' => 'in',
    'iowa' => 'ia',
    'kansas' => 'ks',
    'kentucky' => 'ky',
    'louisiana' => 'la',
    'maine' => 'me',
    'maryland' => 'md',
    'massachusetts' => 'ma',
    'michigan' => 'mi',
    'minnesota' => 'mn',
    'mississippi' => 'ms',
    'missouri' => 'mo',
    'montana' => 'mt',
    'nebraska' => 'ne',
    'nevada' => 'nv',
    'new hampshire' => 'nh',
    'new jersey' => 'nj',
    'new mexico' => 'nm',
    'new york' => 'ny',
    'north carolina' => 'nc',
    'north dakota' => 'nd',
    'ohio' => 'oh',
    'oklahoma' => 'ok',
    'oregon' => 'or',
    'pennsylvania' => 'pa',
    'rhode island' => 'ri',
    'south carolina' => 'sc',
    'south dakota' => 'sd',
    'tennessee' => 'tn',
    'texas' => 'tx',
    'utah' => 'ut',
    'vermont' => 'vt',
    'virginia' => 'va',
    'washington' => 'wa',
    'west virginia' => 'wv',
    'wisconsin' => 'wi',
    'wyoming' => 'wy'
  }

states = STATE_HASH.values
# states = ["ak"]
breakdowns = []
time_start = Time.now
p "Started script at: #{time_start}"
state_breakdowns = []
states.each do |state|
  p "On #{state} at #{Time.now}"
  school_ids = School.on_db(state) { School.active.pluck(:id) }
  half = school_ids.length/2
  school_caches = SchoolCache.where(school_id: school_ids, state: state, name: "test_scores_gsdata")
  # school_caches = SchoolCache.where(school_id: school_ids, state: state, name: "test_scores_gsdata")
  # school_caches = SchoolCache.where(school_id: school_ids, state: state, name: "ratings")
  school_caches.each_with_index do |cache_info,idx|
    # p "Halfway through #{state}" if idx == half
    json_blob = JSON.parse(cache_info["value"])
    json_blob.values.each do |array_of_hash|
      breakdowns << array_of_hash.map {|x| x["breakdowns"]}
      # breakdowns << array_of_hash&.map {|x| x["breakdown"]}
    end
    # breakdowns << json_blob.values.map {|x| x.first["breakdown"] }
    # breakdowns << json_blob.select {|k,v| k == "Test Score Rating"}.values.first&.map {|x| x["breakdowns"]} #Test Score Rating
    # breakdowns << json_blob.select {|k,v| k == ""}.values.first&.map {|x| x["breakdowns"]} #Test Score Rating
  end
  hash = {key: state, breakdowns: breakdowns.flatten.uniq}
  state_breakdowns << hash
  File.open("./final_test_scores_gsdata.json","a") {|f| f.write(JSON.pretty_generate(hash)) }
  File.open("./final_test_scores_gsdata.json","a") {|f| f.write(',') }
  p "Finish #{state} at #{Time.now}"
end
p state_breakdowns
time_end = Time.now
p "Ended script at: #{time_end}"
time = time_end - time_start
p "Total time is #{time}s"