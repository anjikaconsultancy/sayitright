FROM quay.io/aptible/ruby:1.9.3


# Install apt based dependencies required to run Rails as 
# well as RubyGems. As the Ruby image itself is based on a 
# Debian image, we use apt-get to install those.
RUN apt-get update && apt-get install -y \ 
  build-essential \ 
  locales \ 
  nodejs

# Use en_US.UTF-8 as our locale
RUN locale-gen en_US.UTF-8 
ENV LANG en_US.UTF-8 
ENV LANGUAGE en_US:en 
ENV LC_ALL en_US.UTF-8

RUN gem install foreman

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# This should be cached?
COPY Gemfile Gemfile.lock ./ 
#RUN gem install bundler && bundle install --jobs 20 --retry 5
RUN gem install bundler -v 1.17.3 && bundle install --jobs 20 --retry 5

# Copy the main application.
COPY . /usr/src/app

EXPOSE 3000

CMD ["foreman","start"]
#CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]