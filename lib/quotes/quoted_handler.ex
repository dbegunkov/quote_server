defmodule Quotes.Quoted_handler do
  @behaviour :cowboy_http_handler

  def init({_any, :http}, req, []) do
    {:ok, req, :undefined}
  end

  def handle(req, state) do
    :ok  = Quotes.Limit_rate.check_limits([:all, :chat], "Bot1", "Chat1")
    {:ok, req} = :cowboy_req.reply 200, [], <<"OK, BOT">>, req
    {:ok, req, state}
  end

  def terminate(_request, _state) do
    :ok
  end
end
T
