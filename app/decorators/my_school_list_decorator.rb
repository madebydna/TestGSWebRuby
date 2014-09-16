class MySchoolListDecorator < SchoolProfileDecorator
  include GradeLevelConcerns

  decorates :school
  delegate_all

end