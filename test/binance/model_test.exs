defmodule ExchangeZoo.Binance.ModelTest do
  use ExUnit.Case, async: true
  import ExchangeZoo.Fixtures

  describe "ExchangeInfo" do
    alias ExchangeZoo.Binance.Model.ExchangeInfo
    alias ExchangeZoo.Binance.Model.ExchangeInfo.{Asset, Symbol, RateLimit}

    test "should parse /fapi/v1/exchangeInfo" do
      expected = %ExchangeInfo{
        assets: [
          %Asset{
            asset: "BUSD",
            margin_available: true,
            auto_asset_exchange: Decimal.new(0)
          },
          %Asset{
            asset: "USDT",
            margin_available: true,
            auto_asset_exchange: Decimal.new(0)
          },
          %Asset{asset: "BNB", margin_available: false, auto_asset_exchange: nil}
        ],
        exchange_filters: [],
        rate_limits: [
          %RateLimit{
            interval: :minute,
            interval_num: 1,
            limit: 2400,
            rate_limit_type: :request_weight
          },
          %RateLimit{
            interval: :minute,
            interval_num: 1,
            limit: 1200,
            rate_limit_type: :orders
          }
        ],
        symbols: [
          %Symbol{
            symbol: "BLZUSDT",
            pair: "BLZUSDT",
            contract_type: :perpetual,
            delivery_date: 4_133_404_800_000,
            onboard_date: 1_598_252_400_000,
            status: :trading,
            maint_margin_percent: Decimal.new("2.5000"),
            required_margin_percent: Decimal.new("5.0000"),
            base_asset: "BLZ",
            quote_asset: "USDT",
            margin_asset: "USDT",
            price_precision: 5,
            quantity_precision: 0,
            base_asset_precision: 8,
            quote_precision: 8,
            underlying_type: "COIN",
            underlying_sub_type: ["STORAGE"],
            settle_plan: 0,
            trigger_protect: Decimal.new("0.15"),
            order_type: [
              :limit,
              :market,
              :stop,
              :stop_market,
              :take_profit,
              :take_profit_market,
              :trailing_stop_market
            ],
            time_in_force: [:gtc, :ioc, :fok, :gtx, :gtd],
            liquidation_fee: Decimal.new("0.010000"),
            market_take_bound: Decimal.new("0.30"),
            filters: [
              %{
                "filter_type" => "PRICE_FILTER",
                "max_price" => "300",
                "min_price" => "0.0001",
                "tick_size" => "0.0001"
              },
              %{
                "filter_type" => "LOT_SIZE",
                "max_qty" => "10000000",
                "min_qty" => "1",
                "step_size" => "1"
              },
              %{
                "filter_type" => "MARKET_LOT_SIZE",
                "max_qty" => "590119",
                "min_qty" => "1",
                "step_size" => "1"
              },
              %{"filter_type" => "MAX_NUM_ORDERS", "limit" => 200},
              %{"filter_type" => "MAX_NUM_ALGO_ORDERS", "limit" => 100},
              %{"filter_type" => "MIN_NOTIONAL", "notional" => "1"},
              %{
                "filter_type" => "PERCENT_PRICE",
                "multiplier_decimal" => 4,
                "multiplier_down" => "0.8500",
                "multiplier_up" => "1.1500"
              }
            ]
          }
        ],
        timezone: "UTC"
      }

      assert expected ==
               json_fixture("binance/fapi_v1_exchangeInfo")
               |> ExchangeInfo.from!()
    end
  end

  describe "AssetIndex" do
    alias ExchangeZoo.Binance.Model.AssetIndex

    test "should parse /fapi/v1/assetIndex" do
      expected = [
        %AssetIndex{
          symbol: "ADAUSD",
          time: 1_635_740_268_004,
          index: Decimal.new("1.92957370"),
          bid_buffer: Decimal.new("0.10000000"),
          ask_buffer: Decimal.new("0.10000000"),
          bid_rate: Decimal.new("1.73661633"),
          ask_rate: Decimal.new("2.12253107"),
          auto_exchange_bid_buffer: Decimal.new("0.05000000"),
          auto_exchange_ask_buffer: Decimal.new("0.05000000"),
          auto_exchange_bid_rate: Decimal.new("1.83309501"),
          auto_exchange_ask_rate: Decimal.new("2.02605238")
        }
      ]

      assert expected ==
               json_fixture("binance/fapi_v1_assetIndex")
               |> Enum.map(&AssetIndex.from!/1)
    end
  end

  describe "LeverageBracket" do
    alias ExchangeZoo.Binance.Model.LeverageBracket
    alias ExchangeZoo.Binance.Model.LeverageBracket.Bracket

    test "should parse /fapi/v1/leverageBracket" do
      expected = %LeverageBracket{
        symbol: "ETHUSDT",
        brackets: [
          %Bracket{
            bracket: 1,
            initial_leverage: Decimal.new("75"),
            notional_cap: Decimal.new("10000"),
            notional_floor: Decimal.new("0"),
            maint_margin_ratio: Decimal.new("0.0065"),
            cum: Decimal.new("0")
          }
        ]
      }

      assert expected ==
               json_fixture("binance/fapi_v1_leverage_bracket")
               |> LeverageBracket.from!()
    end
  end

  describe "AccountInfo" do
    alias ExchangeZoo.Binance.Model.Account

    test "should parse /fapi/v2/account" do
      expected = %Account{
        fee_tier: 0,
        can_trader: nil,
        can_deposit: true,
        can_withdraw: true,
        update_time: 0,
        multi_assets_margin: true,
        total_initial_margin: Decimal.new("0E-8"),
        total_maint_margin: Decimal.new("0E-8"),
        total_wallet_balance: Decimal.new("126.72469206"),
        total_unrealized_profit: Decimal.new("0E-8"),
        total_margin_balance: Decimal.new("126.72469206"),
        total_position_initial_margin: Decimal.new("0E-8"),
        total_open_order_initial_margin: Decimal.new("0E-8"),
        total_cross_wallet_balance: Decimal.new("126.72469206"),
        total_cross_un_pnl: Decimal.new("0E-8"),
        available_balance: Decimal.new("126.72469206"),
        assets: [
          %Account.Asset{
            asset: "USDT",
            wallet_balance: Decimal.new("23.72469206"),
            unrealized_profit: Decimal.new("0E-8"),
            margin_balance: Decimal.new("23.72469206"),
            maint_margin: Decimal.new("0E-8"),
            initial_margin: Decimal.new("0E-8"),
            position_initial_margin: Decimal.new("0E-8"),
            open_order_initial_margin: Decimal.new("0E-8"),
            cross_wallet_balance: Decimal.new("23.72469206"),
            cross_un_pnl: Decimal.new("0E-8"),
            available_balance: Decimal.new("23.72469206"),
            max_withdraw_amount: Decimal.new("23.72469206"),
            margin_available: true,
            update_time: Decimal.new(1_625_474_304_765)
          },
          %Account.Asset{
            asset: "BUSD",
            wallet_balance: Decimal.new("103.12345678"),
            unrealized_profit: Decimal.new("0E-8"),
            margin_balance: Decimal.new("103.12345678"),
            maint_margin: Decimal.new("0E-8"),
            initial_margin: Decimal.new("0E-8"),
            position_initial_margin: Decimal.new("0E-8"),
            open_order_initial_margin: Decimal.new("0E-8"),
            cross_wallet_balance: Decimal.new("103.12345678"),
            cross_un_pnl: Decimal.new("0E-8"),
            available_balance: Decimal.new("103.12345678"),
            max_withdraw_amount: Decimal.new("103.12345678"),
            margin_available: true,
            update_time: Decimal.new(1_625_474_304_765)
          }
        ],
        positions: [
          %Account.Position{
            symbol: "BTCUSDT",
            initial_margin: Decimal.new(0),
            maint_margin: Decimal.new(0),
            unrealized_profit: Decimal.new("0E-8"),
            position_initial_margin: Decimal.new(0),
            open_order_initial_margin: Decimal.new(0),
            leverage: Decimal.new(100),
            isolated: true,
            entry_price: Decimal.new("0.00000"),
            max_notional: Decimal.new(250_000),
            bid_notional: Decimal.new(0),
            ask_notional: Decimal.new(0),
            position_side: :both,
            position_amt: Decimal.new(0),
            update_time: 0
          }
        ]
      }

      assert expected ==
               json_fixture("binance/fapi_v2_account")
               |> Account.from!()
    end
  end

  describe "Order" do
    alias ExchangeZoo.Binance.Model.Order

    test "should parse /fapi/v1/openOrders" do
      expected = [
        %ExchangeZoo.Binance.Model.Order{
          activate_price: Decimal.new(9020),
          avg_price: Decimal.new("0.00000"),
          client_order_id: "abc",
          close_position: false,
          cum_quote: Decimal.new(0),
          executed_qty: Decimal.new(0),
          order_id: 1_917_641,
          orig_qty: Decimal.new("0.40"),
          orig_type: :trailing_stop_market,
          position_side: :short,
          price: Decimal.new(0),
          price_protect: false,
          price_rate: Decimal.new("0.3"),
          reduce_only: false,
          side: :buy,
          status: :new,
          stop_price: Decimal.new(9300),
          symbol: "BTCUSDT",
          time: 1_579_276_756_075,
          time_in_force: :gtc,
          type: :trailing_stop_market,
          update_time: 1_579_276_756_075,
          working_type: :contract_price
        }
      ]

      assert expected ==
               json_fixture("binance/fapi_v1_openOrders")
               |> Enum.map(&Order.from!/1)
    end
  end

  describe "BookTicker" do
    alias ExchangeZoo.Binance.Model.BookTicker

    test "should parse /fapi/v1/ticker/bookTicker" do
      expected = [
        %BookTicker{
          symbol: "BTCUSDT",
          bid_price: Decimal.new("4.00000000"),
          bid_qty: Decimal.new("431.00000000"),
          ask_price: Decimal.new("4.00000200"),
          ask_qty: Decimal.new("9.00000000"),
          time: 1_589_437_530_011
        }
      ]

      assert expected ==
               json_fixture("binance/fapi_v1_ticker_bookTicker")
               |> Enum.map(&BookTicker.from!/1)
    end
  end

  describe "BookTickerEvent" do
    alias ExchangeZoo.Binance.Model.BookTickerEvent

    test "should parse bookTicker event" do
      expected = %BookTickerEvent{
        order_book_update_id: 400_900_217,
        event_time: 1_568_014_460_893,
        transaction_time: 1_568_014_460_891,
        symbol: "BNBUSDT",
        best_bid_price: Decimal.new("25.35190000"),
        best_bid_qty: Decimal.new("31.21000000"),
        best_ask_price: Decimal.new("25.36520000"),
        best_ask_qty: Decimal.new("40.66000000")
      }

      assert expected ==
               json_fixture("binance/events/book_ticker")
               |> BookTickerEvent.from!()
    end
  end

  describe "ContractInfoEvent" do
    alias ExchangeZoo.Binance.Model.ContractInfoEvent
    alias ExchangeZoo.Binance.Model.ContractInfoEvent.Bracket

    test "should parse contractInfo event" do
      expected = %ContractInfoEvent{
        event_time: 1_669_356_423_908,
        symbol: "IOTAUSDT",
        pair: "IOTAUSDT",
        contract_type: :perpetual,
        delivery_time: 4_133_404_800_000,
        onboard_time: 1_569_398_400_000,
        contract_status: :trading,
        brackets: [
          %Bracket{
            notional_bracket: 1,
            floor_notional: 0,
            cap_notional: 5000,
            maint_ratio: Decimal.new("0.01"),
            aux_num: 0,
            min_leverage: 21,
            max_leverage: 50
          },
          %Bracket{
            notional_bracket: 2,
            floor_notional: 5000,
            cap_notional: 25000,
            maint_ratio: Decimal.new("0.025"),
            aux_num: 75,
            min_leverage: 11,
            max_leverage: 20
          }
        ]
      }

      assert expected ==
               json_fixture("binance/events/contract_info")
               |> ContractInfoEvent.from!()
    end
  end

  describe "MarkPriceUpdateEvent" do
    alias ExchangeZoo.Binance.Model.MarkPriceUpdateEvent

    test "should parse markPriceUpdate event" do
      expected = %MarkPriceUpdateEvent{
        event_time: 1_562_305_380_000,
        symbol: "BTCUSDT",
        mark_price: Decimal.new("11794.15000000"),
        index_price: Decimal.new("11784.62659091"),
        estimated_settle_price: Decimal.new("11784.25641265"),
        funding_rate: Decimal.new("0.00038167"),
        next_funding_time: 1_562_306_400_000
      }

      assert expected ==
               json_fixture("binance/events/mark_price_update")
               |> MarkPriceUpdateEvent.from!()
    end
  end

  describe "ListenKeyExpiredEvent" do
    alias ExchangeZoo.Binance.Model.ListenKeyExpiredEvent

    test "should parse listenKeyExpired event" do
      expected = %ListenKeyExpiredEvent{event_time: 1_576_653_824_250}

      assert expected ==
               json_fixture("binance/events/listen_key_expired")
               |> ListenKeyExpiredEvent.from!()
    end
  end

  describe "MarginCallEvent" do
    alias ExchangeZoo.Binance.Model.MarginCallEvent

    test "should parse MARGIN_CALL event" do
      expected = %MarginCallEvent{
        event_time: 1_587_727_187_525,
        cross_wallet_balance: Decimal.new("3.16812045"),
        positions: [
          %MarginCallEvent.Position{
            symbol: "ETHUSDT",
            side: :long,
            amount: Decimal.new("1.327"),
            margin_type: :crossed,
            isolated_wallet: Decimal.new(0),
            mark_price: Decimal.new("187.17127"),
            unrealized_pnl: Decimal.new("-1.166074"),
            maint_margin_req: Decimal.new("1.614445")
          }
        ]
      }

      assert expected ==
               json_fixture("binance/events/margin_call")
               |> MarginCallEvent.from!()
    end
  end

  describe "AccountUpdateEvent" do
    alias ExchangeZoo.Binance.Model.AccountUpdateEvent
    alias ExchangeZoo.Binance.Model.AccountUpdateEvent.{AccountUpdate, Balance, Position}

    test "should parse ACCOUNT_UPDATE event" do
      expected = %AccountUpdateEvent{
        event_time: 1_564_745_798_939,
        transaction_time: 1_564_745_798_938,
        account_update: %AccountUpdate{
          reason_type: :order,
          balances: [
            %Balance{
              asset: "USDT",
              wallet_balance: Decimal.new("122624.12345678"),
              cross_wallet_balance: Decimal.new("100.12345678"),
              balance_change: Decimal.new("50.12345678")
            },
            %Balance{
              asset: "BUSD",
              wallet_balance: Decimal.new("1.00000000"),
              cross_wallet_balance: Decimal.new("0E-8"),
              balance_change: Decimal.new("-49.12345678")
            }
          ],
          positions: [
            %Position{
              symbol: "BTCUSDT",
              side: :both,
              amount: Decimal.new(0),
              entry_price: Decimal.new("0.00000"),
              accumulated_realized: Decimal.new(200),
              unrealized_pnl: Decimal.new(0),
              margin_type: :isolated,
              isolated_wallet: Decimal.new("0E-8")
            },
            %Position{
              symbol: "BTCUSDT",
              side: :long,
              amount: Decimal.new(20),
              entry_price: Decimal.new("6563.66500"),
              accumulated_realized: Decimal.new(0),
              unrealized_pnl: Decimal.new("2850.21200"),
              margin_type: :isolated,
              isolated_wallet: Decimal.new("13200.70726908")
            },
            %Position{
              symbol: "BTCUSDT",
              side: :short,
              amount: Decimal.new(-10),
              entry_price: Decimal.new("6563.86000"),
              accumulated_realized: Decimal.new("-45.04000000"),
              unrealized_pnl: Decimal.new("-1423.15600"),
              margin_type: :isolated,
              isolated_wallet: Decimal.new("6570.42511771")
            }
          ]
        }
      }

      assert expected ==
               json_fixture("binance/events/account_update_order")
               |> AccountUpdateEvent.from!()
    end
  end

  describe "OrderTradeUpdateEvent" do
    alias ExchangeZoo.Binance.Model.OrderTradeUpdateEvent

    test "should parse ORDER_TRADE_UPDATE event" do
      expected = %OrderTradeUpdateEvent{
        event_time: 1_568_879_465_651,
        transaction_time: 1_568_879_465_650,
        order_update: %OrderTradeUpdateEvent.OrderUpdate{
          symbol: "BTCUSDT",
          client_order_id: "TEST",
          side: :sell,
          order_type: :trailing_stop_market,
          time_in_force: :gtc,
          original_quantity: Decimal.new("0.001"),
          original_price: Decimal.new(0),
          avg_price: Decimal.new(0),
          stop_price: Decimal.new("7103.04"),
          execution_type: :new,
          order_status: :new,
          order_id: 8_886_774,
          order_last_filled_qty: Decimal.new(0),
          total_filled: Decimal.new(0),
          last_fill_price: Decimal.new(0),
          commission_asset: "USDT",
          commission_amount: Decimal.new(0),
          order_trade_time: 1_568_879_465_650,
          trade_id: 0,
          bid_notional: Decimal.new(0),
          ask_notional: Decimal.new("9.91"),
          maker_side: false,
          reduce_only: false,
          stop_price_working_type: :contract_price,
          original_order_type: :trailing_stop_market,
          position_side: :long,
          close_all: false,
          activation_price: Decimal.new("7476.89"),
          callback_rate: Decimal.new("5.0"),
          realized_profit: Decimal.new(0)
        }
      }

      assert expected ==
               json_fixture("binance/events/order_trade_update")
               |> OrderTradeUpdateEvent.from!()
    end
  end

  describe "TradeLiteEvent" do
    alias ExchangeZoo.Binance.Model.TradeLiteEvent

    test "should parse TRADE_LITE event" do
      expected = %TradeLiteEvent{
        event_time: 1_721_895_408_092,
        transaction_time: 1_721_895_408_214,
        symbol: "BTCUSDT",
        maker_side: false,
        side: :buy,
        original_quantity: Decimal.new("0.001"),
        original_price: Decimal.new("0"),
        order_last_filled_qty: Decimal.new("0.040"),
        last_fill_price: Decimal.new("64089.20"),
        client_order_id: "z8hcUoOsqEdKMeKPSABslD",
        order_id: 8_886_774,
        trade_id: 109_100_866
      }

      assert expected ==
               json_fixture("binance/events/trade_lite")
               |> TradeLiteEvent.from!()
    end
  end

  describe "AccountConfigUpdateEvent" do
    alias ExchangeZoo.Binance.Model.AccountConfigUpdateEvent

    test "should parse ACCOUNT_CONFIG_UPDATE event" do
      expected = %AccountConfigUpdateEvent{
        event_time: 1_611_646_737_479,
        transaction_time: 1_611_646_737_476,
        trade_pair: %AccountConfigUpdateEvent.TradePair{
          symbol: "BTCUSDT",
          leverage: 25
        },
        margin_mode: nil
      }

      assert expected ==
               json_fixture("binance/events/account_config_update")
               |> AccountConfigUpdateEvent.from!()
    end
  end

  describe "StrategyUpdateEvent" do
    alias ExchangeZoo.Binance.Model.StrategyUpdateEvent

    test "should parse STRATEGY_UPDATE event" do
      expected = %StrategyUpdateEvent{
        event_time: 1_669_261_797_628,
        transaction_time: 1_669_261_797_627,
        strategy_update: %StrategyUpdateEvent.StrategyUpdate{
          strategy_id: 176_054_594,
          strategy_type: :grid,
          strategy_status: :new,
          symbol: "BTCUSDT",
          update_time: 1_669_261_797_627,
          opcode: 8007
        }
      }

      assert expected ==
               json_fixture("binance/events/strategy_update")
               |> StrategyUpdateEvent.from!()
    end
  end

  describe "GridUpdateEvent" do
    alias ExchangeZoo.Binance.Model.GridUpdateEvent

    test "should parse GRID_UPDATE event" do
      expected = %GridUpdateEvent{
        event_time: 1_669_262_908_218,
        transaction_time: 1_669_262_908_216,
        grid_update: %GridUpdateEvent.GridUpdate{
          strategy_id: 176_057_039,
          strategy_type: :grid,
          strategy_status: :working,
          symbol: "BTCUSDT",
          realized_pnl: Decimal.new("-0.00300716"),
          unmatched_avg_price: Decimal.new(16720),
          unmatched_qty: Decimal.new("-0.001"),
          unmatched_fee: Decimal.new("-0.00300716"),
          matched_pnl: Decimal.new("0.0"),
          update_time: 1_669_262_908_197
        }
      }

      assert expected ==
               json_fixture("binance/events/grid_update")
               |> GridUpdateEvent.from!()
    end
  end

  describe "AssetIndexEvent" do
    alias ExchangeZoo.Binance.Model.AssetIndexUpdateEvent

    test "should parse assetIndex event" do
      expected = %AssetIndexUpdateEvent{
        event_time: 1_685_120_787_000,
        symbol: "ADAUSD",
        index: Decimal.new("0.35965432"),
        bid_buffer: Decimal.new("0.10000000"),
        ask_buffer: Decimal.new("0.10000000"),
        bid_rate: Decimal.new("0.32368889"),
        ask_rate: Decimal.new("0.39561976"),
        auto_exchange_bid_buffer: Decimal.new("0.05000000"),
        auto_exchange_ask_buffer: Decimal.new("0.05000000"),
        auto_exchange_bid_rate: Decimal.new("0.34167161"),
        auto_exchange_ask_rate: Decimal.new("0.37763704")
      }

      assert expected ==
               json_fixture("binance/events/asset_index_update")
               |> AssetIndexUpdateEvent.from!()
    end
  end

  describe "Klines" do
    alias ExchangeZoo.Binance.Model.Kline

    test "should parse /fapi/v1/klines" do
      expected = [
        %Kline{
          open_time: 1499040000000,
          open: Decimal.new("0.01634790"),
          high: Decimal.new("0.80000000"),
          low: Decimal.new("0.01575800"),
          close: Decimal.new("0.01577100"),
          volume: Decimal.new("148976.11427815"),
          close_time: 1499644799999,
          quote_asset_volume: Decimal.new("2434.19055334"),
          trades: 308,
          taker_buy_base_asset_volume: Decimal.new("1756.87402397"),
          taker_buy_quote_asset_volume: Decimal.new("28.46694368")
        }
      ]

      assert expected ==
               json_fixture("binance/fapi_v1_klines")
               |> Enum.map(&Kline.from!/1)
    end
  end
end
