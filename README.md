
emqttd_plugin_state
======================

用户上下线记录插件（免编译版）
使用了MYSQL鉴权插件的驱动和pool，无需源码编译可直接使用

./bin/emqttd_ctl plugins load emqttd_plugin_state
./bin/emqttd_ctl plugins unload emqttd_plugin_state

为保证正确性必须随emqtt broker同时启动

配置文件

[

  {emqttd_plugin_state, [

    {mysql_pool, [
        %% ecpool options
        {pool_size, 8},
        {auto_reconnect, 1},

        %% mysql options
        {host,     "xxx"},
        {port,     3306},
        {user,     "xxx"},
        {password, "xxx"},
        {database, "xxx"},
        {encoding, utf8},
        {keep_alive, true}
    ]},
    {start, ["UPDATE user SET state=0", "UPDATE device SET state=0"]},
    {connected, ["UPDATE user SET state=1 WHERE user_id='%c'", "UPDATE device SET state=1 WHERE device_id='%c'"]},
    {disconnected, ["UPDATE user SET state=0 WHERE user_id='%c'", "UPDATE device SET state=0 WHERE device_id='%c'"]},
    {over, ["UPDATE user SET state=0", "UPDATE device SET state=0"]}
  ]}

].

目前用户上下线识别只支持%c（client id）参数，sql语句可执行一个或多个
