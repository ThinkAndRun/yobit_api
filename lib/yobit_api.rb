require 'yobit_api/version'
require 'openssl'
require 'rest-client'
require 'addressable/uri'

module YobitApi
  PUBLIC_API_URL = 'https://yobit.net/api/3/'.freeze
  TRADE_API_URL  = 'https://yobit.net/tapi/'.freeze

  class Client
    attr_accessor :config

    def initialize(key: '', secret: '', key_init_date: Time.now)
      key_init_date = Time.parse(key_init_date) unless key_init_date.is_a? Time
      Struct.new('ApiConfig', :key, :secret, :key_init_date)
      @config = Struct::ApiConfig.new(key, secret, key_init_date)
      raise 'Nonce is expired' if nonce > 2147483646
    end

    def info
      get('info')
    end

    def ticker(pairs_list)
      currencies = prepare_pairs(pairs_list)
      get('ticker' + currencies)
    end

    def depth(pairs_list:, limit: 150)
      limit = 2000 if (limit > 2000)
      currencies = prepare_pairs(pairs_list)
      get('depth' + currencies, limit: limit)
    end

    def trades(pairs_list:, limit: 150)
      limit = 2000 if (limit > 2000)
      currencies = prepare_pairs(pairs_list)
      get('trades' + currencies, limit: limit)
    end

    def get_info
      post('getInfo', client: trade_client)
    end

    def trade(pair:, type:, rate:, amount:)
      post('Trade', client: trade_client, pair: pair, type: type, rate: rate, amount: amount)
    end

    def active_orders(pair)
      post('ActiveOrders', client: trade_client, pair: pair)
    end

    def order_info(order_id)
      post('OrderInfo', client: trade_client, order_id: order_id)
    end

    def cancel_order(order_id)
      post('CancelOrder', client: trade_client, order_id: order_id)
    end

    def trade_history(from: 0, count: 1000, from_id: 0, end_id: 1000, order: 'DESC', since: 0, end_time: Time.new(3000).to_i, pair:)
      post('TradeHistory', client: trade_client,
           from:     from,
           count:    count,
           from_id:  from_id,
           end_id:   end_id,
           order:    order,
           since:    since,
           end:      end_time,
           pair:     pair)
    end

    def get_deposit_address(coin_name:, need_new: 0)
      post('GetDepositAddress', client: trade_client, coinName: coin_name, need_new: need_new)
    end

    def withdraw_coins_to_address(coin_name:, amount:, address:)
      post('WithdrawCoinsToAddress', client: trade_client, coinName: coin_name, amount: amount, address: address)
    end

    protected

    def prepare_pairs(pairs_list)
      pairs_list.join("-").prepend("/")
    end

    def public_client
      @public_client ||= RestClient::Resource.new(YobitApi::PUBLIC_API_URL)
    end

    def trade_client
      @trade_client ||= RestClient::Resource.new(YobitApi::TRADE_API_URL)
    end

    def get(method_name, client: public_client, **params)
      params = '?'.concat((params.map{ |k,v| "#{k}=#{v}"}).join('&'))
      client[method_name + params].get
    rescue => e
      e.response
    end

    def post(method_name, client: public_client, **params)
      params[:nonce] = nonce
      params[:method] = method_name
      client.post(params, {key: config.key, sign: create_sign(params)})
    rescue => e
      e.response
    end

    def create_sign(data)
      encoded_data = Addressable::URI.form_encode(data)
      OpenSSL::HMAC.hexdigest('sha512', config.secret, encoded_data)
    end

    def nonce
      ((Time.now - config.key_init_date).to_f * 10).to_i
    end
  end
end
