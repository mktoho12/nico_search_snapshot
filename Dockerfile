FROM ruby:2.6.0

RUN apt-get update \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN gem update

RUN mkdir /work
WORKDIR /work

ADD Gemfile /work
ADD Gemfile.lock /work
ADD nico_search_snapshot.gemspec /work
RUN mkdir -p /work/lib/nico_search_snapshot
ADD lib/nico_search_snapshot/version.rb /work/lib/nico_search_snapshot
RUN bundle install

ADD lib /work/lib

CMD bundle exec rake spec
