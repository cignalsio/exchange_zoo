defmodule ExchangeZoo.Binance.FWS do
  @moduledoc ~S"""
  Source: https://binance-docs.github.io/apidocs/futures/en/#event-balance-and-position-update
  """

  use Wind.Client, ping_timer: 30_000

  alias ExchangeZoo.Binance.Model.{
    BookTickerEvent,
    ContractInfoEvent,
    AssetIndexUpdateEvent,
    MarkPriceUpdateEvent,
    ListenKeyExpiredEvent,
    MarginCallEvent,
    AccountConfigUpdateEvent,
    AccountUpdateEvent,
    OrderTradeUpdateEvent,
    StrategyUpdateEvent,
    TradeLiteEvent,
    GridUpdateEvent
  }

  require Logger

  @base_url "wss://fstream.binance.com/ws"

  def connect_uri(), do: URI.new!(@base_url)

  # [params, listen_key, callback_mod]
  def start_link(opts) do
    opts = Keyword.merge([uri: connect_uri()], opts)
    Wind.Client.start_link(__MODULE__, opts)
  end

  @impl true
  def handle_connect(state) do
    params = [state.opts[:listen_key]] ++ state.opts[:params]
    message = Jason.encode!(%{method: "SUBSCRIBE", params: params, id: 1})

    {:reply, {:text, message}, state}
  end

  @impl true
  def handle_frame({:text, data}, state) do
    {:ok, data} = Jason.decode(data)

    {:ok, callback_state} =
      case parse_event(data) do
        # TODO: Pass error messages too (we'll need them in the UI)
        :subscribed ->
          {:ok, state.opts[:callback_state]}

        event ->
          state.opts[:callback_mod].handle_event({:event, event}, state.opts[:callback_state])
      end

    {:noreply, put_in(state[:opts][:callback_state], callback_state)}
  end

  def parse_event(%{"id" => 1, "result" => nil}), do: :subscribed

  def parse_event(%{"e" => "assetIndexUpdate"} = data),
    do: AssetIndexUpdateEvent.from!(data)

  def parse_event([%{"e" => "assetIndexUpdate"} | _] = data),
    do: Enum.map(data, &AssetIndexUpdateEvent.from!/1)

  def parse_event(%{"e" => "markPriceUpdate"} = data),
    do: MarkPriceUpdateEvent.from!(data)

  def parse_event(%{"e" => "contractInfo"} = data),
    do: ContractInfoEvent.from!(data)

  def parse_event(%{"e" => "bookTicker"} = data),
    do: BookTickerEvent.from!(data)

  def parse_event(%{"e" => "listenKeyExpired"} = data),
    do: ListenKeyExpiredEvent.from!(data)

  def parse_event(%{"e" => "MARGIN_CALL"} = data),
    do: MarginCallEvent.from!(data)

  def parse_event(%{"e" => "ACCOUNT_UPDATE"} = data),
    do: AccountUpdateEvent.from!(data)

  def parse_event(%{"e" => "ORDER_TRADE_UPDATE"} = data),
    do: OrderTradeUpdateEvent.from!(data)

  def parse_event(%{"e" => "ACCOUNT_CONFIG_UPDATE"} = data),
    do: AccountConfigUpdateEvent.from!(data)

  def parse_event(%{"e" => "STRATEGY_UPDATE"} = data),
    do: StrategyUpdateEvent.from!(data)

  def parse_event(%{"e" => "GRID_UPDATE"} = data),
    do: GridUpdateEvent.from!(data)

  def parse_event(%{"e" => "TRADE_LITE"} = data),
    do: TradeLiteEvent.from!(data)
end
