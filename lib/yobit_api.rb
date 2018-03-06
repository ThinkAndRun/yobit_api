require 'yobit_api/version'
require 'openssl'
require 'rest-client'
require 'addressable/uri'

module YobitApi
  PUBLIC_API_URL = 'https://yobit.net/api/3/'.freeze
  TRADE_API_URL  = 'https://yobit.net/tapi/'.freeze

  class ApiConfig
    attr_accessor :key, :secret

    def initialize
      @key    = ''
      @secret = ''
    end
  end

  class << self
    attr_accessor :config
  end

  def self.setup
    @config ||= ApiConfig.new
    yield config
  end

  def self.info
    get('info')
  end

  def self.ticker(pairs_list)
    currencies = prepare_pairs(pairs_list)
    get('ticker' + currencies)
  end

  def self.depth(pairs_list:, limit: 150)
    limit = 2000 if (limit > 2000)
    currencies = prepare_pairs(pairs_list)
    get('depth' + currencies, limit: limit)
  end

  def self.trades(pairs_list:, limit: 150)
    limit = 2000 if (limit > 2000)
    currencies = prepare_pairs(pairs_list)
    get('trades' + currencies, limit: limit)
  end

  def self.get_info
    get('getInfo', client: trade_client)
  end

  def self.trade(pair:, type:, rate:, amount:)
    post('Trade', client: trade_client, pair: pair, type: type, rate: rate, amount: amount)
  end

  def self.active_orders(pair)
    get('ActiveOrders', client: trade_client, pair: pair)
  end

  def self.order_info(order_id)
    get('OrderInfo', client: trade_client, order_id: order_id)
  end

  def self.cancel_order(order_id)
    post('CancelOrder', client: trade_client, order_id: order_id)
  end

  def self.trade_history(from: 0, count: 1000, from_id: 0, end_id: 1000, order: "DESC", since: 0, end_time: Time.new(3000).to_i, pair:)
    post('TradeHistory', client: trade_client,
         from:     from,
         count:    count,
         from_id:  from_id,
         end_id:   end_id,
         order:    order,
         since:    since,
         end_time: end_time,
         pair:     pair)
  end

  def self.get_deposit_address(coin_name:, need_new: 0)
    get('GetDepositAddress', client: trade_client, coinName: coin_name, need_new: need_new)
  end

  def self.withdraw_coins_to_address(coin_name:, amount:, address:)
    post('WithdrawCoinsToAddress', client: trade_client, coinName: coin_name, amount: amount, address: address)
  end

  protected

  def self.prepare_pairs(pairs_list)
    pairs_list.join("-").prepend("/")
  end

  def self.public_client
    @@public_client ||= RestClient::Resource.new(YobitApi::PUBLIC_API_URL)
  end

  def self.trade_client
    @@trade_client ||= RestClient::Resource.new(YobitApi::TRADE_API_URL)
  end

  def self.get(method_name, client: public_client, **params)
    client[method_name].get(params)
  end

  def self.post(method_name, client: public_client, **params)
    params[:nonce] = (Time.now.to_f * 10000000).to_i
    params[:sign]  = create_sign(params)
    client[method_name].post(params, {key: config.key})
  end

  def self.create_sign(data)
    encoded_data = Addressable::URI.form_encode(data)
    OpenSSL::HMAC.hexdigest('sha512', config.secret, encoded_data)
  end
end
