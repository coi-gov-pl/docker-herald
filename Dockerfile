FROM ubuntu:trusty

MAINTAINER Karol Kozakowski <karol.kozakowski@coi.gov.pl>

ENV DEBIAN_FRONTEND noninteractive
ENV HERALD_USER herald
ENV HERALD_USER_ID 442
ENV HERALD_HOMEDIR /home/$HERALD_USER

RUN apt-get update
RUN apt-get install -y ruby libpq-dev ruby-dev make gcc postgresql-client
RUN gem install puppet-herald pg puma

RUN useradd --system --create-home --uid $HERALD_USER_ID --home-dir $HERALD_HOMEDIR $HERALD_USER
RUN mkdir /etc/pherald
RUN touch /etc/pherald/passfile
RUN chown $HERALD_USER:$HERALD_USER /etc/pherald/passfile
RUN chmod 0600 /etc/pherald/passfile

COPY src/herald_start.sh /usr/local/sbin/herald-start
RUN chmod +x /usr/local/sbin/herald-start

USER $HERALD_USER
CMD ["/usr/local/sbin/herald-start"]
