FROM amazonlinux

RUN yum install -y ruby23-devel git gcc gcc-c++ postgresql-devel zlib-devel

RUN gem install bundler

ENV INSTALL_PATH /test_track

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY Gemfile Gemfile.lock ./

COPY . .

RUN bundle install --binstubs

CMD puma -C config/puma.rb
