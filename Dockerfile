FROM ruby:2.6.3

ENV NODE_VERSION v14.13.1

RUN apt-get -y install \
  ca-certificates \
  libxml2-dev \
  libxslt-dev \
  tzdata \
  # mariadb-dev \
  curl

RUN curl -sL https://deb.nodesource.com/setup_14.x | APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1 bash

RUN apt-get install -y nodejs

RUN npm install -g yarn

RUN gem install bundler \
  && bundler config --global frozen 1

WORKDIR /app

# ! production / development
ENV RAILS_ENV production
# ENV RAILS_ENV development

# Node 모듈 설치
COPY package.json yarn.lock ./

# ! production / development
# RUN yarn install --production
RUN yarn install

# Gem 모듈 설치
COPY Gemfile Gemfile.lock ./

# ! production / development
RUN bundle install --without development test --jobs 8
# RUN bundle install

# scss > css 파일로

# 레일즈 앱 전체 복사
COPY . .

RUN RAILS_ENV=production rails assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]

VOLUME ["/app/storage", "/app/log"]