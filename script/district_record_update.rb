from_date = ARGV.first

begin
  date = Date.parse(from_date)
rescue ArgumentError => e
  puts "Use date format: YYYY-MM-DD"
  abort e.message
end


UpdateQueue.where(source: ['District editor', 'Queue Processor']).where("created > ?", from_date).each do |queue_entry|
  # force update
  update_blob = JSON.parse(queue_entry.update_blob)

  # {
  # "directory" : [
  #   {
  #     "action" : "build_cache",
  #     "entity_id" : 608,
  #     "entity_state" : "OK",
  #     "entity_type" : "district"
  #   }
  # ]
  # }
  next unless update_blob["directory"][0]["entity_type"] == "district"
  shard = update_blob["directory"][0]["entity_state"].downcase.to_sym
  entity_id = update_blob["directory"][0]["entity_id"]
  district = District.on_db(shard).find(entity_id)
  puts "-- Processing district #{shard}-#{district.id}"
  begin
    DistrictRecord.update_from_district(district, shard, log: true)
  rescue RuntimeError => e
    puts "DistrictRecord NOT updated"
    puts e.message
  end
end