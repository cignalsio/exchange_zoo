defmodule ExchangeZoo.Binance.Model.ExchangeInfo do
  use ExchangeZoo.Model
  alias ExchangeZoo.Binance.Model.ExchangeInfo.{Asset, RateLimit, Symbol}

  @primary_key false

  embedded_schema do
    field :exchange_filters, {:array, :string}
    # field :server_time, :integer
    field :timezone, :string

    embeds_many :assets, Asset
    embeds_many :symbols, Symbol
    embeds_many :rate_limits, RateLimit
  end

  def changeset(account_info, attrs \\ %{}) do
    attrs = underscore_keys(attrs)

    account_info
    |> cast(attrs, __MODULE__.__schema__(:fields) -- [:assets, :symbols, :rate_limits])
    |> cast_embed(:assets)
    |> cast_embed(:symbols)
    |> cast_embed(:rate_limits)
  end
end

defmodule ExchangeZoo.Binance.Model.ExchangeInfo.Asset do
  use ExchangeZoo.Model

  @primary_key false

  embedded_schema do
    field :asset, :string
    field :margin_available, :boolean
    field :auto_asset_exchange, :decimal
  end

  def changeset(asset, attrs \\ %{}) do
    cast(asset, attrs, __MODULE__.__schema__(:fields))
  end
end

defmodule ExchangeZoo.Binance.Model.ExchangeInfo.Symbol do
  use ExchangeZoo.Model

  @primary_key false

  @contract_types ~w(perpetual current_month next_month current_quarter next_quarter perpetual_delivering tradifi_perpetual)a
  @statuses ~w(pending_trading trading pre_delivering delivering delivered pre_settle settling close)a
  @order_types ~w(limit market stop stop_market take_profit take_profit_market trailing_stop_market)a
  @time_in_forces ~w(gtc ioc fok gtx gtd gte_gtc)a

  embedded_schema do
    field :symbol, :string
    field :pair, :string
    field :contract_type, Ecto.Enum, values: @contract_types
    field :delivery_date, :integer
    field :onboard_date, :integer
    field :status, Ecto.Enum, values: @statuses
    field :maint_margin_percent, :decimal
    field :required_margin_percent, :decimal
    field :base_asset, :string
    field :quote_asset, :string
    field :margin_asset, :string
    field :price_precision, :integer
    field :quantity_precision, :integer
    field :base_asset_precision, :integer
    field :quote_precision, :integer
    # unpublished so we won't deal with them
    field :underlying_type, :string
    # unpublished so we won't deal with them
    field :underlying_sub_type, {:array, :string}
    field :settle_plan, :integer
    field :trigger_protect, :decimal
    field :order_type, {:array, Ecto.Enum}, values: @order_types
    field :time_in_force, {:array, Ecto.Enum}, values: @time_in_forces
    field :liquidation_fee, :decimal
    field :market_take_bound, :decimal
    field :filters, {:array, :map}
  end

  def changeset(symbol, attrs \\ %{}) do
    attrs = prepare_enums(attrs, ~w(contract_type status order_type time_in_force))
    cast(symbol, attrs, __MODULE__.__schema__(:fields))
  end
end

defmodule ExchangeZoo.Binance.Model.ExchangeInfo.RateLimit do
  use ExchangeZoo.Model

  @primary_key false

  @intervals ~w(second minute)a
  @types ~w(request_weight orders)a

  embedded_schema do
    field :interval, Ecto.Enum, values: @intervals
    field :interval_num, :integer
    field :limit, :integer
    field :rate_limit_type, Ecto.Enum, values: @types
  end

  def changeset(rate_limit, attrs \\ %{}) do
    attrs = prepare_enums(attrs, ~w(interval rate_limit_type))
    cast(rate_limit, attrs, __MODULE__.__schema__(:fields))
  end
end
