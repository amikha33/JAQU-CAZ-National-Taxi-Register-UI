FROM buildkite/puppeteer:v1.15.0
RUN npm install -g pa11y-ci --unsafe-perm=true --allow-root

ADD /.pa11yci.conf.js usr/.pa11yci.conf.js

ENTRYPOINT ["pa11y-ci", "-c", "/usr/.pa11yci.conf.js"]

