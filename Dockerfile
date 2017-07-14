FROM ubuntu:16.04
MAINTAINER Dmitry Mozzherin

ENV LAST_FULL_REBUILD 2016-10-24

RUN apt-get update && \
    apt-get install -y software-properties-common curl && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get install apt-transport-https -y && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_6.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get update && \
    apt-get install -y ruby2.3 ruby2.3-dev build-essential git vim \
    qt5-default libqt5webkit5-dev gstreamer1.0-plugins-base locales \
    gstreamer1.0-tools gstreamer1.0-x \
    libpq-dev postgresql-client dnsutils libmagic-dev \
    nodejs yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo 'gem: --no-rdoc --no-ri >> "$HOME/.gemrc"'

RUN gem install --no-rdoc --no-ri bundler && \
    mkdir /app && mkdir /var/run/sshd
WORKDIR /app
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock
RUN bundle install

COPY . /app

CMD ["/app/exe/docker_startup.sh"]
