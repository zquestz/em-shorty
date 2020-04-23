FROM ruby:2.3.8
MAINTAINER Josh Ellithorpe <josh@quest@mac.com>

# Setup app environment.
ENV APP_HOME /app
ENV HOME /root

# Copy resources to APP_HOME.
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy Gemfile so we can cache bundle.
COPY Gemfile $APP_HOME
COPY Gemfile.lock $APP_HOME

# Install all gem dependencies.
RUN gem install bundler
RUN bundle install

# Copy app now that dependencies are installed.
COPY . $APP_HOME

# Setup ENV to be production.
ENV RACK_ENV production

EXPOSE 8080
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8080"]
