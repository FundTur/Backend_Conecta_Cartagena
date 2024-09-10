# Dockerfile
FROM node:18-alpine3.18

#Set TimeZone
RUN apk add --no-cache tzdata
ENV TZ=America/Bogota
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install Bash
RUN apk add --no-cache bash

# Process manager for node
# RUN npm install --global pm2
# create destination directory
RUN mkdir -p /usr/src/directus
WORKDIR /usr/src/directus

# copy the app, note .dockerignore
COPY . /usr/src/directus/

# RUN \
  # Create data directories
  # mkdir -p \
  #   database \
  #   extensions \
  #   uploads

# RUN npm install forever-monitor
RUN npm install

EXPOSE 8055

# Start HTTP service, HTTPS Service, and PM2 logs
CMD [ "npm","run", "start"]