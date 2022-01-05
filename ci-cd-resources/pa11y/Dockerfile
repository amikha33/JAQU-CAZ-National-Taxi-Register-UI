FROM node:16.13.1-slim

RUN apt-get update \
    && apt-get install -y wget gnupg ca-certificates \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

RUN yarn global add pa11y-ci@3.0.1

COPY /.pa11yci.conf.js /.pa11yci.conf.js
CMD ["/usr/local/bin/pa11y-ci", "-c", ".pa11yci.conf.js"]
