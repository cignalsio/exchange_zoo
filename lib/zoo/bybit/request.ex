defmodule ExchangeZoo.Bybit.Request do
  alias ExchangeZoo.Request
  alias ExchangeZoo.Bybit.Model.Error

  def perform_public(url, method, params, mod) do
    url = append_query_params(url, params)

    Finch.build(method, url)
    |> Request.perform(mod, Error, &decode/3)
  end

  def perform_private(url, method, params, mod, opts) do
    api_key = Keyword.fetch!(opts, :api_key)
    secret_key = Keyword.fetch!(opts, :secret_key)

    timestamp =
      Keyword.get(opts, :timestamp, DateTime.utc_now() |> DateTime.to_unix(:millisecond))

    recv_window = Keyword.get(opts, :recv_window, 5000)

    body = Jason.encode!(params)

    Finch.build(method, url, [], body)
    |> Request.add_header("X-BAPI-API-KEY", api_key)
    |> Request.add_header("X-BAPI-TIMESTAMP", to_string(timestamp))
    |> Request.add_header("X-BAPI-RECV-WINDOW", to_string(recv_window))
    |> Request.put_header_signature("X-BAPI-SIGN", secret_key, fn request ->
      "#{timestamp}#{api_key}#{recv_window}#{request.query}#{request.body}"
    end)
    |> Request.perform(mod, Error, &decode/3)
  end

  defdelegate append_query_params(uri, opts), to: Request

  defp decode(%Finch.Response{status: 200} = response, mod, error_mod) do
    case Jason.decode(response.body) do
      # TODO: there's a retExtInfo that looks like it returns a result code for
      # each object in a list - should we include that somehow?
      {:ok, %{"retCode" => 0, "result" => %{"list" => data}}} ->
        {:ok, Enum.map(data, &Request.model_from_data(&1, mod))}

      {:ok, %{"retCode" => 0, "result" => data}} ->
        {:ok, Request.model_from_data(data, mod)}

      {:ok, data} ->
        {:error, response.status, Request.model_from_data(data, error_mod)}

      {:error, reason} ->
        {:error, response.status, reason}
    end
  end

  defp decode(response, _mod, error_mod) do
    case Jason.decode(response.body) do
      {:ok, data} ->
        {:error, response.status, Request.model_from_data(data, error_mod)}

      {:error, reason} ->
        {:error, response.status, reason}
    end
  end
end
