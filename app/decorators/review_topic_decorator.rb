class ReviewTopicDecorator < Draper::Decorator

  decorates :review_topic
  delegate_all

  def header
    topic_key[id.to_s][:header]
  end

  def subheading
    topic_key[id.to_s][:subheading]
  end

  def topic_key
    {'1'=> {header: "Review your school!",
               subheading: "Families want to hear your honest opinion about your school." },
     '2'=> {header: "How does your school teach honesty?",
               subheading: "Search for your school to share your thoughts."},
     '3'=> {header: "How does your school build empathy?",
               subheading: "Search for your school to share your thoughts."},
     '4'=> {header: "How does your school encourage respect?",
               subheading: "Search for your school to share your thoughts."},
     '5'=> {header: "How does your school develop persistence?",
            subheading: "Search for your school to share your thoughts."},
     '6'=> {header: "How is homework at your school?",
                subheading: "Too much? Too little? Share you opinion."},
     '7'=> {header: "Share your thoughts on teachers.",
                subheading: "Great schools begin with great teachers.  How are yours?"}
    }
    end
end
