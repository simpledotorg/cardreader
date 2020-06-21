# Card Reader

[![Build Status](https://semaphoreci.com/api/v1/resolvetosavelives/cardreader/branches/master/badge.svg)](https://semaphoreci.com/resolvetosavelives/cardreader)

This is a companion data-entry app for adding IHMI treatment cards to [Simple Server](https://github.com/simpledotorg/simple-server).

## Development Setup

First, you need to install [ruby](https://www.ruby-lang.org/en/documentation/installation/). 
It is recommended to use [rbenv](https://github.com/rbenv/rbenv) to manage ruby versions.

```bash
gem install bundler
bundle install
rake db:create db:setup db:migrate
```

### Running the application locally

The application will start at http://localhost:3001.

```bash
RAILS_ENV=development bin/rails s -p 3001
```

### Configuring

The app can be configured using a `.env` file. Look at `.env.development` for sample configuration.

To allow syncing from `cardreader` to `Simple`, fill in `SIMPLE_SERVER_HOST`, `SIMPLE_SERVER_USER_ID` and `SIMPLE_SERVER_ACCESS_TOKEN` to have `cardreader` connect to `Simple`. 
These can be found simply by connecting to a `bin/rails console` on `Simple` and running a command like the following:

```ruby
User.first.slice(:id, :access_token)
```

The `SIMPLE_SERVER_HOST` will typically be `http://localhost:3000`

***NOTE:** The user that you pick for sync access will only be able to sync in the facilities they have access to*

## Running the tests

```bash
RAILS_ENV=test bundle exec rspec
```

## Deployment
`cardreader` is deployed using capistrano.

```bash
bundle exec cap <enviroment> deploy
# eg: bundle exec cap staging deploy
```
