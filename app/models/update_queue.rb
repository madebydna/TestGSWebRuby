class UpdateQueue < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'update_queue'
  attr_accessible :source, :status, :update_blob, :notes, :updated, :priority

  scope :todo, -> { where(status: 'todo') }

  def self.oldest_item_in_todo
    UpdateQueue.where(status: 'todo').order(:created).first
  end

  def self.most_recent_failure
    UpdateQueue.where(status: 'failed').order('updated desc').first
  end

  def self.created_in_last_week
    UpdateQueue.where("created > ?", 1.weeks.ago).group(:source).count
  end

  def self.failed_within_24_hrs
    UpdateQueue.where(status: 'failed').where("updated > ?", 1.days.ago).group(:source).count
  end

  def self.failed_within_2_weeks
    UpdateQueue.where(status: 'failed').where("updated > ?", 2.weeks.ago).group(:source).count
  end

  def self.done_vs_todo_per_source
    sql=%(
      select todos.source, time_started, queued, IFNULL(done, 0) as done, (queued/(queued+done))*100 as percent_done from
      (select source, count(*) as queued
      from update_queue
      where status = 'TODO'
      and source is not null
      and created > "#{2.weeks.ago}"
      group by source) todos
      left join
      (select source, count(*) as done, min(created) as time_started
      from update_queue
      where status = 'DONE'
      and source is not null
      and created > "#{2.weeks.ago}"
      group by source) dones
      on todos.source = dones.source
    )
    results = UpdateQueue.connection.exec_query(sql).to_a
    results.each do |entry|
      if entry['time_started']
        time_started = entry['time_started']
        elapsed_seconds = Time.zone.now - time_started
        average_seconds = elapsed_seconds / entry['done']
        seconds_left = average_seconds * entry['queued']
        est_completion_time = Time.zone.now + seconds_left
        entry['average_seconds'] = average_seconds
        entry['est_completion_time'] = est_completion_time
      end
    end
    results
  end

  def self.sample_data
    [
        {
            source: 'osp',
            update_blob: {
                Enrollment: [
                    {
                        action: :disable,
                        entity_type: :school,
                        entity_id: 23,
                        entity_state: 'AK',
                        value: 34
                    }
                ],
                Ethnicity: [
                    {
                        action: :disable,
                        entity_type: :school,
                        entity_id: 23,
                        entity_state: 'AK',
                        breakdown: 'Hispanic',
                        value: 66
                    },
                    {
                        action: :disable,
                        entity_type: :school,
                        entity_id: 23,
                        entity_state: 'AK',
                        breakdown: 'White',
                        value: 34
                    }
                ]
            }.to_json
        },
        {
            source: 'osp',
            update_blob: {
                Enrollment: [
                    {
                        action: :disable,
                        entity_type: :school,
                        entity_id: 12,
                        entity_state: 'AK',
                        value: 3400,
                        grade: 5,
                        year: 2012
                    }
                ],
                boys_sports: [
                    {
                        action: :disable,
                        entity_type: :school,
                        entity_id: 12,
                        entity_state: 'AK',
                        member_id: 2,
                        value: 'swimming'
                    },
                    {
                        action: :disable,
                        entity_type: :school,
                        entity_id: 12,
                        member_id: 2,
                        entity_state: 'AK',
                        value: 'basketball'
                    }
                ]
            }.to_json
        },
        {
            source: 'invalid_json_test',
            update_blob: 'not json'
        },
        {
            source: 'bad_ethnicity_test',
            update_blob: {
                Enrollment: [
                    {
                        action: :disable,
                        entity_type: :school,
                        entity_id: 12,
                        entity_state: 'AK',
                        value: 34,
                        breakdown: 'Orc',
                    }
                ]
            }.to_json
        },
        {
            source: 'bad_subject_test',
            update_blob: {
                Enrollment: [
                    {
                        entity_type: :school,
                        entity_id: 12,
                        entity_state: 'AK',
                        value: 3400,
                        subject: 'Jumping jacks',
                        year: 2012
                    }
                ]
            }.to_json
        }
    ]
  end

  def self.seed_sample_data!
    sample_data.each do |data|
      UpdateQueue.create!(data)
    end
  end
end
