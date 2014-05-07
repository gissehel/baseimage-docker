FROM ubuntu:14.04
MAINTAINER Gissehel <public-docker-phusion-baseimage@gissehel.org>

ENV HOME /root
RUN mkdir /build
ADD . /build

RUN /build/prepare.sh && \
	/build/system_services.sh && \
	/build/utilities.sh && \
	/build/cleanup.sh

CMD ["/sbin/my_init"]
