def school_collection_values
  Collection.all.to_a.map do |collection|
    if collection.definition.present?
      collection.definition.each_with_object('') do |(state, where_clause), query|
        school_ids = School
          .on_db(state.to_s.downcase)
          .where(where_clause)
          .to_a
          .map(&:id)
        school_ids.each do |school_id|
          query << "('#{state}', #{school_id}, #{collection.id}),"
        end
      end
    end
  end.join.sub(/,$/, ';')
end

def truncate_school_collection!
  ActiveRecord::Base.connection.execute(
    "TRUNCATE TABLE gs_schooldb.#{SchoolCollection.table_name}"
  )
end

def insert_statement(values)
  "INSERT INTO gs_schooldb.school_collections (state, school_id, collection_id)
  VALUES
  #{values}"
end

def add_school_collections!(values)
  ActiveRecord::Base.connection.execute(insert_statement(values))
end

truncate_school_collection!
add_school_collections!(school_collection_values)
