# SqrlCheckWeb

Web interface to SQRL::Check SQRL test suite

## Local Installation

Depends on Redis and libsodium

    $ bundle
    $ guard

## Heroku installation

   herkou apps:create
   heroku addons:create heroku-redis:hobby-dev
   # or other Redis provider
   heroku buildpacks:add --index 1 "https://github.com/JustinLove/heroku-buildpack-libsodium.git"
   heroku buildpacks:add --index 2 heroku/ruby
   heroku config:set SESSION_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   heroku config:set HEROKU_ACCESS_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   heroku config:set HEROKU_APP=xxxxxxxxxx
   git push heroku master

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/JustinLove/sqrl_check_web.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

