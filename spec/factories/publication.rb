FactoryGirl.define do

  factory :publication do
    id 1
    content_type 'Article'
    language 'EN'
    content ({
      "title" => "Umoja's children",
      "licensorName" => nil,
      "sidebar" => nil,
      "dateCreated" => "2009-08-19T21:04:57Z",
      "id" => 1571,
      "lastUpdated" => "2009-11-17T23:56:20Z",
      "sortablePrimaryKategory" => "Academic Skills",
      "body" => <<-eos.gsub(/\n | \s/, "")
        <p><em>Learn more about the Umoja Student Development Corporation and
        Executive Director Lila Leff's tips for</em> <a href=\"content://Article#1570\"
        class=\"internal-gs\">feeding young minds</a>.</p>\n<h2>Corey Hobart*</h2>\n<p
        class=\"MsoNormal\">Corey Hobart is the son of a single mom, who spends much of her
        time caring for a severely disabled sister. As a freshman, Corey wandered into the Umoja
        offices and asked if it was too soon to apply for college admission. Instead of handing
        him some brochures and telling him to come back as a senior, Leff took him to several
        college campuses and had him talk to kids who came from similar backgrounds. Corey
        signed up for leadership programs that taught him to debate persuasively and use varied
        methods of researching an issue. He went on to give presentations on issues such as
        police brutality, race relations, and the pitfalls of public transportation in
        <st1:place w:st=\"on\">East Lawndale</st1:place> to local community groups and boards.
        </p>\n<p class=\"MsoNormal\">Corey recently graduated from <st1:place w:st=\"on\">
        <st1:placename w:st=\"on\">Ohio</st1:placename> <st1:placetype w:st=\"on\">State</st1:
        placetype></st1:place> University and has just completed his first year as an <a
        class=\"external\" target=\"_blank\" href=\"http://www.americorps.gov/\">AmeriCorps</a>
        volunteer, teaching in a grade school. Next year he&rsquo;ll teach at a <st1:city
        w:st=\"on\"><st1:place w:st=\"on\">Chicago</st1:place></st1:city> high school. His
        career aspirations currently swing between becoming a chef and running for president
        of the <st1:country-region w:st=\"on\"><st1:place w:st=\"on\">United   States</st1
        :place></st1:country-region>.<o:p></o:p></p>\n<h2>Keisha Jackson*</h2>\n<p class=\"M
        soNormal\">Keisha Jackson was Manley&rsquo;s valedictorian this year, but without
        Umoja she could have easily ended up dropping out. Socially awkward and artistic,
        she was bullied at school, and her tumultuous home life gave her little support
        .<span style=\"\"> </span>After bouncing around from state to state, in and out of
        foster care, Keisha had moved in her with her dad and eight siblings.<o:p></o:p></
        p>\n<p class=\"MsoNormal\">Umoja helped Keisha develop skills around friendship &mdash
        ;<span style=\"\"> </span>talking with her to help her understand her interactions
        with others<span style=\"color: red;\">. </span>From there she got deeply involved
        in community service. She won scholarships to an arts program in Wyoming and a
        service program on a Montana Indian reservation, working with local teens to build
        a preschool.</p>\n<p class=\"MsoNormal\"><o:p></o:p>This fall Keisha is headed to
        <st1:placename w:st=\"on\">Trinity</st1:placename> <st1:placetype w:st=\"on\">
        College</st1:placetype> in <st1:place w:st=\"on\"><st1:state w:st=\"on\">Connecticut
        </st1:state></st1:place>, courtesy of the Posse Foundation. The foundation gives full
        four-year scholarships, sending a group of students of color to a predominantly
        white school and giving them additional support &mdash; weekly pre-collegiate
        meetings to build academic, communication, and leadership skills and, once they&rsquo;re
        on campus, frequent group and individual meetings with mentors and retreats to
        discuss campus issues.</p>\n<p class=\"MsoNormal\"><em>*Names have been changed
        to preserve students' privacy.</em></p>
        eos
    })
  end
end