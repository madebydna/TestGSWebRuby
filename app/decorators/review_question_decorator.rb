class ReviewQuestionDecorator < Draper::Decorator

  decorates :review_question
  delegate_all

  def placeholder_text
    placeholder_text = placeholder_prefix_text
    # if there is no matching key will default to prefix statement
    placeholder_text += placeholder_question_key[topic.name] || '. '
    placeholder_text += placeholder_optional_text if !overall?
    placeholder_text
  end

  private

  def placeholder_prefix_text
    I18n.t('decorators.review_question_decorator.placeholder_prefix')
  end

  def placeholder_optional_text
    I18n.t('decorators.review_question_decorator.optional_suffix')
  end

  def placeholder_question_key
    {
     'Overall'=> I18n.t('decorators.review_question_decorator.overall_placeholder_text'),
     'Honesty'=> I18n.t('decorators.review_question_decorator.honesty_placeholder_text'),
     'Empathy'=> I18n.t('decorators.review_question_decorator.empathy_placeholder_text'),
     'Respect'=> I18n.t('decorators.review_question_decorator.respect_placeholder_text'),
     'Grit'=> I18n.t('decorators.review_question_decorator.grit_placeholder_text'),
     'Homework'=> I18n.t('decorators.review_question_decorator.homework_placeholder_text'),
     'Teachers'=> I18n.t('decorators.review_question_decorator.teachers_placeholder_text')
    }
  end
end
