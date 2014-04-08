## GSWeb Ruby

### Getting Started

#### Getting the code

1. do a git clone (probably already done unless you're viewing this elsewhere):

    `git clone git@githost.greatschools.org:gswebruby`

#### Setting up databases and dependencies

2. Navigate into the newly-created gswebruby directory and run:
  
    `rake gsweb:install` 

    This should automatically do things such as:

      - Perform a 'bundle install'
      - Create a '_development' version of the database
      - Create a few files that aren't checked into the git repo, used for overwriting functionality on your machine



3. Next, create your test databases with
  
    `rake db:test:prepare`

#### Running RSpec tests with Zeus and Guard

4. If `bundle install` worked earlier, you should have zeus installed. Start
   Zeus with the following command, paying special attention to set the rails
   environment to 'test'

    `RAILS_ENV=test zeus start`

5. Next, open a new terminal session (you need to keep zeus running), run: 

    `guard`

    It should connect to your zeus server and give a prompt. Guard
will watch your file system for changes as you code, and re-run specs as 
necessary

6. Within the Guard prompt, run 

    `rspec` 

    and cross your fingers! If everything has gone well so far, all tests should 
  pass.

#### Starting up Rails

7. If everything has worked so far, you should be able to start rails: 

    `rails s`

    The 'thin' rails server should start up and start serving pages on port 3000

8. Navigate to [http://localhost:3000/california/alameda/1-Alameda-High-School/](http://localhost:3000/california/alameda/1-Alameda-High-School/)
and you should see a school profile page

