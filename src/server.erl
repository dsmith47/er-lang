-module(server).
-import(array_2d, [new/3, get/3, set/4]).
-export([start/0]).

start() -> start(8080, 20).


start(Port, Size) ->
    Canvas = array_2d:new(Size, Size, 0),
    spawn(fun () -> {ok, Sock} = gen_tcp:listen(Port, [{active, false}]), 
		    loop(Sock, Canvas) end).

loop(Sock, Canvas) ->
    {ok, Conn} = gen_tcp:accept(Sock),
    Handler = spawn(fun () -> handle(Conn, Canvas) end),
    gen_tcp:controlling_process(Conn, Handler),
    loop(Sock, Canvas).

handle(Conn, Canvas) ->
    {ok, Packet} = gen_tcp:recv(Conn, 0),
    UserAgent = get_user_agent(Packet),
    io:fwrite(UserAgent),
    case get_req_type(Packet) of
      "GET"  -> gen_tcp:send(Conn,
                            response(get_canvas_response(Canvas)));
      "POST" -> gen_tcp:send(Conn, response(post_pixel_response(Canvas)))
    end,
    gen_tcp:send(Conn, response("Hello World")),
    gen_tcp:close(Conn).


get_canvas_response(Canvas) -> "GET".


post_pixel_response(Canvas) -> "POST".


get_user_agent(String) -> 
    UserAgent = string:find(String, "User-Agent"),
    lists:nth(1, string:split(UserAgent, "\r\n")).


get_req_type(String) ->
    lists:nth(1, string:split(lists:nth(1, string:split(String, "\r\n")), " ")).


response(Str) ->
    B = iolist_to_binary(Str),
    iolist_to_binary(
      io_lib:fwrite(
         "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ~p\n\n~s",
         [size(B), B])).
