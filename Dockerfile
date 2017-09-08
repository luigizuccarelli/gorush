# build stage
FROM appleboy/golang-testing:1.7.5
ADD . /go/src/github.com/appleboy/gorush
RUN cd /go/src/github.com/appleboy/gorush && make docker_build

# final stage
FROM centurylink/ca-certs
EXPOSE 8088

ADD config/config.yml /
COPY --from=0 /go/src/github.com/appleboy/gorush/bin/gorush /

ENTRYPOINT ["/gorush"]
CMD ["-c", "config.yml"]
