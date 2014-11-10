-module(scheduler_pool).

-export([start_link/1]).

start_link(SchedulerOpts) ->
  poolboy:start_link([
      {name, {local, scheduler}},
      {worker_module, scheduler},
      {size, proplists:get_value(pool_size, SchedulerOpts)},
      {max_overflow, 0}
    ], SchedulerOpts).
