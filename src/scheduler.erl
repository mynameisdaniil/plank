-module(scheduler).

-behaviour(gen_server).
-behaviour(poolboy_worker).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, code_change/3]).

start_link(Args) ->
  gen_server:start_link(?MODULE, Args, []).

init(_Args) ->
  {ok, undefined}.

handle_call({schedule, Timediff, Payload}, _From, State) ->
  lager:info("Scheduling: ~s with ~p", [Timediff, Payload]),
  {reply, {ok, [], Timediff}, State};

handle_call({get, Timediff}, _From, State) ->
  lager:info("Returning: ~s", [Timediff]),
  {reply, {ok, [], Timediff}, State};

handle_call(_, _From, State) -> {ok, undefined, State}.

handle_cast(_, State) -> {noreply, State}.

handle_info(_, State) -> {noreply, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.
