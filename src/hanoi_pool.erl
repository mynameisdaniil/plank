-module(hanoi_pool).

-behaviour(gen_server).

-export([start_link/1]).
-export([transaction/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2]).
-export([terminate/2, code_change/3]).

-record(state, {pool, pool_size, pool_sup}).

start_link(HanoiPoolOpts) ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, HanoiPoolOpts, []).

build_list(N) ->
  build_list(N, []).
build_list(0, List) -> List;
build_list(N, List) -> build_list(N-1, [N-1 | List]).

init(HanoiPoolOpts) ->
  BasePath = proplists:get_value(data_root, HanoiPoolOpts),
  PoolSize = proplists:get_value(pool_size, HanoiPoolOpts),
  {ok, HanoiPoolSup} = hanoi_pool_sup:start_link(),
  HanoiPool = lists:map(fun(N) ->
        DataRoot = filename:join(BasePath, erlang:integer_to_binary(N)),
        filelib:ensure_dir(DataRoot),
        case supervisor:start_child(HanoiPoolSup,
            {N,
              {hanoidb, open_link, [DataRoot]},
              permanent,
              5000,
              worker,
              [hanoidb]
            }
          ) of
          {ok, HanoiInstance} ->        {N, HanoiInstance};
          {ok, HanoiInstance, _Info} -> {N, HanoiInstance}
        end
    end, build_list(PoolSize)),
  {ok, #state{pool = maps:from_list(HanoiPool), pool_size = PoolSize, pool_sup = HanoiPoolSup}}.

transaction(Key, Fun) ->
  gen_server:call(?MODULE, {transaction, Key, Fun}).

handle_call({transaction, Key, Fun}, From, #state{pool = Pool, pool_size = PoolSize} = State) ->
  Worker = maps:get(erlang:phash2(Key, PoolSize), Pool),
  spawn(fun()->
        gen_server:reply(From, Fun(Worker))
    end),
  {noreply, State};

handle_call(_, _From, State) -> {reply, undefined, State}.

handle_cast(_, State) -> {noreply, State}.

handle_info(_, State) -> {noreply, State}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

terminate(_Reason, _State) -> ok.
