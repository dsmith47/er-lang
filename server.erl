-module(server).
-export([start/0]).

start() -> start(8080).

start(Port) ->
    spawn(fun () -> {ok, Sock} = gen_tcp:listen(Port, [{active, false}]), 
                    loop(Sock) end).

loop(Sock) ->
    {ok, Conn} = gen_tcp:accept(Sock),
    Handler = spawn(fun () -> handle(Conn) end),
    gen_tcp:controlling_process(Conn, Handler),
    loop(Sock).

handle(Conn) ->
    {ok, Packet} = gen_tcp:recv(Conn, 0),
    UserAgent = get_user_agent(Packet),
    io:fwrite(UserAgent),
    gen_tcp:send(Conn, response("Hello World")),
    gen_tcp:close(Conn).


get_user_agent(String) -> 
    UserAgent = string:find(String, "User-Agent"),
    lists:nth(1, string:split(UserAgent, "\r\n")).

response(Str) ->
    B = iolist_to_binary(Str),
    iolist_to_binary(
      io_lib:fwrite(
         "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ~p\n\n~s",
         [size(B), B])).
