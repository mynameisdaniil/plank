-module(rest).

-include_lib("elli/include/elli.hrl").

-behaviour(elli_handler).

-export([handle/2, handle_event/3]).

handle(Req, Args) ->
  lager:info("Handling request ~p,~nwith args: ~p", [Req, Args]),
  {ok, [], <<"Hello Elli!">>}.

handle_event(_Event, _Data, _Args) -> ok.
