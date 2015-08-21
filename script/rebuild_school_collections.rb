module RebuildSchoolCollections

  module_function

  def add_school_collections!
    school_collections_to_add.each do |sc|
      add_school_collection!(sc)
    end
  end

  def remove_school_collections!
    school_collections_to_remove.each do |sc|
      remove_school_collection!(sc)
    end
  end

  def school_collections_to_add
    school_collections_from_definition - school_collections_from_db
  end

  def school_collections_to_remove
    school_collections_from_db - school_collections_from_definition
  end

  def remove_school_collection!(values)
    ActiveRecord::Base.connection.execute(delete_statement(values))
  end

  def add_school_collection!(values)
    ActiveRecord::Base.connection.execute(insert_statement(values))
  end

  def school_collections_from_definition
    @school_collections_from_definition ||= (
      Collection.all.map do |collection|
        if collection.definition.present?
          collection.definition.each_with_object([]) do |(state, where_clause), query|
            school_ids = school_ids_for_definition(state.downcase, where_clause)
            school_ids.each do |school_id|
              query << [state, school_id, collection.id]
            end
          end
        end
      end.flatten(1)
    )
  end

  def school_ids_for_definition(shard, where_clause)
    # There is a better ActiveRecord way of doing this with .pluck, but it seems
    # like that does not behave well with sharding.
    ActiveRecord::Base.connection.execute(
      "select id from _#{shard}.school where #{where_clause};"
    ).to_a.flatten
  end

  def school_collections_from_db
    @school_collections_from_db ||= (
      SchoolCollection.all.map do |school_collection|
        school_collection.attributes.values_at('state', 'school_id', 'collection_id')
      end
    )
  end

  def insert_statement(values)
    "INSERT INTO gs_schooldb.school_collections (state, school_id, collection_id)
    VALUES #{as_sql_value(values)};"
  end

  def as_sql_value(array)
    "('#{array[0]}', #{array[1]}, #{array[2]})"
  end

  def delete_statement(values)
    "DELETE FROM gs_schooldb.school_collections where #{as_sql_where(values)};"
  end

  def as_sql_where(array)
    "(
      collection_id = #{array[2]} and
      school_id     = #{array[1]} and
      state         = '#{array[0]}'
    )"
  end
end

if ENV['RAILS_ENV'] == 'production'
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['mysql_production_rw'])
else
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['mysql_dev_rw'])
end
RebuildSchoolCollections.add_school_collections!
RebuildSchoolCollections.remove_school_collections!
