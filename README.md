## GSWeb Ruby

### Getting Started

#### Prerequisites

  To set up this project, you'll need:

  - A git binary on your path (`which git`)
  - The ability to check out code from Git (you have to send your git .ssh
    keys to the system admins)
  - A running mysql server on your machine (`mysql -uroot`)
  - A ruby binary on your path (`which ruby`)
  - A gem binary on your path (`which gem`)
  - A bundler binary on your path (`which bundle`)
    - If you have everything else but are missing bundler, you can install it
      with `gem install bundler`

#### Getting the code

1. do a git clone (probably already done unless you're viewing this elsewhere):

    `git clone git@githost.greatschools.org:gswebruby`

#### Installing ruby gem dependencies and creating databases

2. Navigate into the newly-created gswebruby directory and run:

    `rake gsweb:install`

    This should automatically do things such as:

      - Perform a 'bundle install'
      - Create LocalizedProfiles_development
      - Create other needed databases, and dump schemas (but not data) from dev
      - Insert data needed for a minimal school profile page to load in Rails
      - Create a few files that aren't checked into the git repo, used for
        overwriting specific functionality on your machine



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

    and cross your fingers! If everything has gone well so far, all tests
    should pass.

#### Starting up Rails

7. If everything has worked so far, you should be able to start rails:

    `rails s`

    The 'thin' rails server should start up and start serving pages on port
    3000

8. Navigate to [http://localhost:3000/california/alameda/1-Alameda-High-School/](http://localhost:3000/california/alameda/1-Alameda-High-School/)
and you should see a school profile page

#### Getting more data

  If you'd like to load more pages or see more data on your local machine
  you'll want to do either of the following steps:

- Use mysqldump to selectively copy data from dev (instructions WIP)

      __OR__

- Run this rake task edit your `database_local.yml` file so that your Rails
  will use the mysql server on dev instead of localhost:

  `rake gsweb:use_dev_db`

  To switch back to using mysql on localhost:

  `rake gsweb:use_localhost_db`

### Coding conventions

  Currently, the team has agreed to generally follow the ruby style
  conventions at the [community Ruby Style Guide on Github]
  (https://github.com/bbatsov/ruby-style-guide). If you're not familiar with
  it, please give it a read. Also, suggestions are welcome, so
  feel free to discuss with the team about specific ruby style conventions.

  Rubocop is a code analyze that's based on the ruby style guide, and is
  currently being looked at. The Cane gem has also been suggested.

### Troubleshooting

  WIP

### Deploying

  To deploy, you'll want a unix account (ask sysadmins@greatschools.org). You can also use the syncer account

  `ssh syncer@alpha`

  Once inside, these 2 commands deploy to alpha:
  `sudo -u syncer gsdeploy-fetch alpha gswebruby && sudo -u syncer deployfarmer gswebruby`
