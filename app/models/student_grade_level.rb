class StudentGradeLevel < ActiveRecord::Base
  self.table_name = 'student'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  validates_presence_of :grade, :member_id

  validates :grade, inclusion: { in: ['PK','pk','KG','kg','1','2','3','4','5','6','7','8','9','10','11','12'],
                                message: "You must specify a valid grade" }

end