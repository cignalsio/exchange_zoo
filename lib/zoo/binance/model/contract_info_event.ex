defmodule ExchangeZoo.Binance.Model.ContractInfoEvent do
  use ExchangeZoo.Model
  alias ExchangeZoo.Binance.Model.ContractInfoEvent.Bracket

  @primary_key false

  @contract_types ~w(perpetual current_month next_month current_quarter next_quarter perpetual_delivering)a
  @contract_statuses ~w(pending_trading trading pre_delivering delivering delivered pre_settle settling close)a

  @fields %{
    "E" => :event_time,
    "s" => :symbol,
    "ps" => :pair,
    "ct" => :contract_type,
    "dt" => :delivery_time,
    "ot" => :onboard_time,
    "cs" => :contract_status,
    "bks" => :brackets
  }

  embedded_schema do
    field :event_time, :integer
    field :symbol, :string
    field :pair, :string
    field :contract_type, Ecto.Enum, values: @contract_types
    field :delivery_time, :integer
    field :onboard_time, :integer
    field :contract_status, Ecto.Enum, values: @contract_statuses

    embeds_many :brackets, Bracket
  end

  def changeset(event, attrs \\ %{}) do
    attrs =
      attrs
      |> map_keys(@fields)
      |> prepare_enums(~w(contract_status contract_type)a)

    event
    |> cast(attrs, __MODULE__.__schema__(:fields) -- [:brackets])
    |> cast_embed(:brackets)
  end
end

defmodule ExchangeZoo.Binance.Model.ContractInfoEvent.Bracket do
  use ExchangeZoo.Model

  @primary_key false

  @fields %{
    "bs" => :notional_bracket,
    "bnf" => :floor_notional,
    "bnc" => :cap_notional,
    "mmr" => :maint_ratio,
    "cf" => :aux_num,
    "mi" => :min_leverage,
    "ma" => :max_leverage
  }

  embedded_schema do
    field :notional_bracket, :integer
    field :floor_notional, :integer
    field :cap_notional, :integer
    field :maint_ratio, :decimal
    field :aux_num, :integer
    field :min_leverage, :integer
    field :max_leverage, :integer
  end

  def changeset(event, attrs \\ %{}) do
    attrs = map_keys(attrs, @fields)
    cast(event, attrs, __MODULE__.__schema__(:fields))
  end
end
