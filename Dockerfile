FROM ruby:2.5.3-alpine

ARG TEST_ZSH_VERSION
RUN : "${TEST_ZSH_VERSION:?}"

RUN apk add --no-cache autoconf
RUN apk add --no-cache libtool
RUN apk add --no-cache libcap-dev
RUN apk add --no-cache pcre-dev
RUN apk add --no-cache curl
RUN apk add --no-cache build-base
RUN apk add --no-cache ncurses-dev
RUN apk add --no-cache tmux

WORKDIR /zsh-autosuggestions

ADD install_test_zsh.sh ./
RUN ./install_test_zsh.sh

ADD Gemfile Gemfile.lock ./
RUN bundle install
