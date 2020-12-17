FROM golang:1.15.6-alpine3.12 as build

LABEL description="A list of Erlang and Elixir packages available at https://hex.pm. \
The image build downloads all versions of the packages and their dependencies. \
A simple webserver exposes the endpoints needed for getting the packages via Mix."

RUN apk update \
    && apk add libc6-compat

COPY hexdump /hexdump
# COPY hexserver /hexserver
RUN cd /hexdump \
  && CGO_ENABLED=0 go build hexdump.go
#   && cd /hexserver \
#   && CGO_ENABLED=0 go build hexserver.go

FROM alpine:3.8

RUN mkdir -p /hexdump/packages && \
    mkdir -p /hexdump/tarballs && \
    mkdir -p /hexdump/installs && \
    mkdir -p /app

COPY --from=build /hexdump/hexdump /app/
# COPY --from=build /hexserver/hexserver /app/
ADD packages.txt /app/

RUN /app/hexdump
RUN rm /app/hexdump

ADD plugins/ /plugins/

# EXPOSE 5000

# CMD ["/app/hexserver"]
