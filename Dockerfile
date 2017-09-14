FROM jekyll/jekyll:3.5
COPY Gemfile .
RUN bundle install