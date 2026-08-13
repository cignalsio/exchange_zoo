# TODO: Replace most of this with Req.Steps decoder, etc
defmodule ExchangeZoo.Response do
  require Logger

  def decompress_body(response) do
    case get_content_encoding(response.headers) do
      nil ->
        response

      encoding ->
        list = compression_algorithms(encoding)
        decompress_body(response, list)
    end
  end

  def decompress_body(%Finch.Response{} = response, [algorithm | rest])
      when algorithm in ["gzip", "x-gzip"] do
    decompress_body(%Finch.Response{response | body: :zlib.gunzip(response.body)}, rest)
  end

  def decompress_body(response, ["identity" | rest]), do: decompress_body(response, rest)

  def decompress_body(response, [codec | rest]) do
    Logger.warning(fn -> "Codec #{codec} not supported" end)
    decompress_body(response, rest)
  end

  def decompress_body(response, []), do: response

  defp get_content_encoding(headers) do
    case List.keyfind(headers, "content-encoding", 0) do
      {"content-encoding", encoding} ->
        encoding

      _ ->
        nil
    end
  end

  defp compression_algorithms(value) do
    value
    |> String.downcase()
    |> String.split(",", trim: true)
    |> Enum.map(&String.trim/1)
    |> Enum.reverse()
  end
end
