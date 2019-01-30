FROM jekyll/jekyll:3.5
COPY Gemfile /
RUN bundle install
RUN chmod -R 777 /srv/jekyll