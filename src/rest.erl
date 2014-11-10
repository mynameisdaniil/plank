-module(rest).

-include_lib("elli/include/elli.hrl").

-behaviour(elli_handler).

-export([handle/2, handle_event/3]).

-define(SCHEDULER_CALL(Call), poolboy:transaction(scheduler, fun(W) -> gen_server:call(W, Call) end)).

handle(Req, _Args) ->
  handle(Req#req.method, elli_request:path(Req), Req).

handle('PUT', [<<"schedule">>, Timediff], Req) ->
  ?SCHEDULER_CALL({schedule, Timediff, elli_request:body(Req)});

handle(_, _, _) -> {404, [], <<"Not found\n">>}.

handle_event(_Event, _Data, _Args) -> ok.
