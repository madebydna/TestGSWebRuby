# base off of ruby image
FROM ruby:2.4.2

# Install additional needed packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev xvfb qt5-default libqt5webkit5-dev libqtwebkit-dev
RUN apt-get clean

# Set up the install directory, copy over gemfiles, and install
RUN mkdir /srv/rails
WORKDIR /srv/rails
RUN mkdir /srv/rails/log

RUN echo "gem: --no-rdoc --no-ri" > /etc/gemrc
RUN cp ./config/env_global_local_template.yml ./config/env_global_local.yml

COPY Gemfile Gemfile.lock ./
RUN bundle install --binstubs --jobs 10

EXPOSE 3000
COPY ./docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bundle", "install", "--jobs", "10"]
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0"]