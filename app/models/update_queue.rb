class UpdateQueue < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'update_queue'
  attr_accessible :source, :status, :update_blob, :notes, :updated, :priority

  scope :todo, -> { where(status: 'todo') }

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
