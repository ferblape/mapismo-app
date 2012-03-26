# Mapismo

Mapismo is a web application focused on extract and analyze geolocated data from the main social networks with the help of [CartoDB](http://cartodb.com).

It has been designed as two component service:

  - `mapismo-app`: which is the web application running the user interface of mapismo (this application)

  - [`mapismo-worker-past`](https://github.com/ferblape/mapismo-worker-past): Node.js worker focused on fetch data asynchronously and insert it on CartoDB

Data from social networks is stored in CartoDB and represented in a map. Mapismo sends a message using a Redis channel to the worker with the type of data that has to be fetched, in what table it has to be stored, the parameters of the search, and so on. More details about these messages can be found in [workers README](https://github.com/ferblape/mapismo-worker-past/blob/master/README.md).

## Setup and dependencies

Mapismo is a modern Ruby on Rails application (it only works in Ruby 1.9.2+). To setup and run it you have to follow the following steps:

  - setup a new gemset: `rvm use 1.9.3@mapismo --create`
  - `gem install bundler`
  - `bundle install`

Then, you have to setup some environment variables:

  - `mapismo_oauth_token`: an authenticated token of the user `mapismo` in CartoDB
  - `mapismo_oauth_secret`: a secret token of the user `mapismo` in CartoDB
  - `mapismo_consumer_key`: consumer key of the user `mapismo` in CartoDB
  - `mapismo_consumer_secret`: consumer secret of the user `mapismo` in CartoDB
  - `workers_password_channel`: a shared password between the workers and the application to encode and decode the messages

Also `config/app_config.yml` file can be edited to adjust some parameters.

In production Redis must be setup. In development environment a mock of Redis can be used (edit `config/environments/development.rb`) to activate one or the other.

As Mapismo works using CartoDB, no local database has to be configured.

## Run tests

Mapismo uses Rspec to define the behavior of the application. To run the tests just type `rake`.

## TODO

- Right now, only Flickr and Instagram are accepted as data sources. Twitter and FourSquare are perfect candidates for an application like this

- Interaction with the map: would be great to know which feature has been selected. To achieve this a new interactive layer can be used. Investigate in this way: http://mapbox.com/glower/#

- ...

## Authors

- [Alberto Romero](http://github.com/denegro)

- [Fernando Blat](http://github.com/ferblape)

## License

[MIT License FTW](http://www.opensource.org/licenses/mit-license.html)