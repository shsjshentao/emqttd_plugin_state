-module(emqttd_plugin_state).

-include("../../../include/emqttd.hrl").

-define(APP, emqttd_plugin_state).

-export([load/1, unload/0]).

%% Hooks functions
-export([on_client_connected/3, on_client_disconnected/3]).

-export([connect/1, squery/1,squery/3]).




%% Called when the plugin application start
load(Env) ->
    emqttd:hook('client.connected', fun ?MODULE:on_client_connected/3, [Env]),
    emqttd:hook('client.disconnected', fun ?MODULE:on_client_disconnected/3, [Env]).    

on_client_connected(ConnAck, Client = #mqtt_client{client_id = ClientId}, _Env) ->
    {ok, ConnAction} = application:get_env(?APP, connected),
    lists:foreach(fun(X)->
        {Statement,Params} = parse_query(X),
        squery(Statement,Params,ClientId)
    end,ConnAction),
    {ok, Client}.

on_client_disconnected(Reason, ClientId, _Env) ->
    {ok, DisConnAction} = application:get_env(?APP, disconnected),
    lists:foreach(fun(X)->
        {Statement,Params} = parse_query(X),
        squery(Statement,Params,ClientId)
    end,DisConnAction),
    ok.

%% Called when the plugin application stop
unload() ->
    emqttd:unhook('client.connected', fun ?MODULE:on_client_connected/3),
    emqttd:unhook('client.disconnected', fun ?MODULE:on_client_disconnected/3).

parse_query(undefined) ->
    undefined;
parse_query(Sql) ->
    case re:run(Sql, "'%[uca]'", [global, {capture, all, list}]) of
        {match, Variables} ->
            Params = [Var || [Var] <- Variables],
            {re:replace(Sql, "'%[uca]'", "?", [global, {return, list}]), Params};
        nomatch ->
            {Sql, []}
    end.

replvar(Params, ClientId) ->
    replvar(Params, ClientId, []).

replvar([], ClientId, Acc) ->
    lists:reverse(Acc);
replvar(["'%c'" | Params], ClientId, Acc) ->
    replvar(Params, ClientId, [ClientId | Acc]);
replvar([Param | Params], ClientId, Acc) ->
    replvar(Params, ClientId, [Param | Acc]).


connect(Options) ->
    mysql:start_link(Options).

squery(Sql,Params,ClientId) ->
    ecpool:with_client(?MODULE, fun(C) -> mysql:query(C, Sql,replvar(Params,ClientId)) end).

squery(Sql) ->
    ecpool:with_client(?MODULE, fun(C) -> mysql:query(C, Sql) end).