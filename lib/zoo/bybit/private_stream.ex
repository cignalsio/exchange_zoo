defmodule ExchangeZoo.Bybit.PrivateStream do
  @moduledoc ~S"""
  Source: https://bybit-exchange.github.io/docs/v5/ws/connect
  """

  use Wind.Client, ping_timer: 30_000
  alias ExchangeZoo.Request

  alias ExchangeZoo.Bybit.Model.{
    PositionEvent,
    ExecutionEvent,
    OrderEvent,
    WalletEvent,
    GreeksEvent
  }

  require Logger

  # @base_url "wss://stream.bybit.com/v5/private"
  @base_url "wss://stream-testnet.bybit.com/v5/private"

  def connect_uri(), do: URI.new!(@base_url)

  # [params, listen_key, callback_mod]
  def start_link(opts) do
    opts = Keyword.merge([uri: connect_uri()], opts)
    Wind.Client.start_link(__MODULE__, opts)
  end

  @impl true
  def handle_connect(state) do
    message = authorize(state)
    {:reply, {:text, message}, state}
  end

  @impl true
  def handle_frame({:text, data}, state) do
    {:ok, data} = Jason.decode(data)

    case parse_event(data) do
      # TODO: Pass error messages too (we'll need them in the UI)
      :authorized ->
        message = subscribe(state)
        {:reply, {:text, message}, state}

      :subscribed ->
        {:noreply, state}

      event ->
        {:ok, callback_state} =
          state.opts[:callback_mod].handle_event({:event, event}, state.opts[:callback_state])

        {:noreply, put_in(state[:opts][:callback_state], callback_state)}
    end
  end

  def authorize(state) do
    api_key = Keyword.fetch!(state.opts, :api_key)
    secret_key = Keyword.fetch!(state.opts, :secret_key)

    expiry = (DateTime.utc_now() |> DateTime.to_unix(:millisecond)) + 5000
    payload = "GET/realtime#{expiry}"
    signature = Request.sign_payload(payload, secret_key)

    Jason.encode!(%{op: "auth", args: [api_key, expiry, signature]})
  end

  def subscribe(state) do
    Jason.encode!(%{op: "subscribe", args: state.opts[:params]})
  end

  def parse_event(%{"op" => "auth", "success" => true}), do: :authorized

  def parse_event(%{"op" => "subscribe", "success" => true}), do: :subscribed

  def parse_event(%{"topic" => "execution", "data" => data}),
    do: Enum.map(data, &ExecutionEvent.from!/1)

  def parse_event(%{"topic" => "position", "data" => data}),
    do: Enum.map(data, &PositionEvent.from!/1)

  def parse_event(%{"topic" => "order", "data" => data}),
    do: Enum.map(data, &OrderEvent.from!/1)

  def parse_event(%{"topic" => "wallet", "data" => data}),
    do: Enum.map(data, &WalletEvent.from!/1)

  def parse_event(%{"topic" => "greeks", "data" => data}),
    do: Enum.map(data, &GreeksEvent.from!/1)
end
