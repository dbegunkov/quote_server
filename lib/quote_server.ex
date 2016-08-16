defmodule QuoteServer do
  use Application
  def start(_type, _args) do
    IO.puts "Im started"
    dispatch = :cowboy_router.compile([
      {'_', [
          {"/", :quoted_handler, []}
      ]}
    ])
    _status = :application.start :ranch
    _status = :application.start :cowboy
    {:ok, _} = :cowboy.start_http(:http, 100, [{:port, 8080}], [env: [dispatch: dispatch]])
  end
end
