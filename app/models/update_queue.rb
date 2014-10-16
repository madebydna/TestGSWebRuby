class UpdateQueue < ActiveRecord::Base
  db_magic :connection => :gs_schooldb
  self.table_name = 'update_queue'
  attr_accessible :source, :status, :update_blob, :updated

  scope :todo, -> { where(status: 'todo') }

  def self.sample_data
    [
        {
            Enrollment: [
                {
                    entity_type: :school,
                    entity_id: 23,
                    entity_state: 'AK',
                    value: 34
                }
            ],
            Ethnicity: [
                {
                    entity_type: :school,
                    entity_id: 23,
                    entity_state: 'AK',
                    breakdown: 'latino',
                    value: 66
                },
                {
                    entity_type: :school,
                    entity_id: 23,
                    entity_state: 'AK',
                    breakdown: 'white',
                    value: 34
                }
            ]
        },
        {
            Enrollment: [
                {
                    entity_type: :school,
                    entity_id: 12,
                    entity_state: 'AL',
                    value: 3400,
                    grade: 5,
                    year: 2012
                }
            ],
            boys_sports: [
                {
                    entity_type: :school,
                    entity_id: 12,
                    entity_state: 'AL',
                    value: 'swimming'
                },
                {
                    entity_type: :school,
                    entity_id: 12,
                    entity_state: 'AL',
                    value: 'basketball'
                }
            ]
        }
    ]
  end

  def self.seed_sample_data!
    sample_data.each do |blob|
      UpdateQueue.create!(source: 'osp', update_blob: blob.to_json)
    end
  end
end
