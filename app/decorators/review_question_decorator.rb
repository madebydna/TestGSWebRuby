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
    'Please share why you feel this way'
  end

  def placeholder_optional_text
    "\n(Optional. There\'s no need to repeat text from another review.)"
  end

  def placeholder_question_key
    {
     'Overall'=>'. ',
     'Honesty'=> '. How do you feel this school develops honesty, integrity, and fairness in students? ' ,
     'Empathy'=> '. How do you feel this school develops compassion, caring, and empathy in students? ',
     'Respect'=> '. How do you feel this school develops respect in students? ',
     'Grit'=> '. How do you feel this school develops persistence, grit, and determination in students? ',
     'Homework'=> ' about homework at this school. ',
     'Teachers'=> ' about teachers at this school. '
    }
  end
end