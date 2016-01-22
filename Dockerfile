FROM ubuntu:trusty

MAINTAINER Karol Kozakowski <karol.kozakowski@coi.gov.pl>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y ruby
RUN apt-get install -y libpq-dev
RUN apt-get install -y ruby-dev
RUN apt-get install -y make gcc
RUN gem install puppet-herald

ADD src/herald_start.sh /usr/local/sbin/herald-start
RUN chmod +x /usr/local/sbin/herald-start
