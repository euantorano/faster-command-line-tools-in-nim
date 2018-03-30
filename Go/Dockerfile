# build image

FROM golang:alpine AS build-env

WORKDIR /app

COPY main.go .

RUN go build -o csv_test ./csvtest.go

# runtime image

FROM alpine:latest

WORKDIR /app

COPY --from=build-env /app/csv_test .

VOLUME ['/data', '/output', '/resources']

RUN apk add --no-cache bash

CMD /resources/run.sh go.txt