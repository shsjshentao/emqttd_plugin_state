-module(emqttd_plugin_state_app).

-behaviour(application).

-define(APP, emqttd_plugin_state).

-import(emqttd_plugin_state, [squery/1]).

%% Application callbacks
-export([start/2, prep_stop/1, stop/1]).

start(_StartType, _StartArgs) ->
    {ok, Sup} = emqttd_plugin_state_sup:start_link(),
    emqttd_plugin_state:load(application:get_all_env()),
    {ok, StartAction} = application:get_env(?APP, start),
	lists:foreach(fun(X)->
        squery(X)
    end,StartAction),
    {ok, Sup}.

prep_stop(State) ->
	{ok, OverAction} = application:get_env(?APP, over),
	lists:foreach(fun(X)->
        squery(X)
    end,OverAction),
    State.

stop(_State) ->
    emqttd_plugin_state:unload().