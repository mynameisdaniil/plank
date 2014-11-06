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
  {ok, HanoiPoolOpts} = application:get_env(hanoi_pool),
  {ok, SchedulerOpts} = application:get_env(scheduler),
  {ok, { {one_for_one, 5, 10}, [
        {rest,
          {elli, start_link, [ElliOpts]},
          permanent,
          5000,
          worker,
          [elli]
        },
        {hanoi_pool,
          {hanoi_pool, start_link, [HanoiPoolOpts]},
          permanent,
          5000,
          worker,
          [hanoi_pool]
        },
        {scheduler_pool,
          {scheduler_pool, start_link, [SchedulerOpts]},
          permanent,
          infinity,
          supervisor,
          [scheduler_pool]
        }
      ]}
  }.

