defmodule ExchangeZoo.Binance.Model.TradeLiteEvent do
  use ExchangeZoo.Model

  @primary_key false

  @order_sides ~w(buy sell)a

  @fields %{
    "E" => :event_time,
    "T" => :transaction_time,
    "s" => :symbol,
    "q" => :original_quantity,
    "p" => :original_price,
    "m" => :maker_side,
    "c" => :client_order_id,
    "S" => :side,
    "l" => :order_last_filled_qty,
    "L" => :last_fill_price,
    "t" => :trade_id,
    "i" => :order_id
  }

  embedded_schema do
    field :event_time, :integer
    field :transaction_time, :integer
    field :symbol, :string
    field :maker_side, :boolean
    field :side, Ecto.Enum, values: @order_sides
    field :original_quantity, :decimal
    field :original_price, :decimal
    field :order_last_filled_qty, :decimal
    field :last_fill_price, :decimal
    field :client_order_id, :string
    field :order_id, :integer
    field :trade_id, :integer
  end

  def changeset(event, attrs \\ %{}) do
    attrs =
      attrs
      |> map_keys(@fields)
      |> prepare_enums(~w(side)a)

    cast(event, attrs, __MODULE__.__schema__(:fields))
  end
end
