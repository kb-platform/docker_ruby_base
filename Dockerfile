FROM ubuntu:trusty

# Install ruby-build
ENV RUBY_VERSION 2.2.0
ENV RUBY_INSTALL_VERSION 0.4.3

# Install build, git, postgres, redis
RUN apt-get update && apt-get -y upgrade && apt-get install -y --no-install-recommends \
 ca-certificates \
 build-essential \
 libpq-dev \
 git curl wget nano openssh-client \

 && apt-get clean &&\
 rm -Rf /var/cache/* &&\
 mkdir /var/cache/debconf

# Ruby 2.1.2 stable via ruby-install, cleaned up the ruby src afterwards (src is 350mb)
RUN echo 'gem: --no-document' >> /usr/local/etc/gemrc &&\
    wget -O /tmp/ruby-install.tar.gz https://github.com/postmodern/ruby-install/archive/v$RUBY_INSTALL_VERSION.tar.gz &&\
    tar -xzvf /tmp/ruby-install.tar.gz -C /opt && rm /tmp/ruby-install.tar.gz &&\
    /opt/ruby-install-$RUBY_INSTALL_VERSION/bin/ruby-install -i /usr/local/ ruby $RUBY_VERSION -- --disable-install-rdoc &&\
    echo 'Cleaning up Ruby src' &&\
    rm /usr/local/src/ruby-$RUBY_VERSION.tar.bz2 &&\
    rm -rf /usr/local/src/ruby-$RUBY_VERSION &&\
    gem update --system &&\
    gem install bundler


# Gem dependencies
RUN apt-get install libcurl3-dev -y --no-install-recommends

# Install NodeJS
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN mkdir /cached_gems
WORKDIR /cached_gems
# bundler first for caching steps

# Rest the Gemfile
ADD . /cached_gems
ENV GEM_HOME /ruby_gems/2.2
ENV PATH /ruby_gems/2.2/bin:$PATH

# Run Bundler
RUN bundle install -j4 --system --without development test
