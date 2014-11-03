-module(hanoi_pool).

-behaviour(supervisor).

-export([start_link/1]).
-export([init/1]).

start_link(Opts) ->
  supervisor:start_link({local, ?MODULE}, ?MODULE, Opts).


build_list(N) ->
  build_list(N, []).
build_list(0, List) -> List;
build_list(N, List) -> build_list(N-1, [N-1 | List]).


init(Opts) ->
  BasePath = proplists:get_value(data_root, Opts),
  PoolSize = proplists:get_value(pool_size, Opts),
  HanoiPool = lists:map(fun(N) ->
        DataRoot = filename:join(BasePath, erlang:integer_to_binary(N)),
        filelib:ensure_dir(DataRoot),
        {N,
          {hanoidb, open_link, [DataRoot]},
          permanent,
          5000,
          worker,
          [hanoidb]
        }
    end, build_list(PoolSize)),
  {ok, { {one_for_one, 5, 10}, HanoiPool}}.

