-module(scheduler_pool).

-export([start_link/1]).

start_link(SchedulerOpts) ->
  poolboy:start_link([
      {name, {local, scheduler}},
      {worker_module, scheduler},
      {size, 2},
      {max_overflow, 0}
    ], SchedulerOpts).
