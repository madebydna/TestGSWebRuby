class SchoolReviews
    def self.calc_review_data(school_reviews_all)

      # fetches all reviews
      #school_reviews_all = school.reviews
      #store star counts for overall
      star_counts = [ 0, 0, 0, 0, 0, 0 ]
      #store resulting average and components for calculating them
      rating_averages = Hashie::Mash.new(
          {
              overall:   { avg_score: 0, total: 0, counter: 0 },
              principal: { avg_score: 0, total: 0, counter: 0 },
              teacher:   { avg_score: 0, total: 0, counter: 0 },
              parent:    { avg_score: 0, total: 0, counter: 0 }
          }
      )
      review_filter_totals = Hashie::Mash.new(
          {
              all: school_reviews_all.size,
              parent: 0,
              student: 0
          }
      )

      school_reviews_all.each do |review|
        #use quality or p_overall(for prek) for star counts and overall score.OM-209
        overall_rating = 'decline'
        if review.quality != 'decline'
          overall_rating = review.quality
        elsif review.p_overall != 'decline'
          overall_rating = review.p_overall
        end

        if overall_rating != 'decline'
          star_counts[overall_rating.to_i] = star_counts[overall_rating.to_i]+1
        end
        if review.who == 'parent'
          review_filter_totals.parent = review_filter_totals.parent+1
        end
        if review.who == 'student'
          review_filter_totals.student = review_filter_totals.student+1
        end
        set_reviews_values rating_averages.overall, overall_rating
        set_reviews_values rating_averages.principal, review.principal
        set_reviews_values rating_averages.teacher, review.teachers
        set_reviews_values rating_averages.parent, review.parents
      end
      determine_star_average rating_averages.overall
      determine_star_average rating_averages.principal
      determine_star_average rating_averages.teacher
      determine_star_average rating_averages.parent

      Hashie::Mash.new({:star_counts => star_counts,  :rating_averages => rating_averages, :review_filter_totals => review_filter_totals   })

    end

    def self.set_reviews_values (set_obj,  set_value )
      if set_value != 'decline'
        set_obj.total = set_obj.total + set_value.to_i
        set_obj.counter = set_obj.counter + 1
      end
    end

    def self.determine_star_average ( set_obj )
      if set_obj.counter != 0
        set_obj.avg_score = (set_obj.total.to_f / set_obj.counter.to_f).round
      end
    end
end