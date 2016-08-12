defmodule Quotes.Limit_rate do
  @limit_all 30 ## per seconds
  @limit_chat 30 ## per minute
  @limit_die 10 ## max seconds sleep
  @sleep_all 1000 ## in miliseconds
  @sleep_chat 10000 ## in miliseconds

  def check_limits([], nameBot, nameChat, startTimer ) do
    :ok
  end
  def check_limits([limit | t], nameBot, nameChat, startTimer) do
    check_limit(limit, nameBot, nameChat, startTimer)
    check_limits(t, nameBot, nameChat, startTimer)
  end

  def check_limit(type_limit, nameBot, nameChat, startTimer) do
    now = int_timestamp()
    counter = case :ets.lookup(:limit_rate_all,{nameBot, now}) do
                [] -> 1
                [{_, L}] -> L + 1
              end
    nameEts = :erlang.binary_to_atom("limit_rate_" <> type_limit, :utf8)
    :ets.insert(nameEts, {{nameBot, now}, counter})
    {rateQuery, sleep, limitDie} = get_params_cheking(type_limit)
    case counter do
      c when c > rateQuery ->
        check_die(limitDie, startTimer, now)
        :timer.sleep(sleep)
        check_limit(type_limit, nameBot, nameChat, startTimer)
      _ ->
        :ok
    end
  end

  def check_die(limitDie, startTimer, now) when now - startTimer > limitDie do
                                                      raise "limit over"
  end
  def check_die(_limitDie, _startTimer, _now) do
    :ok
  end

  def get_params_cheking(:all) do
    {@limit_all, @sleep_all, @limit_die}
  end

  def get_params_cheking(:chat) do
    {@limit_chat, @sleep_chat, @limit_die}
  end

  def init_ets() do
    :ets.new(:limit_rate_all, [:named_table])
    :ets.new(:limit_rate_chat, [:named_table])
  end

  def int_timestamp() do
    {mega, secs, _Micro} = :os.timestamp()
    mega * 1000000 + Secs
  end

end
