defmodule ExchangeZoo.Bybit.API do
  use ExchangeZoo.API, base_url: "https://api-testnet.bybit.com"

  alias ExchangeZoo.Bybit.Model

  public :get, "/v5/market/instruments-info", Model.InstrumentsInfo
  private :get, "/v5/order/realtime", Model.OrderResponse, as: :get_open_orders
  private :post, "/v5/order/create", Model.OrderResponse, as: :create_order
  private :post, "/v5/order/create-batch", Model.OrderResponse, as: :create_batch_order # 404??
  private :post, "/v5/order/cancel-batch", Model.OrderResponse, as: :cancel_batch_order # 404??
  private :post, "/v5/order/cancel-all", Model.OrderResponse, as: :cancel_all_orders
end
