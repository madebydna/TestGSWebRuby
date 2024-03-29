#!/bin/env ruby
# encoding: utf-8

articles_value = "{ articles: [ { heading:'How to spot a world-class education', content:'In an exclusive adaptation from her new book, \"The Smartest Kids in the World,\" Amanda Ripley encapsulates her three years studying high-performing schools around the globe into a few powerful guidelines.', articlepath:'/school-choice/7624-amanda-ripley-how-to-spot-world-class-education.gs', articleImagePath:'/res/img/cityHubs/1_Article_1.png', newwindow:'false' } ,{ heading:'Education Detroit', content:'A new magazine devoted to helping Detroit parents/guardians give kids an academic edge and find standout school options', articlepath:'http://www.metroparent.com/Metro-Parent/Education-Detroit/', articleImagePath:'/res/img/cityHubs/1_Article_2.png', newwindow:'true' } , { heading:'Excellent News!', content:'Videos on what\\'s working in Detroit schools and information about the choices available for your children', articlepath:'http://vimeo.com/channels/590307', articleImagePath:'/res/img/cityHubs/1_Article_3.png', newwindow:'true' } ] } "
partners_value = "{ heading: 'Detroit Education Community', partnerLogos: [ " \
 "{ logoPath:'/res/img/cityHubs/1_Partner_0.png', partnerName:'Black Family Development, Inc.', anchoredLink:'?tab=Community' }" \
  ", { logoPath:'/res/img/cityHubs/1_Partner_1.png', partnerName:'Cornerstone Charters', anchoredLink:'?tab=Education' } , { logoPath:'/res/img/cityHubs/1_Partner_2.png', partnerName:'Detroit Edison Public School Academy', anchoredLink:'?tab=Education' } , { logoPath:'/res/img/cityHubs/1_Partner_3.png', partnerName:'Detroit Parent Network', anchoredLink:'?tab=Community' } , { logoPath:'/res/img/cityHubs/1_Partner_4.png', partnerName:'Detroit Public Schools', anchoredLink:'?tab=Education' },"\
  "{ logoPath:'/res/img/cityHubs/1_Partner_5.png', partnerName:'Detroit Public Television', anchoredLink:'?tab=Community' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_6.png', partnerName:'Detroit Regional Chamber', anchoredLink:'?tab=Community' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_7.png', partnerName:'Education Achievement Authority', anchoredLink:'?tab=Education' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_8.png', partnerName:'Kresge Foundation', anchoredLink:'?tab=Funders' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_9.png', partnerName:'The Skillman Foundation', anchoredLink:'?tab=Funders' }," \
  "{ logoPath:'/res/img/cityHubs/1_Partner_10.png', partnerName:'United Way for Southeastern Michigan', anchoredLink:'?tab=Community' }]  }"
sponsor_value = "{ sponsor: {  name:'Detroit Excellent Schools', text:'In partnership with',path:'/res/img/cityHubs/1_sponsor.png'} }"
choose_school_value = "{    heading: 'Finding a Great School in Detroit',    content:'We&#39;re here to help you explore your options and find the right school for your child. To get started with the school research process, check out the resources below to learn more about how to choose a school and how enrollment works in Detroit.',    link:[        {            name:'Five steps to choosing a school &#187;',            path:'choosing-schools',            newWindow: ''        },        {            name:' education community &#187;',            path:'education-community',            newWindow:''        },        {            name:'How enrollment works in Detroit &#187;',            path:'enrollment',            newWindow:''        }    ]}"
announcement_value = "{content: 'foobar a ton of content',      link: { name:'Learn More',      path:'http://www.metroparent.com/Metro-Parent/Education-Detroit/', newWindow:'true' } }"
important_events_value = "{ events: [   {     date: '#{(Date.today - 5.days).strftime('%m-%d-%Y')}',     description: 'DPS: Mid-Winter Break Starts',    url: 'http://detroitk12.org/calendars/academic/'  },  {     date: '#{(Date.today + 5.days).strftime('%m-%d-%Y')}',     description:'DPS: Schools Closed',    url: 'http://detroitk12.org/calendars/academic/'  },  {     date: '#{(Date.today + 10.days).strftime('%m-%d-%Y')}',     description: 'Loyola High School Open House',     url: 'http://www.aod.org/schools/choose-catholic-high-schools/high-school-open-houses-and-testing/'   } ] } "
education_community_subheading_value = "{ content:'Education doesn\'t happen in a vacuum and neither does the work of improving education. Great partnerships require deep commitment to a common goal or vision, and our partners have that in abundance. Our partners include, but are not limited to:' }"

