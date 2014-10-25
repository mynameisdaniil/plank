-module(plank_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
  {ok, ElliOpts} = application:get_env(web),
  WorkersPool = poolboy:child_spec(scheduler, [
      {name, {local, scheduler}},
      {worker_module, scheduler},
      {size, 2},
      {max_overflow, 0}
    ], []),
  {ok, { {one_for_one, 5, 10}, [
        {rest,
          {elli, start_link, [ElliOpts]},
          permanent,
          5000,
          worker,
          [elli]
        },
        WorkersPool
      ]}
  }.

