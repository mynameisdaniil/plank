-module(scheduler_pool).

-export([start_link/0]).

start_link() ->
  poolboy:start_link([
      {name, {local, scheduler}},
      {worker_module, scheduler},
      {size, 2},
      {max_overflow, 0}
    ]).
