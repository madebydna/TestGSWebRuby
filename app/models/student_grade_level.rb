class StudentGradeLevel < ActiveRecord::Base
  self.table_name = 'student'

  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'

  validates_presence_of :grade, :member_id

  validates :grade, inclusion: { in: ['PK','KG','1','2','3','4','5','6','7','8','9','10','11','12','13','UG','AE'],
                                message: "You must specify a valid grade" }

# TODO some sorta regex
  # validates_format_of :grade,

end