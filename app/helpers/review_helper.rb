
module ReviewHelper

  def click_to_add_review_answer_fields(response_type, f, association, response_value)
    new_object = f.object.send(association).klass.new
    id = Time.now.to_f
    fields = f.fields_for(:review_answers, new_object, child_index: id) do |builder|
      render "shared/reviews/modules/input/hidden_#{response_type}", response_value: response_value, f: builder, id: id
    end
    render "shared/reviews/modules/input/display_#{response_type}", response_value: response_value, fields: fields
  end


  def question_response_div(response_count, index, response_type, f, association, response_value)
    klasses = question_response_column_klass_key(response_count)
    if response_count == 5 && index == 0
      klasses += question_response_offset_klass_key(response_count)
    end
    klasses += " mtm"
    content_tag(:div, click_to_add_review_answer_fields(response_type, f, association, response_value), class: klasses)
  end

  def question_response_column_klass_key(response_count)
    klass_key = {
        "2" => "col-xs-6 col-lg-6",
        "3" => "col-xs-4 col-lg-4",
        "4" => "col-xs-6 col-sm-3",
        "5" => "col-xs-4 col-sm-2",
        "6" => "col-xs-6 col-sm-4 col-lg-2",
        "7" => "col-xs-4 col-sm-3",
        "8" => "col-xs-6 col-sm-3",
        "9" => "col-xs-4"
    }
    klass_key[response_count.to_s]
  end

  def question_response_offset_klass_key(response_count)
    klass_key = {
        "5" => " col-sm-offset-1"
    }
    klass_key[response_count.to_s]
  end

end
