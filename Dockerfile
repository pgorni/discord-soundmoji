FROM ruby:2.5.1-alpine3.7

COPY . /app

# first, update the packages
RUN apk update && apk upgrade

# this is required so that OpenSSL errors don't appear
RUN apk add ca-certificates && update-ca-certificates && apk add openssl

# add build essentials
RUN apk add build-base

# get discordrb requirements
RUN apk add libsodium-dev opus-dev ffmpeg-dev ffmpeg

# move everything
COPY . /app
WORKDIR /app

# install Ruby deps
RUN bundle install --without development

# start
CMD ["ruby", "bot.rb"]
