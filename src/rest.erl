-module(rest).

-include_lib("elli/include/elli.hrl").

-behaviour(elli_handler).

-export([handle/2, handle_event/3]).

handle(Req, Args) ->
  handle(Req#req.method, elli_request:path(Req), Req).

handle('PUT', [<<"schedule">>], Req) ->
  poolboy:transaction(scheduler,
    fun(Worker) ->
        gen_server:call(Worker, {schedule, Req})
    end);

handle(_, _, _Req) -> {404, [], <<"Not found">>}.

handle_event(_Event, _Data, _Args) -> ok.
