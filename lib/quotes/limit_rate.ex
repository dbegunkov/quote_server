defmodule Quotes.Limit_rate do
  @limit_all 30 ## per seconds
  @limit_chat 30 ## per minute
  @limit_die 10 ## max seconds sleep
  @sleep_all 1000 ## in miliseconds
  @sleep_chat 10000 ## in miliseconds

  def check_limits([], NameBot, NameChat, StartTimer ) do
    :ok
  end
  def check_limits([Limit | T], NameBot, NameChat, StartTimer) do
    check_limit(Limit, NameBot, NameChat, StartTimer)
    check_limits(T, NameBot, NameChat, StartTimer)
  end

  def check_limit(type_limit, NameBot, NameChat, StartTimer) do
    Now = int_timestamp()
    Counter = case :ets.lookup(:limit_rate_all,{NameBot, Now}) do
                [] -> 1
                [{_, L}] -> L + 1
              end
    NameEts = :erlang.binary_to_atom("limit_rate_" <> type_limit, :utf8)
    :ets.insert(NameEts, {{NameBot, Now}, Counter})
    {RateQuery, Sleep, LimitDie} = get_params_cheking(type_limit)
    case Counter do
      C when C > RateQuery ->
        check_die(LimitDie, StartTimer, Now)
        :timer.sleep(Sleep)
        check_limit(type_limit, NameBot, NameChat, StartTimer)
      _ ->
        :ok
    end
  end

  def check_die(LimitDie, StartTimer, Now) when Now - StartTimer > LimitDie do
                                                      raise "limit over"
  end
  def check_die(_LimitDie, _StartTimer, _Now) do
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
    {Mega, Secs, _Micro} = :os.timestamp()
    Mega * 1000000 + Secs
  end

end
