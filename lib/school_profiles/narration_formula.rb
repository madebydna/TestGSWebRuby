module SchoolProfiles
  class NarrationFormula

    def low_income_grad_rate_and_entrance_requirements(*args)
      low_income_test_scores_calculate_column(*args)
    end

    def low_income_test_scores_calculate_column(st_li_avg, sch_li_avg, st_all_avg)
      # margin of error
      st_li_moe  = 1
      st_all_moe = 1

      st_li_avg = numberfy(st_li_avg)
      sch_li_avg = numberfy(sch_li_avg)
      st_all_avg = numberfy(st_all_avg)

      # Column logic
      if (sch_li_avg - (st_li_avg - st_li_moe) < 0)
        '1'
      elsif ((sch_li_avg - (st_li_avg - st_li_moe) >= 0) && (sch_li_avg - (st_li_avg + st_li_moe) <= 0))
        '2'
      elsif ((sch_li_avg - (st_li_avg + st_li_moe) > 0) && (sch_li_avg - (st_all_avg - st_all_moe) < 0))
        '3'
      elsif ((sch_li_avg - (st_all_avg - st_all_moe) >= 0))
        '4'
      end
    end

    def numberfy(value)
      if value.is_a? String
        value.scan(/\d+/).first.to_f
      else
        value
      end
    end

  end
end
