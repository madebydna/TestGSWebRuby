class SchoolLoading::Loader < SchoolLoading::Base

  DATA_TYPE = :school_data

  def load!
    begin

      if updates.present?
        to_be_updated_value =  updates.map{|update| update["value"] }.join(",")
        to_be_updated_column_name = data_type
        school_update = SchoolLoading::Update.new(data_type, updates.first)
        database = school_update.entity_state.to_s.downcase.to_sym
        existing_school = School.on_db(database).find(school_update.entity_id)
        if should_be_inserted?(school_update,existing_school)
        existing_school.on_db(database).update_attributes(
            to_be_updated_column_name => to_be_updated_value,
            modified: updates.first['created'].present? ? updates.first['created'] : Time.now,
            modifiedBy: source
        )
        end
      end
    end
  rescue Exception => e
    raise e.message
  end


  def should_be_inserted?(update, existing_school)
     (existing_school.present? && !existing_school.modified.present?)|| (existing_school.present? && existing_school.modified.present? &&  update.created.present? && Time.parse(update.created) +2.minutes >  existing_school.modified)
  end

end


