-module(server).
-export([start/0]).

start() -> start(8080).

% get_req_type(Str) -> lists:nth(1, string:split(lists:nth(1,
%                                    strings:split(Str,"\n")), " ")).

get_req_type(Str) -> lists:nth(1,vstrings:split(Str, "\n")).

start(Port) ->
    spawn(fun () -> {ok, Sock} = gen_tcp:listen(Port, [list,{active, false},{packet,http}]), 
                    loop(Sock) end).

loop(Sock) ->
    {ok, Conn} = gen_tcp:accept(Sock),
    Handler = spawn(fun () -> handle(Conn) end),
    gen_tcp:controlling_process(Conn, Handler),
    loop(Sock).

% TODO(dsmith47): this is no longer a binary, but a list
handle(Conn) ->
    %%gen_tcp:send(Conn, response("Hello World")),
    case gen_tcp:recv(Conn, 0) of
      {ok, {http_request, Method, Path, _Version}} ->
                      case Method of
                        'GET' -> gen_tcp:send(Conn,
                                              response(get_canvas_response()));
                        'POST' -> gen_tcp:send(Conn, response(post_pixel_response()))
                      end
    end,
    gen_tcp:send(Conn, response("Hello World")),
    gen_tcp:close(Conn).

get_canvas_response() -> "GET".

post_pixel_response() -> "POST".

response(Str) ->
    B = iolist_to_binary(Str),
    iolist_to_binary(
      io_lib:fwrite(
         "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ~p\n\n~s",
         [size(B), B])).
