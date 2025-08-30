defmodule Test do
  def handle_event({:event, event}, state) do
    dbg(event)
    {:ok, state}
  end
end

# Bybit

alias ExchangeZoo.Bybit
options = [api_key: System.fetch_env!("BYBIT_API_KEY"), secret_key: System.fetch_env!("BYBIT_API_SECRET")]

Bybit.API.get_instruments_info(category: "linear")

Bybit.API.get_wallet_balance([accountType: "UNIFIED"], options)

Bybit.API.get_position_info([category: "linear", symbol: "BTCUSDT"], options)

Bybit.API.get_open_orders(%{category: "linear", symbol: "BTCUSDT"}, options)

Bybit.API.create_order(%{category: "linear", symbol: "BTCUSDT", side: "Buy", orderType: "Limit", price: "10000", qty: "1"}, options)

Bybit.API.create_batch_order(%{category: "linear", request: [%{category: "linear", symbol: "BTCUSDT", side: "Buy", orderType: "Limit", qty: "0", price: "1000.00"}]}, options)

Bybit.API.cancel_batch_order(%{category: "linear", request: [%{category: "linear", symbol: "BTCUSDT", orderId: "abbacadabba"}]}, options)

Bybit.API.cancel_all_orders(%{category: "linear", symbol: "BTCUSDT"}, options)

Bybit.API.set_position_leverage(%{category: "linear", symbol: "BTCUSDT", buyLeverage: "10", sellLeverage: "10"}, options)

Bybit.PrivateStream.start_link(Keyword.merge(options, callback_mod: Test, params: ~w(execution position order wallet greeks)))

# Binance Futures
# alias ExchangeZoo.Binance

# Binance.FAPI.get_exchange_info()

# MEXC

alias ExchangeZoo.MEXC
options = [api_key: System.fetch_env!("MEXC_API_KEY"), secret_key: System.fetch_env!("MEXC_API_SECRET")]

MEXC.SpotAPI.get_exchange_info([], options)

MEXC.ContractAPI.get_assets([], options)

MEXC.ContractAPI.get_open_orders([], options)

MEXC.ContractAPI.change_leverage(%{leverage: 15, openType: 1, symbol: "BTC_USDT", positionType: 1}, options)

MEXC.ContractAPI.create_order(%{symbol: "BTC_USDT", price: Decimal.new("40000"), vol: Decimal.new("0.001"), side: 1, type: 2, openType: 1, externalOid: "test-001"}, options)

MEXC.ContractWS.start_link(Keyword.merge(options, callback_mod: Test, symbol: "BTC_USDT"))


# BitMEX

alias ExchangeZoo.BitMEX
options = [api_key: System.fetch_env!("BITMEX_API_KEY"), secret_key: System.fetch_env!("BITMEX_API_SECRET")]

BitMEX.API.get_margin([], options)
BitMEX.API.get_order([open: true], options)
BitMEX.API.get_position([], options)

BitMEX.WS.start_link(Keyword.merge(options, callback_mod: Test, params: ~w(funding instrument margin wallet execution order position)))

