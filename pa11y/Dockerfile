FROM buildkite/puppeteer:v1.15.0

RUN npm install -g pa11y-ci --unsafe-perm=true --allow-root

COPY /.pa11yci.conf.js /.pa11yci.conf.js

CMD ["/usr/local/bin/pa11y-ci", "-c", ".pa11yci.conf.js"]