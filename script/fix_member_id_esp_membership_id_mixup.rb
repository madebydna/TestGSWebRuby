# See AT-931 for the reasons for this script.
# It updates member_id fields for tables that had esp_membership_id put into that field by accident.

module EspMembershipIdToMemberIdFixer

  module_function

  def connection
    @_connection ||= begin
      if ENV['RAILS_ENV'] == 'production'
        ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['mysql_production_rw'])
      else
        ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['mysql_dev_rw'])
      end
      ActiveRecord::Base.connection
    end
  end

  def esp_membership_to_member_id
    @_esp_membership_to_member_id ||= begin
      queries = [
        { table: 'gs_schooldb.osp_form_responses', date_field: 'updated', member_field: 'esp_membership_id' },
        { table: 'gs_schooldb.school_media', date_field: 'date_created', member_field: 'member_id' },
        { table: 'esp_response', date_field: 'created', member_field: 'member_id', sharded: true },
      ].each_with_object([]) do |osp_table, qs|
        if osp_table[:sharded]
          States.abbreviations.each do |state|
            qs << esp_membership_to_member_id_query(osp_table, state)
          end
        else
          qs << esp_membership_to_member_id_query(osp_table)
        end
      end
      queries.each_with_object({}) do |query, id_hash|
        new_ids = Hash[connection.execute(query).to_a].reject do |id, _|
          # Don't try to fix short member_ids that are potentially good
          valid_esp_member_short_member_ids.include?(id)
        end
        id_hash.merge!(new_ids)
      end
    end
  end

  def esp_membership_to_member_id_query(osp_table, state = nil)
    prefix = state ? "_#{state}." : ''
    "SELECT em.id, em.member_id FROM #{prefix}#{osp_table[:table]}
     JOIN gs_schooldb.esp_membership em
     ON em.id = #{osp_table[:table]}.#{osp_table[:member_field]}
     WHERE #{osp_table[:table]}.#{osp_table[:date_field]} >= '#{date_of_first_ruby_osp_usage}'
     AND length(#{osp_table[:table]}.#{osp_table[:member_field]}) <= 5
     GROUP BY em.id, em.member_id;"
  end

  def valid_esp_member_short_member_ids
    @_valid_esp_member_short_member_ids ||= begin
      query = "SELECT member_id FROM gs_schooldb.esp_membership
               WHERE length(member_id) <= 5 AND status like '%approved';"
      connection.execute(query).to_a.flatten
    end
  end

  def date_of_first_ruby_osp_usage
    @_date_of_first_ruby_osp_usage ||= begin
      query = "SELECT min(updated) FROM gs_schooldb.osp_form_responses;"
      connection.execute(query).to_a.flatten.first
    end
  end

  def fix_affected_members!
    esp_membership_to_member_id.each do |esp_id, member_id|
      fix_affected_school_media!
      fix_affected_osp_form_response!(esp_id, member_id)
      States.abbreviations.each do |state|
        fix_affected_esp_response!(esp_id, member_id, state)
      end
    end
  end

  def fix_affected_school_media!(esp_id, member_id)
    query = "UPDATE gs_schooldb.school_media set member_id = #{member_id}
             WHERE member_id = #{esp_id} AND
             date_created >= '#{date_of_first_ruby_osp_usage}'"
    connection.execute(query)
  end

  def fix_affected_esp_response!(esp_id, member_id, state)
    query = "UPDATE _#{state}.esp_response set member_id = #{member_id}
             WHERE member_id = #{esp_id} AND
             created >= '#{date_of_first_ruby_osp_usage}'"
    connection.execute(query)
  end

  def fix_affected_osp_form_response!(esp_id, member_id)
    query = "UPDATE gs_schooldb.osp_form_responses
             SET response = replace(response, '\"member_id\":#{esp_id},', '\"member_id\":#{member_id},')
             WHERE updated >= '#{date_of_first_ruby_osp_usage}'"
    connection.execute(query)
  end
end

EspMembershipIdToMemberIdFixer.fix_affected_members!
