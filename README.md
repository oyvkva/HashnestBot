# Hashnest Trading Bot

This is a basic bot that trades on Hashnest, use it at your own risk. The idea of the bot is to take adventage of the spread between bid and ask on Hashnest, it's only profitable under some market conditions.

The bot uses Sidekiq
Sidekiq is a background processing library for Ruby. It adds some handy methods to our classes which make background processing quite simple.

Sidekiq relies on Redis: brew install redis (using HomeBrew)

After it's installed, run redis-server /usr/local/etc/redis.conf

After Redis is installed and running, simply add gem "sidekiq" to your Gemfile and run bundle.

Once the Sidekiq gem is installed, you can start it up by running bundle exec sidekiq

The bot has only been tested running locally. I'm not using the bot anymore but feel free to contribute and improve it.