class ReviewQuestionDecorator < Draper::Decorator

  decorates :review_question
  delegate_all

  def placeholder_text
    placeholder_text = placeholder_prefix_text
    # if there is no matching key will default to prefix statement
    placeholder_text += placeholder_question_key[topic.name] || '.'
    placeholder_text += placeholder_optional_text if !overall?
    placeholder_text
  end

  private

  def placeholder_prefix_text
    'Please share why you feel this way'
  end

  def placeholder_optional_text
    ' (Optional. Please do not repeat exact text from another review.)'
  end

  def placeholder_question_key
    {
     'Overall'=>'.',
     'Honesty'=> '. How do you see honesty, integrity, and fairness developed or not developed in students?' ,
     'Empathy'=> '. How do you see compassion, caring, and empathy developed or not developed in students?',
     'Respect'=> '. How do you see respect developed or not developed in students?',
     'Grit'=> '. How do you see persistence, grit, and determination developed or not developed in students?',
     'Homework'=> ' about homework.' ,
     'Teachers'=> ' about teachers.'
    }
  end
end