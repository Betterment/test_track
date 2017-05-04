FROM amazonlinux

RUN yum install -y ruby23-devel git gcc gcc-c++ postgresql-devel zlib-devel fontconfig freetype freetype-devel fontconfig-devel libstdc++

# install phantomjs manually since it doesn't exist in amazon's repo yet
RUN yum install -y wget bzip2 tar
RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2  && \
  mkdir -p /opt/phantomjs && \
  bzip2 -d phantomjs-1.9.8-linux-x86_64.tar.bz2 && \
  tar -xvf phantomjs-1.9.8-linux-x86_64.tar --directory /opt/phantomjs/ --strip-components 1 && \
  ln -s /opt/phantomjs/bin/phantomjs /usr/bin/phantomjs

RUN gem install bundler

ENV INSTALL_PATH /test_track

RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

ENV BUNDLE_PATH /bundle
