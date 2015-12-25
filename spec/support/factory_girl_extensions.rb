module FactoryGirl
  def self.create_on_shard(shard, *args)
    obj = build(*args)
    obj.on_db(shard).save
    obj
  end
  def self.create_list_on_shard(shard, *args)
    objs = build_list(*args)
    objs.each { |o| o.on_db(shard).save }
    objs
  end
end