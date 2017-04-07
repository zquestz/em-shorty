FROM ruby:2.3.4
MAINTAINER Josh Ellithorpe <josh@quest@mac.com>

# Setup app environment
ENV APP_HOME /app
ENV HOME /root

# Copy resources to APP_HOME
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY . $APP_HOME

# Install all gem dependencies.
RUN bundle install

# Setup ENV to be production
ENV RACK_ENV production

EXPOSE 8080
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "8080"]