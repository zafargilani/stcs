FROM debian:jessie

ADD install-beef /opt
RUN apt-get update && apt-get -y install curl
RUN chmod +x /opt/install-beef

CMD "./opt/install-beef"
#"./beef"