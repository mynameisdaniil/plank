-module(scheduler).

-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, code_change/3]).

-record(state, {granularity}).

start_link(SchedulerOpts) ->
  gen_server:start_link(?MODULE, SchedulerOpts, []).

init(SchedulerOpts) ->
  Granularity = proplists:get_value(granularity, SchedulerOpts),
  lager:info("Granularity:~p", [Granularity]),
  {ok, #state{granularity = Granularity}}.

handle_call({schedule, TimestampBin, Payload}, _From, #state{granularity = Granularity} = State) ->
  {MegaSecs, Secs, MicroSecs} = erlang:now(),
  CurrentTimestamp = (MegaSecs * 1000000 + Secs) * 1000 + MicroSecs div 1000,
  Timestamp = erlang:binary_to_integer(TimestampBin),
  Key = erlang:integer_to_binary((Timestamp - CurrentTimestamp) div Granularity),
  lager:info("Scheduling: ~p with ~p", [Key, Payload]),
  Result = hanoi_pool:transaction(Key, fun(Worker)->
        List = case hanoidb:get(Worker, Key) of
          not_found -> [];
          {ok, Data} -> erlang:binary_to_term(Data)
        end,
        UpdatedList = erlang:term_to_binary([Payload|List]),
        ok = hanoidb:put(Worker, Key, UpdatedList)
    end),
  lager:info("Transaction reply:~p", [Result]),
  {reply, {ok, [], TimestampBin}, State};

handle_call(_, _From, State) -> {ok, undefined, State}.

handle_cast(_, State) -> {noreply, State}.

handle_info(_, State) -> {noreply, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.
