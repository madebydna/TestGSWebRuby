module SchoolProfiles
  class NarrationFormula

    def low_income_grad_rate_and_entrance_requirements(sch_avg, st_avg, st_moe, very_low)
      if (st_avg - st_moe) - sch_avg > very_low
        '1'
      elsif (((st_avg - st_moe) - sch_avg <= very_low) && ((st_avg - st_moe) - sch_avg > 0))
        '2'
      elsif (((st_avg - st_moe) - sch_avg <= 0) && ((st_avg + st_moe) - sch_avg >= 0))
        '3'
      elsif ((st_avg + st_moe) - sch_avg < 0)
        '4'
      end
    end

    def low_income_test_scores_calculate_column(st_nli_avg, st_li_avg, sch_li_avg, st_all_avg)
      # margin of error
      st_li_moe  = 1
      st_all_moe = 1
      st_nli_moe = 1

      # Column logic
      if (sch_li_avg - (st_li_avg - st_li_moe) < 0)
        '1'
      elsif ((sch_li_avg - (st_li_avg - st_li_moe) >= 0) && (sch_li_avg - (st_li_avg + st_li_moe) <= 0))
        '2'
      elsif ((sch_li_avg - (st_li_avg + st_li_moe) > 0) && (sch_li_avg - (st_all_avg - st_all_moe) < 0))
        '3'
      elsif ((sch_li_avg - (st_all_avg - st_all_moe) >= 0) && (sch_li_avg - (st_nli_avg - st_nli_moe) <= 0))
        '4'
      elsif (sch_li_avg - (st_nli_avg - st_nli_moe) >= 0)
        '5'
      end
    end

    def low_income_test_scores_calculate_row(st_nli_avg, st_li_avg, sch_li_avg, sch_nli_avg)
      # margin of error
      st_diff_moe = 1

      #   Row logic
      if ((sch_li_avg - sch_nli_avg) - ((st_li_avg - st_nli_avg) - st_diff_moe) < 0)
        '3'
      elsif (((sch_li_avg - sch_nli_avg) - ((st_li_avg - st_nli_avg) - st_diff_moe) >= 0) && ((sch_li_avg - sch_nli_avg) - ((st_li_avg - st_nli_avg) + st_diff_moe) <= 0))
        '2'
      elsif ((sch_li_avg - sch_nli_avg) - ((st_li_avg - st_nli_avg) + st_diff_moe) > 0)
        '1'
      end
    end

  end
end