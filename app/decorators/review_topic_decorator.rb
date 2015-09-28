class ReviewTopicDecorator < Draper::Decorator

  decorates :review_topic
  delegate_all

  def header
    topic_key[id.to_s][:header]
  end

  def subheading
    topic_key[id.to_s][:subheading]
  end

  def sample_review 
    topic_key[id.to_s][:sample_review]
  end

  def sample_review_school
    topic_key[id.to_s][:sample_review_school]
  end

  def sample_review_city_and_state
    topic_key[id.to_s][:sample_review_city_and_state]
  end

  def sample_review_intro
    "A #{ student? ? 'student' : 'parent' }  at <span class='open-sans_b'> #{sample_review_school}</span> in #{sample_review_city_and_state} said:"
  end

  def student?
    topic_key[id.to_s][:student]
  end

  def topic_key
    {'1'=> {header: "Review your school!",
               subheading: "Families want to hear your honest opinion about your school.",
               sample_review_school: 'Noah Webster Academy',
               sample_review_city_and_state: 'Orem, UT',
               sample_review: "Our daughter ... has made leaps and bounds academically, and 
               socially. She is safe, appreciated by her teachers and peers, and feels that 
               all the kids are equals" },
     '2'=> {header: "How does your school teach honesty?",
               subheading: "Search for your school to share your thoughts.",
               sample_review_school: 'M E T S Charter School',
               sample_review_city_and_state: 'Jersey City, NJ',
               sample_review: "... when it comes to my son, I like that he's held 
               accountable for his actions. Every mother wants to raise an honest 
               child with integrity." },
     '3'=> {header: "How does your school build empathy?",
               subheading: "Search for your school to share your thoughts.",
               sample_review_school: 'St John Catholic School',
               sample_review_city_and_state: 'Encinitas, CA',
               sample_review: "From day one, there is a strong emphasis on service 
               to others, giving back to the community and helping those who are less 
               fortunate." },
     '4'=> {header: "How does your school encourage respect?",
               subheading: "Search for your school to share your thoughts.",
               sample_review_school: 'Frontier School Of Innovation',
               sample_review_city_and_state: 'Kansas City, MO',
               sample_review: "As a parent, I am extremely pleased with the standards 
               the school has for respect among student-student, student-teacher, 
               teacher-student, staff-others." },
     '5'=> {header: "How does your school develop persistence?",
            subheading: "Search for your school to share your thoughts.",
               sample_review_school: 'North Seattle French School',
               sample_review_city_and_state: 'Seattle, WA',
               sample_review: "But through gentle, caring exposure and lots of support, 
               kids learn that they can start out knowing nothing and bit by bit, become 
               really proficient." },
     '6'=> {header: "How is homework at your school?",
                subheading: "Too much? Too little? Share you opinion.",
               student: true,
               sample_review_school: 'Walden Grove High School',
               sample_review_city_and_state: 'Sahuarita, AZ',
               sample_review: "Many teachers give homework on a semi-weekly or weekly 
               basis while math teachers usually give homework every night. This creates 
               a good balance of homework ..." },
     '7'=> {header: "Share your thoughts on teachers.",
                subheading: "Great schools begin with great teachers.  How are yours?",
               sample_review_school: 'John Adams Elementary School',
               sample_review_city_and_state: 'Alexandria, VA,',
               sample_review: "The teachers are constantly striving to learn new ways to reach 
               out to the students." },
     '8'=> {header: "Are you grateful for your school?",
               subheading: "Share why. Find your school to start.",
               sample_review_school: 'Wildwood Elementary School',
               sample_review_city_and_state: 'Westland, MI',
               sample_review: "Thank you ... for investing in my daughter's future. 
               You are amazing teachers!!!" }
    }

    end
end
