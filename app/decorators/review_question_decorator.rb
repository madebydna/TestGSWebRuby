class ReviewQuestionDecorator < Draper::Decorator

  decorates :review_question
  delegate_all

  def placeholder
    placeholder_text = placeholder_prefix
    # if there is no matching key will default to prefix statement
    placeholder_text += placeholder_question_key[id.to_s] || '.'
    placeholder_text += placeholder_optional_text if id.to_i > 1
    placeholder_text
  end

  private

  def placeholder_prefix
    'Please share why you feel this way'
  end

  def placeholder_optional_text
    ' (Optional. Please do not repeat exact text from another review.)'
  end

  def placeholder_question_key
    {'1'=>'.',
     '2'=> '. How do you see honesty, integrity, and fairness developed or not developed in students?' ,
     '3'=> '. How do you see compassion, caring, and empathy developed or not developed in students?',
     '4'=> '. How do you see respect developed or not developed in students?',
     '5'=> '. How do you see persistence, grit, and determination developed or not developed in students?',
     '6'=> ' about homework.' ,
     '7'=> ' about teachers.'
    }
  end
end