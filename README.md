# em-shorty

[![Build Status](https://img.shields.io/travis/zquestz/em-shorty.svg)](https://travis-ci.org/zquestz/em-shorty)
[![License](https://img.shields.io/github/license/zquestz/em-shorty.svg)](https://github.com/zquestz/em-shorty/blob/master/LICENSE)

One of many url shortening apps out there. Was inspired by an article I read at:

http://screencasts.org/episodes/activerecord-with-sinatra

This project is currently live at:

https://emlink.me

I added quite a few things.

1. Now uses rack-fiber_pool, em_mysql2, em-resolv-replace, em-synchrony, and em-http-request for async requests.
2. Fully localized with i18n
3. Templates are flushed out and look good.
4. Added bundler and rvm support.
5. Added sass support.
6. Battery of Unit Tests.
7. Added copy support via clipboard.js.
8. XML, JSON, YAML support.
9. Dalli for speedy memcached support.
10. Tux is included for console debugging.
11. Support for docker-compose.

To start the server:

```
bundle exec thin -R config.ru start
```

This will fire it up on port 3000.

To run the tests:

```
RACK_ENV=test rake db:migrate
bundle exec rake test
```

To launch a console:

```
bundle exec rake console
```

### License

Code in this repository is distributed under the [MIT license](/LICENSE).
