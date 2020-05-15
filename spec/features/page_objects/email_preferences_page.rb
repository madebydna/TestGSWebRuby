class EmailPreferencesPage < SitePrism::Page
  set_url '/preferences/'

  class Grades < SitePrism::Section
    element :pk, '.js-gradeCheckbox[data-grade="PK"]'
    element :kg, '.js-gradeCheckbox[data-grade="KG"]'
    element :first_grade, '.js-gradeCheckbox[data-grade="1"]'
    element :second_grade, '.js-gradeCheckbox[data-grade="2"]'
    element :third_grade, '.js-gradeCheckbox[data-grade="3"]'
    element :forth_grade, '.js-gradeCheckbox[data-grade="4"]'
    element :fifth_grade, '.js-gradeCheckbox[data-grade="5"]'
    element :sixth_grade, '.js-gradeCheckbox[data-grade="6"]'
    element :seventh_grade, '.js-gradeCheckbox[data-grade="7"]'
    element :eighth_grade, '.js-gradeCheckbox[data-grade="8"]'
    element :ninth_grade, '.js-gradeCheckbox[data-grade="9"]'
    element :tenth_grade, '.js-gradeCheckbox[data-grade="10"]'
    element :eleventh_grade, '.js-gradeCheckbox[data-grade="11"]'
    element :twelfth_grade, '.js-gradeCheckbox[data-grade="12"]'
  end

  class District < SitePrism::Section
    element :checkbox, 'div.js-subscriptionCheckbox'
    element :name, 'div.subtitle-md'
    section :grades, Grades, :xpath, './div[2]'

    def subscribed?
      checkbox[:class].include?("active")
    end
  end

  class DistrictGrades < SitePrism::Section
    sections :districts, District, '.mtm'

    def get_district(district)
      districts.detect do |el|
        el.name.text =~ /#{district.name}/i
      end
    end
  end

  class EnglishSubscriptions < SitePrism::Section
    element :weekly, 'div.js-checkbox[data-list="greatnews"]'
    element :sponsor, 'div.js-checkbox[data-list="sponsor"]'
    element :grade_by_grade , 'div.js-checkbox[data-list="greatkidsnews"]'
    element :educators , 'div.js-checkbox[data-list="teacher_list"]'

    section :grades, Grades, '.overall_grades'
    section :district_grades, DistrictGrades, '.district_grades'
  end

  class SpanishSubscriptions < SitePrism::Section
    element :weekly, 'div.js-checkbox[data-list="greatnews"]'
    section :grades, Grades, '.overall_grades'
    element :grade_by_grade , 'div.js-checkbox[data-list="greatkidsnews"]'
    section :district_grades, DistrictGrades, '.district_grades'
  end

  class SchoolUpdates < SitePrism::Section
    elements :school_subscriptions, 'div.js-mssSubscriptionCheckbox'

    def get_subscription(school)
      school_subscriptions.detect do |el|
        el[:class].include?("active") &&
        el["data-state"] == school.state &&
        el["data-school-id"].to_i == school.id
      end
    end
  end

  def subscribed?(el)
    el[:class].include?("active")
  end

  section :english, EnglishSubscriptions, '.news-en'
  section :spanish, SpanishSubscriptions, '.news-es'
  section :school_updates, SchoolUpdates, '.mtm', text: /School Updates/

  element :spanish_tab, 'a.tab-news-es'
  element :english_tab, 'a.tab-news-en'
  element :submit_btn, 'button', text: /Save changes/
  element :unsubscribe_link, 'a', text: 'Unsubscribe'
end