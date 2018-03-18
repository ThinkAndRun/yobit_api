# YobitApi

This gem provides a wrapper for the yobit.net api: [yobit.net](https://yobit.net/en/api)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yobit_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yobit_api

## Usage

1. **Initialize:**

    ```ruby
    client = YobitApi::Client.new
    ```
2. **Setup your API key (for Trade API):**

    Use
    ```ruby
    client = YobitApi::Client.new(key: 'key', secret: 'secret', key_init_date: '01.01.2018')
    ```
    Where key_init_date = api key release date or first usage day date
    
    Or
    ```ruby
    client.config.key = key
    client.config.secret = secret
    ```
3. **Use the api:**

    ```ruby
    client.info
    ```

    Full list of supported methods, see [yobit](https://yobit.net/en/api) for usage.

    *Public API:*
    ```ruby
    info
    ticker(['usd_rur'])
    depth(pairs_list: ['usd_rur'], limit: 1)
    trades(pairs_list: ['usd_rur'], limit: 1)
    ```
    
    *Trade API:*
    ```ruby
    get_info
    trade(pair: 'usd_rur', type: 'buy', rate: 1, amount: 1)
    active_orders('usd_rur')
    order_info(1)
    cancel_order(1)
    trade_history(pair: 'usd_rur')
    get_deposit_address(coin_name: 'BTC', need_new: 0)
    withdraw_coins_to_address(coin_name: 'BTC', amount: 1, address: 'address')
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ThinkAndRun/yobit_api.

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
