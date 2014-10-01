module LevelCodeConcerns

#Find Level of School
  def is_k8
    level_code_string=level_code.to_s
    if   level_code_string.include? "m" or level_code_string.include? "e" or level_code_string.include? "p"
      true
    else
      false
    end


  end

  def is_high_school
    level_code_string=level_code.to_s
    if  level_code_string.include? "h"
      true
    else
      false
    end
  end


end