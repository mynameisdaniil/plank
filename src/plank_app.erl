-module(plank_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  lager:info("Starting..."),
  plank_sup:start_link().

stop(_State) ->
  lager:info("Shutting down..."), ok.