education_community_partners_value = "{ partners : [
 {
   tabName :'Community',
   heading:'Black Family Development, Inc.',
   description:'Black Family Development (BFDI) is a private, non-profit comprehensive family counseling agency that was created in 1978 by the Detroit chapter of the National Association of Black Social Workers. BFDI’s program and services include: Family Preservation and support; Mental Health and Substance Abuse services; Juvenile Justice services and Positive Youth Development programs. Via partnerships with the human service agencies and Detroit Public Schools BFDI serves clients throughout the community. Highlights of BFDI’s Youth Development programs include: Academic Olympics; African Centered Olympics; Annual Christmas Jam; Keys to Literacy (an afterschool program); and Summer Youth Employment Training. ',
   anchor:'1',
   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_01.png',
   links : [ {url:'www.blackfamilydevelopment.org', heading :'Learn more about BFDI',newwindow:'true' }
           ]
  } ,
 {
   tabName :'Community',
   heading:'Brightmoor Alliance',
   description:'The Brightmoor Alliance is a coalition of nearly 50 organizations dedicated to serving northwest Detroit’s Brightmoor community. Founded in 2000, the Alliance was established in response to conditions in the community, including poor housing, a high crime rate, and a large amount of vacant land.',
   anchor:'2',
   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_02.png',
   links : [ {url:'www.brightmooralliance.org', heading :'Learn more about the Brightmoor Alliance',newwindow:'true' }
           ]
  } ,
 {    tabName :'Community',   heading:'Brightmoor Pastor Alliance',    description:'Formed by the pastors and spiritual leaders serving in the Brightmoor and Rosedale communities the Brightmoor Pastor Alliance aims to resolve issues affecting Brightmoor and the surrounding community via a people-focused approach that “prioritizes the physical and spiritual renewal, and economic stability” of community members.',    anchor:'3',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_03.png',   links : [ {url:'www.brightmoorpastors.org', heading :'Learn more about the Brightmoor Pastor Alliance',newwindow:'true' }            ]  } , {    tabName :'Community',   heading:'Data Driven Detroit',    description:'Data Driven Detroit (D3) provides accessible, high-quality information and analysis to drive informed decision-making. D3 believes that direct and practical use of data by grassroots leaders and public officials promotes thoughtful community building and effective policymaking.',    anchor:'4',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_04.png',   links : [ {url:'www.datadrivendetroit.org', heading :'Learn more about D3',newwindow:'true' }           ]  },
 {
   tabName :'Community',
   heading:'Detroit Hispanic Development Corporation',
   description:'The Detroit Hispanic Development Corporation is dedicated to creating opportunities for youth and families in Detroit’s Southwest community. DHDC’s services include bilingual programming for youth and adults, with a focus on increasing high school graduation rates, gang prevention and adult education.',
   anchor:'5',
   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_05.png',
   links : [ {url:'http://www.dhdc1.org/programs/programs.html', heading :'Find out more about DHDC’s services and programs',newwindow:'true' }
           ]
  },
 {
   tabName :'Community',
   heading:'Detroit Parent Network',
   description:'The Detroit Parent Network is a membership based parent organizing nonprofit that offers leadership, parenting and development courses via the 11 Parent Resource and Empowerment centers they run in partnership with Detroit Public Schools (DPS) and the Education Achievement Authority (EAA).',
   anchor:'6',
   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_06.png',
   links : [ {url:'http://www.detroitparentnetwork.org/programs', heading :'Learn more about Detroit Parent Network’s Programs and Services',newwindow:'true' }
           ]
  }, {    tabName :'Community',   heading:'Detroit Public Television',    description:'Through television, radio, web, and social media, Detroit Public Television creates content with a concentration on children and education, arts and culture, energy and environment, health, leadership and public affairs. DPT provides educational programs and services for children, parents and caregivers.',    anchor:'7',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_07.png',   links : [ {url:'www.dptv.org', heading :'Learn more about Detroit Public Television',newwindow:'true' }            ]  }, {    tabName :'Community',   heading:'Detroit Regional Chamber',    description:'The Detroit Regional Chamber is committed to developing and maintaining a workforce with the skills and education to contribute to a thriving economy in the region. The Chamber has an active team, who work on this issue daily, as well as the development of partnerships with educational institutions and organizations in the area to continually develop and retain a highly skilled workforce. Chamber education programs include: Detroit Scholarship Fund, Board Fellowship Program, Detroit Compact, and the Education Engagement Project.',    anchor:'8',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_08.png',   links : [ {url:'http://www.detroitchamber.com/economic-development-2/education-talent/', heading :'Learn more about the Chamber’s education programs',newwindow:'true' }            ]  }, {    tabName :'Community',   heading:'Osborn Neighborhood Alliance',    description:'Osborn Neighborhood Alliance (ONA) advocates, builds capacity, and works as a partner with residents to make Osborn a community of choice. ONA was established in 2006 under the Skillman Good Neighborhoods Initiative with a governing board of 33 residents and stakeholders. The Osborn community is located on the northeast side of Detroit.',    anchor:'9',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_09.png',   links : [ {url:'www.osbornvoice.com', heading :'Find out more about the Osborn Neighborhood Alliance',newwindow:'true' }            ]  }, {    tabName :'Community',   heading:'Southwest Solutions',    description:'Southwest Solutions offers human services and affordable housing assistance along with economic development training for families. Programming includes: parenting workshops based on High Scope curriculum, playgroups for ages 0-5, family literacy events and a lending library of toys and books. Free childcare during workshops and classes are offered in Spanish.',    anchor:'10',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_10.png',   links : [ {url:'http://www.swsol.org/counseling', heading :'Learn more about the programs offered',newwindow:'true' }            ]  }, {    tabName :'Community',   heading:'United Way for Southeastern Michigan',    description:'United Way serves the community via a wide-range of service programming. United Way SEM educational work is focused on early childhood development and college and career readiness. The organization partners with parents and childcare providers to foster nurturing, literacy-rich environments. By partnering with low performing high schools, United Way SEM hopes to provide students with personalized learning experiences that help prepare for college and/or a career.',    anchor:'11',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_11.png',   links : [ {url:'www.liveunitededsem.org', heading :'Learn more about United Way',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Challenge Detroit',    description:'Challenge Detroit is a leadership and professional development program that invites approximately 30 of talented individuals to live, work, play, and give in and around the greater Detroit area for one year. New fellows are selected each spring with the idea that attracting and retaining talent will help drive the revitalization of Detroit.',    anchor:'12',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_12.png',   links : [ {url:'www.challengedetroit.org', heading :'Learn more about Challenge Detroit',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'City Year Detroit',    description:'City Year Detroit corps members make a difference in the lives of 500 students in grades K-12, helping students thrive and reach new heights in subjects such as reading, writing, math and science.',    anchor:'13',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_13.png',   links : [ {url:'http://www.cityyear.org/detroit.aspx', heading :'Learn more about City Year Detroit',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Consortium of Hispanic Agencies',    description:'The Consortium of Hispanic Agencies (CHA) of Southwest Detroit is an entity of community based Latino led organizations working together with other stakeholders promoting effective leadership, advocacy, policy change, and culturally appropriate services to enhance the lives of youth and families in Southwest Detroit.',    anchor:'14',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_14.png',   links : [ {url:'www.chadetroit.org', heading :'Learn more about CHA',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Cornerstone Charter Schools',    description:'Founded by Cardinal Adam Maida, who asked that the community “help build cornerstones for the city.” One cornerstone was to be a Christ-centered schooling alternative that would provide the children of Detroit with access to a “high-quality” education.  Cornerstone Independent Schools were named a top primary school by Excellent Schools Detroit in 2013.',    anchor:'15',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_15.png',   links : [ {url:'www.cornerstonecharters.org', heading :'Learn more about Cornerstone Charter Schools',newwindow:'true' }, {url:'https://secure.infosnap.com/family/actionforms.aspx', heading :'Online Application',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Deloitte',    description:'Deloitte and its employees are committed to moving the needle on the issue of college enrollment and success. Through their program, Their Future is Our Future, Deloitte firms and members are encouraged to engage in local programs that help underserved youth succeed in the 21st-century economy.',    anchor:'16',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_16.png',   links : [ {url:'http://www.deloitte.com/view/en_US/us/About/Community-Involvement/signature-issues/index.htm', heading :'Learn more about Their Future is Our Future',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Detroit Edison Public School Academy',    description:'Detroit Edison Public School Academy opened in September 1998, and has since gone on to receive numerous accolades for their programming. The school is divided into four learning academies: primary, elementary, junior and the Early College of Excellence. Detroit Edison academies accept students from throughout Detroit, and are led by Superintendent Ralph Bland.',    anchor:'17',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_17.png',   links : [ {url:'www.detroitedisonpsa.org', heading :'Learn more about Detroit Edison Public School Academy',newwindow:'true' }, {url:'http://www.detroitedisonpsa.org/education/components/scrapbook/default.php?sectiondetailid=4539&', heading :'Online Application and Enrollment Information',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Detroit Public Schools',    description:'Detroit Public Schools, the largest school system in Michigan, runs 97 schools in Detroit.  The district is made up of 21 application schools, 13 authorized charters, nine schools that are a part of DPS’ Office of Innovation “Rising” schools program, and the remainder of schools are considered traditional open enrollment programs. Amongst the DPS’ schools, 12 schools are listed as a top 20 k-8 Detroit school in Excellent Schools Detroit’s Scorecard.  In partnership with the Detroit Parent Network, there are eight DPS Parent Resource Centers located within schools across the city that offer year round parent training, support groups, and play areas for children.',    anchor:'18',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_18.png',   links : [ {url:'http://detroitk12.org/data/', heading :'Learn more about Detroit Public Schools',newwindow:'true' }, {url:'http://detroitk12.org/resources/prospective_students/', heading :'Learn about enrollment',newwindow:'true' }, {url:'http://detroitk12.org/resources/parents/prc/', heading :'Find Parent Resource Centers',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Education Achievement Authority',    description:'The Education Achievement Authority (EAA) is a statewide school district (currently with 15 schools in Detroit) created in 2011 by Michigan’s governor to address the most poorly performing public schools. The most challenged public schools in the state can be transferred into this new district to turnaround educational outcomes for children. The Detroit Parent Network currently runs two Parent Empowerment Centers in EAA schools to offer families courses in closing the achievement gap, job training and more.',    anchor:'19',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_19.png',   links : [ {url:'www.eaaschools.org', heading :'Learn more about EAA schools',newwindow:'true' }, {url:'http://eaaschools.org/abouteaa/enrollment-application/', heading :'EAA Online Enrollment Application',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Education Pioneers',    description:'The Education Pioneers program exists to identify, train, connect, and inspire a new generation of leaders dedicated to transforming our education system so that all students receive a quality education. The organization partners with more than 180 leading education organizations in 16 cities nationwide to ensure that they have the right people with the right skill sets to advance and scale their most promising results and initiatives. Education Pioneers work specifically with partners that run systems of schools that serve a large number of students, such as school districts or charter school management organizations.',    anchor:'20',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_20.png',   links : [ {url:'www.educationpioneers.org', heading :'Learn more about Education Pioneers',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Ernst & Young',    description:'Ernst & Young is committed to education initiatives, and their College MAP (Mentoring for Access and Persistence) serves youth in 12 cities, including students at Detroit’s Cody High School. The program identifies young people in need of support, and brings College MAP directly to them. College MAP helps disadvantaged students in Atlanta, Birmingham, Boston, Chicago, Dallas, Denver, New York, Palo Alto/San Jose, Philadelphia and Pittsburgh.',    anchor:'21',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_21.png',   links : [ {url:'www.ey.com', heading :'Learn more about Ernst & Young',newwindow:'true' }, {url:'http://www.ey.com/Publication/vwLUAssets/College_MAP_At-a-glance/$FILE/College%20MAP%20Slipsheet_CV0091.pdf', heading :'Learn more about College MAP',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Michigan Future, Inc.',    description:'Michigan Future, Inc. is a non-partisan, non-profit organization. Their mission is to be a source of new ideas on how Michigan can succeed as a world class community in a knowledge-driven economy. The organization’s work is funded by Michigan foundations. Michigan Future’s work focuses on Michigan’s economy, attracting and retaining talent, and preparing talent by creating new high schools in Detroit and it’s suburbs.',    anchor:'22',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_22.png',   links : [ {url:'http://www.michiganfuture.org/', heading :'Learn more about Michigan Future',newwindow:'true' }, {url:'http://michiganfuture.org/schools/', heading :'Learn more about Michigan Future Schools',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'New Detroit - The Coalition',    description:'New Detroit’s mission is to work as the coalition of Detroit area leadership addressing the issue of race relations by positively impacting issues and policies that ensure economic and social equity. The coalition is comprised of leaders from civil rights and advocacy organizations, human services, health and community organizations, business, labor, foundations, education, and the media. The non-profit focuses on areas that represent the greatest potential threat to Detroit’s ability to achieve and maintain positive race relations. These areas are: economic equity, educational opportunity, impacting institutional practices, and building public will.',    anchor:'23',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_23.png',   links : [ {url:'http://www.newdetroit.org/cms/index.php/programs-events', heading :'Learn more about New Detroit’s programs',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Rising Advocates for Young Children',    description:'Rising Advocates for Young Children is a Detroit based collaborative of highly trained early childhood educators and caregivers advocating for the most developmentally appropriate, advanced, safe and nurturing care of at-risk children - birth to five years old.  Services include regular activities for children and a Basic Needs Pantry.',    anchor:'24',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_24.png',   links : [ {url:'http://www.risingayc.org/about.html', heading :'Learn more about Rising Advocates for Young',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Teach For America',    description:'Teach For America finds, trains, and supports top college graduates and professionals who commit to teach for two years in urban and rural public schools. Teach For America’s network includes 11,200 corps members teaching in 48 regions across the country and 32,000 alumni working in education and many other sectors to create the systemic changes that will help end educational inequity. In 2013, 400 TFA placements were made in Detroit.',    anchor:'25',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_25.png',   links : [ {url:'www.teachforamerica.org', heading :'Learn more about Teach For America',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'The Achievement Network',    description:'The Achievement Network (ANet) works with partners to turn school best practices used across the country into individualized school best practices. ANet is a nonprofit that helps schools strengthen their practice and culture of using standards and data to accelerate student learning in underserved communities. ANet provides their partners with both tools and training grounded in the practices of the best schools in their network using the following methods: coaching; networking and professional development; assessments and instructional resources.',    anchor:'26',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_26.png',   links : [ {url:'www.achievementnetwork.org', heading :'Learn more about Anet',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'The Education Trust - Midwest',    description:'The Education Trust - Midwest is a statewide education policy and advocacy organization focused on doing “what is right” for Michigan children. Although many organizations speak up for the adults employed by schools and colleges, Ed Trust speaks up for students, especially those whose needs and potential are often overlooked. Ed Trust-Midwest, based in Royal Oak, MI, is affiliated with the national organization, The Education Trust, based in Washington, DC.',    anchor:'27',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_27.png',   links : [ {url:'http://www.edtrust.org/midwest', heading :'Learn more about Education Trust - Midwest',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'University of Chicago, Urban Education Institute',    description:'Via their UChicago Impact program, the Urban Education Institute provides schools, school systems, and states with the highest quality research-based diagnostic tools and training designed to produce reliably excellent schooling. A piece of their work includes the 5Essentials program. UChicago is an evidence-based system designed to drive improvement in schools nationwide. The 5E system measures changes in a school organization through its survey, predicts school success through analysis, and provides individualized actionable reports to schools, districts, parents, and community partners.',    anchor:'28',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_28.png',   links : [ {url:'uei.uchicago.edu', heading :'Learn more about the Urban Education Institute',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'University of Michigan, Flint',    description:'The University of Michigan at Flint is the site of The Detroit Teacher Project, a program for aspiring teachers who have a bachelor’s degree from an accredited institution and are interested in earning a master’s degree with teacher certification. This full-time program is taught on-site in six Detroit-area high schools. Graduates of the program receive their master’s degree and are eligible for teacher certification in Michigan. As a part of this work, Michigan Future, Inc., was given funding to start up seven additional new high schools and another 35 schools by 2018.',    anchor:'29',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_29.png',   links : [ {url:'https://www.umflint.edu/graduateprograms/education-certification-mac-detroit-teacher-project', heading :'Learn more about the Detroit Teacher Project',newwindow:'true' }            ]  }, {    tabName :'Education',   heading:'Wayne CHAP',    description:'Wayne Children’s Healthcare Access Program (WCHAP) is a private-public collaborative that aims to improve the quality of care to Wayne County children while simultaneously lowering associated health care costs. WCHAP works with its partners to improve quality, access and child health outcomes; strengthen provider, family and community partnerships; and reduce costs and advance systems change.',    anchor:'30',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_30.png',   links : [ {url:'http://wchap.org/services/', heading :'Learn more about WCHAP services',newwindow:'true' }            ]  }, {    tabName :'Funders',   heading:'Max M. & Marjorie S. Fisher Foundation',    description:'The mission of the Max M. & Marjorie S. Fisher Foundation is to “enrich humanity by strengthening and empowering children and families” in need. While remaining flexible in their approach the foundation gives priority to: providing for the needs of and ensuring the future of the Jewish people and to respecting their legacy and commitment to the Detroit community. Areas of critical importance include education, arts, culture and health with particular attention to work pertaining to HIV/AIDS.',    anchor:'31',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_31.png',   links : [ {url:'www.mmfisher.org', heading :'Learn more about the foundation',newwindow:'true' }            ]  }, {    tabName :'Funders',   heading:'McGregor Fund',    description:'The McGregor Fund has a long history of supporting educational projects and institutions. The McGregor Fund’s Education Committee regularly reviews the current education environment and updates the grantmaking priorities to reflect the most promising opportunities for improving the educational outcomes of Detroit-area children and young adults.',    anchor:'32',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_32.png',   links : [ {url:'http://www.mcgregorfund.org/', heading :'Learn more about the McGregor Fund',newwindow:'true' }            ]  }, {    tabName :'Funders',   heading:'Skillman Foundation',    description:'The Skillman Foundation brings ideas and people together in Detroit. The foundation invests $17 million a year in six investment areas: education, safety, social innovation, neighborhoods, community leadership, and youth development.',    anchor:'33',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_33.png',   links : [ {url:'www.skillman.org', heading :'Learn more about the Skillman Foundation',newwindow:'true' }            ]  }, {    tabName :'Funders',   heading:'The Kresge Foundation',    description:'Working with other philanthropic organizations, nonprofits, business, government and other community based partners, the Kresge Foundation is investing in areas that leverage Detroit’s strong assets and present opportunities for helping Detroit residents imagine and build a vibrant 21st-century version of their city. There are nine components to Kresge’s work in Detroit: arts and culture, education reform, entrepreneurial development, green economy, health, mass transit development, complete neighborhoods, city land use, and anchor institutions.',    anchor:'34',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_34.png',   links : [ {url:'www.kresge.org', heading :'Learn more about The Kresge Foundation',newwindow:'true' }            ]  }, {    tabName :'Funders',   heading:'W.K. Kellogg Foundation',    description:'The W.K. Kellogg Foundation grants funding to programs that support parents, students, educators and others in their efforts to change the formal educational system in ways that help children succeed in school and life. Additionally, Kellogg Foundation encourages innovative education practices, which include partnerships between schools, families, communities, government, and business.',    anchor:'35',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_35.png',   links : [ {url:'www.wkkf.org', heading :'Learn more about the foundation',newwindow:'true' }            ]  }, {    tabName :'Funders',   heading:'Walton Family Foundation',    description:'The Walton Family Foundation is committed to improving K-12 education in the United States at every level – in traditional public schools, charter public schools and private schools. Through three distinct initiatives, the foundation invests in efforts to shift decision-making power over where a child attends school to his or her family by: Shaping public policy, creating quality schools, and improving existing schools.  The foundation’s investment sites are: Albany, Atlanta, Boston, Chicago, Denver, Detroit, Harlem (NY), Indianapolis, Los Angeles, Memphis, Milwaukee, Minneapolis, New Orleans, Newark (NJ), Phoenix, and Washington, DC.',    anchor:'36',   logo  : '/res/img/cityHubs/1_EduPage_logo_Partner_36.png',   links : [ {url:'www.waltonfamilyfoundation.org', heading :'Learn more about the foundation',newwindow:'true' }            ]  }


  ] }"
sponsor_data_value = "{sponsors :[ {logo :'/res/img/cityHubs/1_sponsor_image.png',               heading:'Excellent Schools Detroit - ESD',               description:'Excellent Schools Detroit, founded by a broad and diverse cross section of Detroit’s education, government, community, parent, and philanthropic leaders, creates the conditions to ensure that all Detroit children are in a great school by 2020.<br/><br/>Excellent Schools Detroit launched in March 2010 with an education plan that recommended bold steps so that Detroit becomes the first major U.S. city where 90 percent of students graduate from high school, 90 percent of those graduates enroll in college or a quality postsecondary training program, and 90 percent of enrollees are prepared to succeed without remediation.<br/><br/>This citywide plan reflected months of discussions and deliberations by coalition members, as well as a series of six community meetings in November and December 2009, youth focus groups, small group discussions with multiple stakeholders, and other outreach efforts. Many Detroiters offered thoughtful recommendations about the need to prepare all students for college, careers, and life in the 21st century.<br/><br/>Fast forward to 2014 and the activities Excellent Schools Detroit engages in focus on four main activities across an early childhood through college continuum: 1) encouraging parents to make high quality educational choices, 2) incentivizing good schools to become excellent (as according to the 90/90/90 standard), 3) moving schools from weak or failing to good, and 4) seeing more weak or failing schools who don’t wish to succeed, close.<br/><br/><strong>Actionable Information</strong><br/>Each year Excellent Schools Detroit works with students, caregivers, school leaders and community members to produce a K-12 and Early Learning Scorecard that measures school quality. The Scorecard now includes grades to help parents and students make sense of Detroit’s more than 220 schools and find the best fit.<br/><br/>Excellent Schools Detroit recommends parents and students select schools graded C+ or better because these schools will generally prepare students for success in college, career and community.<br/><br/><strong>Voice</strong><br/>Excellent Schools Detroit is dedicated to championing for a quality education for every child in Detroit. In 2013, to ensure that parents, caregivers and community members have information that helps them find the best quality educational options in the city, ESD partnered with GreatSchools to develop GreatSchoolsDetroit.org. Information from ESD’s annual school scorecard will be used to supplement information collected by GreatSchools. As a strong advocate for encouraging parents and community members to have a voice and say in what’s important to them related to education, the staff of ESD liked the fact that anyone can review a school as they wish. It’s the shared goal of ESD and GreatSchools to create an information portal guided by needs and developments of students and families that will always reflect the ever changing educational landscape in Detroit.',               links : [ {url:'http://www.excellentschoolsdetroit.org/en', heading :'Find out more about Excellent Schools Detroit',newwindow:'true' }, {url:'http://scorecard.excellentschoolsdetroit.org/', heading :'ESD Scorecard',newwindow:'true' }, {url:'http://issuu.com/esdetroit/docs/esdplan?e=0/1954712', heading :'Find out more about ESDs education Plan',newwindow:'true' }]                }                          ] }"
sponsor_acro_name_value = 'ESD'
sponsor_page_name_value = 'Excellent Schools Detroit'
choose_page_links_value = "{     link:[         {             name:'ESD Scorecard',             path:'http://scorecard.excellentschoolsdetroit.org/',             newWindow:'true'         },         {             name:'Michigan Top-to-Bottom Rankings',             path:'https://www.michigan.gov/mde/0,4615,7-140-22709_56562---,00.html',             newWindow:'true'         },         {             name:'Michigan School Databases',             path:'http://www.mackinac.org/10361',             newWindow:'true'         },         {             name:'MVCA Annual Education Report',             path:'http://www.k12.com/sites/default/files/pdf/school-docs/MVCA-AER%20-08152012.pdf',             newWindow:'true'         }     ] }"
state_hub_content_module_value = <<EOS
{ contents:  [   {heading: "State report cards for public schools",  description: "Every public school building and district receives a report card from the State of Ohio that evaluates the achievement and progress of its students. On the <a href='http://reportcard.education.ohio.gov/' target='_blank'>Ohio Department of Education\'s website</a>, you will find report cards for all public school buildings and districts, including charter schools and career technical education centers.<br/><br/>The Ohio Department of Education is moving to a new way of rating public schools. They are using an A-F rating system to grade particular areas of each school\'s academic performance. In 2015, schools will also begin receiving an overall A-F rating.<br/><br/>The following components are graded on each school and district\'s report card:<ul><li>Student achievement</li><li>Student progress</li><li>Gap Closing</li><li>Graduation rate</li><li>K-3 literacy (coming soon)</li><li>Prepared for success (coming soon)</li></ul><br/><br/>", view_more: "In depth information about these quality indicators and what they mean can be found on the <a href='http://education.ohio.gov/getattachment/Topics/Data/Report-Card/The-New-A-F-Report-Card-1.pdf.aspx'>Ohio Department of Education's website</a>as well as <a href='http://www.scohio.org/school-options/evaluate-school-options/great-school.html'>School Choice Ohio\'s website</a>."},
{heading:'Enrolling in public schools within your district',  description: "In Ohio, every student is assigned to a public school in their district. But what if you want to attend a different school in your district? Between open enrollment and magnet applications, there are lots of ways to attend different public schools.<br/><br/><u>Intra-district transfer</u><br/>If you want your child to attend a different neighborhood school in your district rather than your assigned school, you can use intra-district open enrollment to request a transfer to the school you prefer. Most districts have an intra-district open-enrollment policy that will allow you to move your child to that school as long as space permits. Call your school district to see what is required because each district works a little differently. Spring is usually the best time to contact the district for the next school year.<br/><br/><u>Magnet or lottery school</u><br/>To attend a magnet school, you need to check with the district because each district has a different sign up process. Magnet schools may have selective admission. Students might be required to apply based on different factors, such as a student’s grades or their artistic audition. Check with the magnet school you are interested in to find out what that school requires. If the Magnet school uses a lottery for admissions, admission is determined through a random number lottery system. Parents are required to fill out an application before the deadline, and then it is entered into the lottery pool. On a scheduled date, names are drawn for the school’s open slots from the pool. Check with your district to find out what the deadlines are for the lottery process at the magnet school you are interested in. Deadlines are usually in fall or winter for the following year."},
{heading:'Enrolling in public schools outside your district',  description: "In Ohio, every student is assigned to a public school in their district. But what if you want to attend a school in a nearby district? Between open enrollment and out-of-boundary tuition there are lots of ways to attend different public schools.<br/><br/><u>Open enrollment</u><br/>Most school districts in the state have an inter-district open enrollment policy. That means that a child that lives in another district is free to attend, as long as there is space for that student in the school.<br/><br/>There are two different types of inter-district open enrollment. The first is that the district is open to students in the surrounding (“adjacent”) districts only. That means that your child\'s assigned district has to border the district you want her to attend. The other option is that the district is open to students from all districts, and that means a child from anywhere in the state could enroll in that school, as long as space permits.<br/><br/>To find out more about open enrollment and each district\'s policies, visit the <a href='http://education.ohio.gov/Topics/School-Choice/Open-Enrollment'>Ohio Department of Education website</a><br/><br/><u>Out-of-boundary tuition</u><br/>If open enrollment is not available at the district you want to send your child to, you can always check with the school and see how much their out-of-district tuition costs or click here for a list of tuition rates on the Ohio Department of Education\'s site. If you find that this is the best fit and the tuition option works, you simply pay the tuition cost for your child to attend.<br/><br/><a href='http://education.ohio.gov/Topics/Finance-and-Funding/Finance-Related-Data/Tuition-Letters-and-Rates'>Find the tuition for a specific school</a>"}, {heading:'Enrolling in public charter schools',
description: "If you want to send your child to a charter school, the process is simple. You just sign your child up to attend that school. Charter schools cannot turn away students unless more students apply than they have seats. In that case, there would be a lottery. So, if you find a charter school that you want your child to attend, simply call or visit and sign up.<br/><br/>For more information about the types of charter schools available, visit <a href='http://www.scohio.org/school-options/explore-school-options/school-sectors/charter-school/'>School Choice Ohio\'s website</a> or visit the <a href='http://education.ohio.gov/Topics/School-Choice/Community-Schools'>Ohio Department of Education</a>."},
{heading:'Enrolling in Career-Tech Schools',
description: "Career-Tech schools can be a great option, especially for students who like a more hands-on approach to learning. In order to send your child to a Career-Tech school, you simply have to sign him up. Sometimes there are GPA requirements for programs. Visit the Tech Prep Ohio website to see what programs are available in your district. You can also learn more about career-tech schools on <a href='http://www.scohio.org/school-options/explore-school-options/school-sectors/career-technical-education.html'>School Choice Ohio’s site</a>"},

   ] }
EOS
state_hub_featured_articles_value = articles_value.clone
state_partners_value = partners_value.clone
enrollment_subheading_value = "{ content:'Detroit offers a variety of education choices. Start the search process early, if you can, so you’ll know all your options – and exactly what’s required for enrollment.' }"
enrollment_module_value = "{ header: 'word', content: 'many letters #{('a'..'z').to_a * 10}', link: [{ name:'name', path:'http://www.aod.org/schools/', newwindow:'true' }] }"
enrollment_tips_value = "{ content:[ 'If you’ve missed an application deadline, call the school and ask if you can still apply, or if there is a waiting list. Schools often have open seats, so you could get lucky!', 'Most charter schools host open houses and school tours in the months of March through May. Check out each school’s website to find out more. ', 'You can check a charter school’s track record by visiting the homepage of the school’s authorizer (charter school authorizers oversee school performance). If the school is part of a larger charter organization, make sure their mission aligns with your goals for your child.', 'Detroit Public Schools does not provide transportation for students who select a school outside the boundary of their assigned school.' ] }"
enrollment_tip_value = "{ content: 'If you’ve missed an application deadline, call the school and ask if you can still apply, or if there is a waiting list. Schools often have open seats, so you could get lucky!' }"
state_choose_school_value = "{    heading:'Finding a Great School in Detroit',    content:'We&#39;re here to help you explore your options and find the right school for your child. To get started with the school research process, check out the resources below to learn more about how...', link: [{ newWindow: 'true', name: 'Detroit partner', path: 'http://google.com' }] }"
key_dates_value = "{ content: '02-01-2014<br>Individual schools hold open houses now through April<br>02-01-2014<br>Individual schools hold open houses now through April' }"
browse_links_value = "{   browseLinks: [     { label: 'PreSchools', link: '/schools/?gradeLevels=p'  },     { label: 'Elementary Schools', link: '/schools/?gradeLevels=e'  },     { label: 'Middle Schools', link: '/schools/?gradeLevels=m'  },     { label: 'High Schools', link: '/schools/?gradeLevels=h'  },     { label: 'Public Schools', link: '/schools/?st=public&st=charter'  },     { label: 'Private Schools', link: '/schools/?st=private'  },     { label: 'Charter Schools', link: '/schools/?st=charter'  }   ] }"
programs_heading_value = 'What makes a great after school or summer program?'
programs_intro_value = "{ content: 'Quality after-school and summer learning opportunities. Each has its own enrollment procedure.', view_more: '<u>Traditional public schools</u><br/>Traditional public schools are tuition-free and offer open enrollment to individuals living within a specific district. In some cases, traditional public school districts will allow inter-district transfers, which permit students who live outside the district boundary to enroll at no cost. Parents should contact school districts directly about this option.<br/><br/><u>Public charter schools</u><br/>Public Charter schools are free, and don’t require students to reside in a specific district in order to attend. Like traditional public schools, public charter schools are required to have an open enrollment policy, and cannot charge tuition. Contact individual schools or school websites for enrollment and other information.<br/><br/><u>Magnet schools </u><br/>Magnet schools are public schools that offer a specific subject or curriculum focus. A magnet school may emphasize performing arts, math, business and finance, or international studies, for example. Families must apply to attend a magnet school. When there are more applicants than available seats, the schools will hold a lottery. Contact individual schools or school websites for enrollment and other information.'}"
programs_sponsor_value = "{ logo: 'hubs/after_school_programs.png', description: 'description of an excellent sponsor', link: 'http://google.com', newwindow:'true' }"
programs_partners_value = "{ heading: 'Detroit Partners', subheading: 'more partner info', resources: [  { heading: 'Facebook Aquires Greatschools', content: '<p>For 1 bagillion dollars</p><br><p>\"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatu</p>', imagePath: 'res/img/cityHubs/9_sponsor.png' }, { heading: 'Facebook Aquires Greatschools', content: '<p>For 1 bagillion dollars</p><p>For 1 bagillion dollars</p><p>For 1 bagillion dollars</p>', imagePath: 'res/img/cityHubs/9_sponsor.png' } ] }"
programs_articles_value = "{ sectionHeading: 'Resources in San Francisco',articles: [ { heading: 'How to find a school', newwindow: 'true', path: 'http://www.google.com' }, { heading: 'How to find a school', newwindow:'true', path: 'http://www.google.com' }, { heading: 'How to find a school', newwindow: 'true', path: 'http://www.google.com' }, { heading: 'How to find a school', newwindow:'true', path: 'http://www.google.com' }, { heading: 'How to find a school',newwindow: 'true',path: 'http://www.google.com'},{heading:'How to find a school',newwindow: 'true',path: 'http://www.google.com'}]}"


FactoryGirl.define do
  factory :state_hub_content_module, class: CollectionConfig do
    collection_id 6
    quay CollectionConfig::CONTENT_MODULE_KEY
    value state_hub_content_module_value
  end

  factory :collection_nickname, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::NICKNAME_KEY
    value 'Detroit'
  end

  factory :feature_articles_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::FEATURED_ARTICLES_KEY
    value articles_value
  end

  factory :city_hub_partners_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CITY_HUB_PARTNERS_KEY
    value partners_value
  end

  factory :city_hub_sponsor_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CITY_HUB_SPONSOR_KEY
    value sponsor_value
  end

  factory :choose_a_school_collection_configs, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CITY_HUB_CHOOSE_A_SCHOOL_KEY
    value choose_school_value
  end

  factory :announcement_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CITY_HUB_ANNOUNCEMENT_KEY
    value announcement_value
  end

  factory :show_announcement_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CITY_HUB_SHOW_ANNOUNCEMENT_KEY
    value 'true'
  end

  factory :important_events_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CITY_HUB_IMPORTANT_EVENTS_KEY
    value important_events_value
  end

  factory :community_partners_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::EDUCATION_COMMUNITY_PARTNERS_KEY
    value education_community_partners_value
  end

  factory :community_partners_subheading_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::EDUCATION_COMMUNITY_SUBHEADING_KEY
    value education_community_subheading_value
  end

  factory :bogus_collection_config, class: CollectionConfig do
    collection_id 1
    quay ''
    value 'foo b?a{r'
  end

  factory :community_tabs_collection_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::EDUCATION_COMMUNITY_TABS_KEY
    value 'true'
  end

  factory :community_sponsor_collection_config_name, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::SPONSOR_ACRO_NAME_KEY
    value 'ESD'
  end

  factory :community_sponsor_collection_config_page_name, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::SPONSOR_PAGE_NAME_KEY
    value 'Excellent Schools Detroit'
  end

  factory :community_sponsor_collection_config_data, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::SPONSOR_DATA_KEY
    value sponsor_data_value
  end

  factory :sponsor_page_acro_name_configs, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::SPONSOR_ACRO_NAME_KEY
    value sponsor_acro_name_value
  end

  factory :sponsor_page_page_name_configs, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::SPONSOR_PAGE_NAME_KEY
    value sponsor_page_name_value
  end

  factory :choosing_page_links_configs, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CHOOSING_STEP3_LINKS_KEY
    value choose_page_links_value
  end

  factory :state_hub_featured_articles, class: CollectionConfig do
    collection_id 6
    quay CollectionConfig::STATE_FEATURED_ARTICLES_KEY
    value state_hub_featured_articles_value
  end

  factory :state_partners_configs, class: CollectionConfig do
    collection_id 6
    quay CollectionConfig::STATE_PARTNERS_KEY
    value state_partners_value
  end

  factory :enrollment_subheading_configs, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::ENROLLMENT_SUBHEADING_KEY
    value enrollment_subheading_value
  end

  factory :enrollment_module_configs, class: CollectionConfig do
    collection_id 1
    quay "enrollmentPage_private_elementary_module"
    value enrollment_module_value
  end

  factory :single_enrollment_tip_config, class: CollectionConfig do
    collection_id 1
    quay "enrollmentPage_private_elementary_tips"
    value enrollment_tip_value
  end

  factory :enrollment_tips_config, class: CollectionConfig do
    collection_id 1
    quay "enrollmentPage_private_elementary_tips"
    value enrollment_tips_value
  end

  factory :state_choose_school_config, class: CollectionConfig do
    collection_id 6
    quay CollectionConfig::STATE_CHOOSE_A_SCHOOL_KEY
    value state_choose_school_value
  end

  factory :key_dates_config, class: CollectionConfig do
    collection_id 1
    quay "keyEnrollmentDates_private_preschool"
    value key_dates_value

    after(:create) { CollectionConfig.create(collection_id: 1, quay: 'keyEnrollmentDates_public_preschool', value: key_dates_value) }
  end

  factory :browse_links_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::CITY_HUB_BROWSE_LINKS_KEY
    value browse_links_value
  end

  factory :programs_heading_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::PROGRAMS_HEADING_KEY
    value programs_heading_value
  end

  factory :programs_intro_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::PROGRAMS_INTRO_KEY
    value programs_intro_value
  end

  factory :programs_sponsor_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::PROGRAMS_SPONSOR_KEY
    value programs_sponsor_value
  end

  factory :programs_partners_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::PROGRAMS_PARTNERS_KEY
    value programs_partners_value
  end

  factory :programs_articles_config, class: CollectionConfig do
    collection_id 1
    quay CollectionConfig::PROGRAMS_ARTICLES_KEY
    value programs_articles_value
  end

  factory :community_show_tabs_config, class: CollectionConfig do
    quay CollectionConfig::EDUCATION_COMMUNITY_TABS_KEY
    value 'true'
    collection_id 6
  end
end
