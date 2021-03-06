FROM node:alpine

LABEL org.label-schema.version=latest
LABEL org.label-schema.vcs-url="https://github.com/one000mph/drone-now"
LABEL org.label-schema.name="drone-now"
LABEL org.label-schema.description="Deploying to now.sh with Drone CI"
LABEL org.label-schema.vendor="Heather Young"
LABEL org.label-schema.schema-version="1.1"

RUN npm install -g --unsafe-perm now@latest

ADD script.sh /bin/
RUN chmod +x /bin/script.sh

ENTRYPOINT /bin/script.sh
