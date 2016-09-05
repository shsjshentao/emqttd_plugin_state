-module(emqttd_plugin_state_sup).

-behaviour(supervisor).

-define(APP, emqttd_plugin_state).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    {ok, Env} = application:get_env(?APP, mysql_pool),
	io:format("aaaaaaaa"),
    PoolSpec = ecpool:pool_spec(?APP, ?APP, ?APP, Env),

    {ok, { {one_for_all, 10, 100}, [PoolSpec]} }.


