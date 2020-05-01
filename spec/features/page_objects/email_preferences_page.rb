class EmailPreferencesPage < SitePrism::Page
  set_url '/preferences/'

  class Grades < SitePrism::Section
    element :pk, '.js-gradeCheckbox', text: 'PK'
    element :kg, '.js-gradeCheckbox', text: 'KG'
    element :first_grade, '.js-gradeCheckbox', text: '1st'
    element :second_grade, '.js-gradeCheckbox', text: '2nd'
    element :third_grade, '.js-gradeCheckbox', text: '3rd'
    element :forth_grade, '.js-gradeCheckbox', text: '4th'
    element :fifth_grade, '.js-gradeCheckbox', text: '5th'
    element :sixth_grade, '.js-gradeCheckbox', text: '6th'
    element :seventh_grade, '.js-gradeCheckbox', text: '7th'
    element :eighth_grade, '.js-gradeCheckbox', text: '8th'
    element :ninth_grade, '.js-gradeCheckbox', text: '9th'
    element :tenth_grade, '.js-gradeCheckbox', text: '10th'
    element :eleventh_grade, '.js-gradeCheckbox', text: '11th'
    element :twelfth_grade, '.js-gradeCheckbox', text: '12th'
  end

  class EnglishSubscriptions < SitePrism::Section
    element :weekly, 'div.js-checkbox[data-list="greatnews"]'
    element :sponsor, 'div.js-checkbox[data-list="sponsor"]'
    element :grade_by_grade , 'div.js-checkbox[data-list="greatkidsnews"]'
    element :educators , 'div.js-checkbox[data-list="teacher_list"]'

    section :grades, Grades, :xpath, './div[2]'
  end

  class SpanishSubscriptions < SitePrism::Section
    #TODO: fill in
  end

  def subscribed?(el)
    el[:class].include?("active")
  end

  section :english, EnglishSubscriptions, '.news-en'
  section :spanish, SpanishSubscriptions, '.news-es'
end