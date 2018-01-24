FROM node:alpine

LABEL org.label-schema.version=latest
LABEL org.label-schema.vcs-url="https://github.com/lucaperret/drone-now"
LABEL org.label-schema.name="drone-now"
LABEL org.label-schema.description="Deploying to now.sh with Drone CI"
LABEL org.label-schema.vendor="Luca Perret"
LABEL org.label-schema.schema-version="1.0"

RUN npm install now

ADD script.sh /bin/
RUN chmod +x /bin/script.sh

ENTRYPOINT /bin/script.sh