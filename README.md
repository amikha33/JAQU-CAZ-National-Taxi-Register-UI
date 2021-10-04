# CAZ Taxi/PHV License Uploader

[![Build Status](http://drone-1587293244.eu-west-2.elb.amazonaws.com/api/badges/InformedSolutions/JAQU-CAZ-National-Taxi-Register-UI/status.svg?ref=refs/heads/develop)](http://drone-1587293244.eu-west-2.elb.amazonaws.com/InformedSolutions/JAQU-CAZ-National-Taxi-Register-UI)

### Run all tests, checks and calculate code coverage.

```
rake build
```

### Generating documentation

To generate code documentation download the project and install rails dependencies.

```
rails clobber_rdoc  # Remove RDoc HTML files
rails rdoc          # Build RDoc HTML files
rails rerdoc        # Rebuild RDoc HTML files
```

To run the documentation open `doc/app/index.html` in browser.

### Dependencies
* Ruby 3
* Ruby on Rails 6
* [GOV.UK Frontend](https://github.com/alphagov/govuk-frontend)
* Other packages listed in Gemfile and package.json files.

### RSpec test
```
rspec
```

### Cucumber test
```
cucumber
```

### Linting
A Ruby static code analyzer and formatter.
```
rubocop
```

Configurable tool for writing clean and consistent SCSS.
```
node_modules/.bin/stylelint 'app/javascript/**/*.(s)?scss'
```

### Security analysis
Patch-level verification for Bundler.
```
bundle audit check --update
```

Vulnerability audit against the installed packages.
```
yarn run improved-yarn-audit
```

A static analysis security vulnerability scanner for Ruby on Rails applications.
```
brakeman
```

### SonarQube inspection
```
sonar-scanner
```

### Variables

* Create .env configuration file from example config.
```
cp .env.example .env
```

* Enter local credentials for database, google analytics etc.:
```
nano .env
```
