FROM ruby:latest

# Enable jemalloc
RUN apt-get update && apt-get install libjemalloc2 && rm -rf /var/lib/apt/lists/*
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2

# Developer Toolkit
RUN apt-get dist-upgrade && apt-get update && apt-get install -y build-essential graphviz
RUN gem install activesupport

WORKDIR /workspace
COPY Gemfile .
COPY Gemfile.lock .
RUN bundle install
