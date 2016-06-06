FROM golang:1.6-alpine

MAINTAINER minimum@cepave.com

# Build Open-Falcon Components
RUN \
  mkdir /package \
  && apk add --update git gcc bash perl

WORKDIR /root

COPY openfalcon-build.sh build.sh

# Start
ENTRYPOINT ["./build.sh"]
CMD ["all"]
