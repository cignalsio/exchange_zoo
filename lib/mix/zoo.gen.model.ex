defmodule Mix.Tasks.Zoo.Gen.Model do
  @shortdoc "Generates a Model"

  @moduledoc """
  Generates boilerplate code for a Model.

      $ mix zoo.gen.model Exchange Record message:string code:integer
      $ mix zoo.gen.model Exchange Record --example=example.json

  Accepts the module name for the exchange, a module name for the model, and a
  list of attributes with Ecto types.  Alternatively, an example JSON file can
  be given to infer the model attributes.

  The generated files will contain:

    * a model `lib/zoo/exchange/model/record.ex`

  """

  @switches [handle: :string]
  @default_opts []
  @template_path "priv/templates/zoo.gen.model"

  use Mix.Task

  alias Mix.Zoo.{Exchange, Model}

  def run(args) do
    build(args)
  end

  def build(args) do
    {opts, parsed, _} = parse_opts(args)

    [exchange_name, model_name | attrs] = validate_args!(parsed)

    exchange = Exchange.new(exchange_name, opts)
    model = Model.new(model_name, attrs)

    copy_new_files(exchange, model)
    inject_files(exchange, model)
  end

  @doc false
  def inject_files(%Exchange{} = exchange, %Model{} = model) do
    template_file = Path.join([@template_path, "model_test_describe_block.ex.eex"])
    dest_file = Path.join(["test", exchange.handle, "model_test.exs"])

    Mix.Zoo.inject_from(
      template_file,
      dest_file,
      [
        exchange: exchange,
        model: model,
        endpoint_path: "/v1/example_endpoint",
        json_fixture_filename: "example_endpoint"
      ]
    )
  end

  @doc false
  def files_to_be_generated(%Exchange{} = exchange, %Model{} = model) do
    module_path = Path.join(["lib", "zoo", exchange.handle, "model"])
    model_file = Macro.underscore(model.name) <> ".ex"

    test_path = Path.join(["test", exchange.handle])

    [
      {"model.ex", Path.join([module_path, model_file])},
      {"model_test.exs", Path.join([test_path, "model_test.exs"])}
    ]
  end

  @doc false
  def copy_new_files(%Exchange{} = exchange, %Model{} = model) do
    fixture_path = Path.join(["test", "support", "fixtures", exchange.handle])
    Mix.Generator.create_directory(fixture_path)

    files = files_to_be_generated(exchange, model)
    Mix.Zoo.copy_from(@template_path, [exchange: exchange, model: model], files)

    exchange
  end

  defp parse_opts(args) do
    {opts, parsed, invalid} = OptionParser.parse(args, switches: @switches)

    merged_opts = Keyword.merge(@default_opts, opts)

    {merged_opts, parsed, invalid}
  end

  defp validate_args!([exchange_name, model_name | _] = args) do
    cond do
      not Exchange.valid?(exchange_name) ->
        raise_with_help(
          "Expected the exchange, #{inspect(exchange_name)}, to be a valid module name"
        )

      not Model.valid?(model_name) ->
        raise_with_help(
          "Expected the model, #{inspect(model_name)}, to be a valid module name"
        )

      true ->
        args
    end
  end

  defp validate_args!(_) do
    raise_with_help("Invalid arguments")
  end

  @doc false
  @spec raise_with_help(binary) :: no_return
  def raise_with_help(msg) do
    Mix.raise("""
    #{msg}

    mix zoo.gen.model expects both an exchange and model
    module name for the resource followed by any number of attributes:

        mix zoo.gen.model Binance Error code:integer message:string
    """)
  end
end
