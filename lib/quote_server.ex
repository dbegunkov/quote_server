defmodule QuoteServer do
  use Application
  def start(_type, _args) do
    dispatch = :cowboy_router.compile([
      {'_', [
          {"/", :quoted_handler, []}
      ]}
    ])
    {:ok, _} = :cowboy.start_http(:http, 100, [{:port, 8080}], [env: [dispatch: dispatch]])
  end
end
