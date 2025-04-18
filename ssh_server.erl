-module(ssh_server).
-export([start/0]).

start() ->
    io:format("Starting vulnerable SSH server~n"),
    application:ensure_all_started(ssh),
    case ssh:daemon(2222, [
        {system_dir, "/root/ssh_keys"},
        {auth_methods, "password"},
        {pwdfun, fun(User, Pass) ->
            io:format("Login attempt ~p/~p~n", [User, Pass]),
            true
        end}
    ]) of
        {ok, Pid} ->
            io:format("SSH Daemon started successfully. Pid: ~p~n", [Pid]);
        {error, Reason} ->
            io:format("Failed to start SSH daemon: ~p~n", [Reason])
    end.
