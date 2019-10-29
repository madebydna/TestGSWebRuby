class ReviewTopicDecorator < Draper::Decorator

  decorates :review_topic
  delegate_all

  def valid_topic_config?
    topic_key[id.to_s].present?
  end

  def header
    return nil unless valid_topic_config?
    topic_key[id.to_s][:header]
  end

  def subheading
    return nil unless valid_topic_config?
    topic_key[id.to_s][:subheading]
  end

  def sample_review 
    return nil unless valid_topic_config?
    topic_key[id.to_s][:sample_review]
  end

  def sample_review_school
    return nil unless valid_topic_config?
    topic_key[id.to_s][:sample_review_school]
  end

  def sample_review_city_and_state
    return nil unless valid_topic_config?
    "#{topic_key[id.to_s][:city]}, #{topic_key[id.to_s][:state]}"
  end

  def sample_review_intro
    return nil unless valid_topic_config?
    "A #{ student? ? 'student' : 'parent' }  at <a class='link-darkgray' href='#{school_url}'><span class='open-sans_b'>#{sample_review_school}</span></a> in #{sample_review_city_and_state} said:"
  end

  def city
    return nil unless valid_topic_config?
    topic_key[id.to_s][:city]
  end

  def state_name
    return nil unless valid_topic_config?
    States.state_name(topic_key[id.to_s][:state])
  end

  def school_id
    return nil unless valid_topic_config?
    topic_key[id.to_s][:school_id]
  end

  def student?
    return nil unless valid_topic_config?
    topic_key[id.to_s][:student]
  end

  def school_url
    h.school_reviews_path(nil, id: school_id, state_name: state_name, city: city, name: sample_review_school, anchor: 'Reviews')
  end

  def topic_key
    {
      '1' => {
        city: 'Orem',
        state: 'UT',
        header: I18n.t('decorators.review_topic_decorator.topic_1_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_1_subheading'),
        sample_review_school: 'Noah Webster Academy',
        sample_review: "Our daughter ... has made leaps and bounds academically, and
         socially. She is safe, appreciated by her teachers and peers, and feels that
         all the kids are equals",
        school_id: 1847
      },
      '2' => {
        city: 'Jersey City',
        state: 'NJ',
        header: I18n.t('decorators.review_topic_decorator.topic_2_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_2_subheading'),
        sample_review_school: 'M E T S Charter School',
        sample_review: "... when it comes to my son, I like that he's held
             accountable for his actions. Every mother wants to raise an honest
             child with integrity.",
        school_id: 7114
      },
      '3' => {
        city: 'Encinitas',
        state: 'CA',
        header: I18n.t('decorators.review_topic_decorator.topic_3_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_3_subheading'),
        sample_review_school: 'St John Catholic School',
        sample_review: "From day one, there is a strong emphasis on service
             to others, giving back to the community and helping those who are less
             fortunate.",
        school_id: 8381
      },
      '4' => {
        city: 'Kansas City',
        state: 'MO',
        header: I18n.t('decorators.review_topic_decorator.topic_4_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_4_subheading'),
        sample_review_school: 'Frontier School Of Innovation',
        sample_review: "As a parent, I am extremely pleased with the standards
         the school has for respect among student-student, student-teacher,
         teacher-student, staff-others.",
        school_id: 5569
      },
      '5' => {
        city: 'Seattle',
        state: 'WA',
        header: I18n.t('decorators.review_topic_decorator.topic_5_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_5_subheading'),
        sample_review_school: 'North Seattle French School',
        sample_review: "But through gentle, caring exposure and lots of support,
           kids learn that they can start out knowing nothing and bit by bit, become
           really proficient.",
        school_id: 4967
      },
      '6' => {
        city: 'Sahuarita',
        state: 'AZ',
        header: I18n.t('decorators.review_topic_decorator.topic_6_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_6_subheading'),
        student: true,
        sample_review_school: 'Walden Grove High School',
        sample_review: "Many teachers give homework on a semi-weekly or weekly
         basis while math teachers usually give homework every night. This creates
         a good balance of homework ...",
        school_id: 5599
      },
      '7' => {
        city: 'Alexandria',
        state: 'VA',
        header: I18n.t('decorators.review_topic_decorator.topic_7_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_7_subheading'),
        sample_review_school: 'John Adams Elementary School',
        sample_review: "The teachers are constantly striving to learn new ways to reach
           out to the students.",
        school_id: 74
      },
      '8' => {
        city: 'West Allis',
        state: 'WI',
        header: I18n.t('decorators.review_topic_decorator.topic_8_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_8_subheading'),
        sample_review_school: 'Good Shepherds Lutheran School',
        sample_review: "I would like to thank the school secretary for her warm smile and
          welcoming personality. She brightens my day...",
        school_id: 2715
      },
      '9' => {
        city: 'Jersey City',
        state: 'NJ',
        header: I18n.t('decorators.review_topic_decorator.topic_2_header'),
        subheading: I18n.t('decorators.review_topic_decorator.topic_2_subheading'),
        sample_review_school: 'M E T S Charter School',
        sample_review: "... when it comes to my son, I like that he's held
             accountable for his actions. Every mother wants to raise an honest
             child with integrity.",
        school_id: 7114
      },

    }

    end
end
