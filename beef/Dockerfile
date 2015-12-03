 FROM ruby:1.9.3

RUN apt-get update && apt-get -y install curl git build-essential\ 
    openssl libreadline6 libreadline6-dev zlib1g zlib1g-dev libssl-dev\
    libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev\
    autoconf libc6-dev libncurses5-dev automake libtool bison subversion

RUN git clone git://github.com/beefproject/beef.git beef-repo
RUN cp -r beef-repo/* .
RUN gem install bundler && bundle install
EXPOSE 3000
CMD "./beef"