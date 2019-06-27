# README

## JAQU CAZ - Ruby on Rails template

### Dependencies
* ruby 2.6.3
* rails 6.0.0.rc1 - update to 6.0.0 as soon as it is available
* [govuk-frontend](https://github.com/alphagov/govuk-frontend)
* other packages listed in Gemfile and package.json files

### Specs test
```
bundle exec rspec
```

### Linting
A Ruby static code analyzer and formatter. 
```
rubocop
```

Configures various linters to comply with GOV.UK's style guides.
```
bundle exec govuk-lint-sass app/javascript
```

### Cucumber test
```
bundle exec rake cucumber
```

### Variables 

* Create .env configuration file from example config
```
cp .env.example .env
```

* Enter local credentials for database, Redis url etc.:
```
nano .env
```
