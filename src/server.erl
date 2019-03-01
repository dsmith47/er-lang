-module(server).
-import(array_2d, [new/3, get/3, set/4, array_to_csv/1]).
-import(hits, [new/0, update/2, get/2, cleanup/1]).
-export([start/0]).


start() -> start(8081, 20).

%test(Canvas) ->
%    io:fwrite("\n"),
%    io:fwrite(integer_to_list(array_2d:get(1,5,Canvas))).

flush_buffer(Canvas, HitTable) ->
    receive
	{post, Packet} -> 
	    {Response, Canvas2} = post_pixel_response(Canvas,Packet),
	    flush_buffer(Canvas2, HitTable);
	{hit, UserAgent} ->
            flush_buffer(Canvas, hits:update(UserAgent,HitTable))
    after 0 -> {Canvas, HitTable}
    end.

start(Port, Size) ->
    Canvas = array_2d:new(Size, Size, 0),
    HitTable = hits:new(),
    spawn(fun () -> {ok, Sock} = gen_tcp:listen(Port, [{active, false}]), 
		    loop(Sock, Canvas, HitTable) end).

loop(Sock, Canvas, HitTable) ->
    case gen_tcp:accept(Sock, 500) of
        {error, timeout} -> 
            {Canvas2, HitTable2} = flush_buffer(Canvas, HitTable),
            loop(Sock, Canvas2, HitTable2);
	{ok, Conn} ->
            MyPid = self(),
            Handler = spawn(fun() -> 
			handle(MyPid, Conn, Canvas, HitTable) end),
            gen_tcp:controlling_process(Conn, Handler),
    
            {Canvas2, HitTable2} = flush_buffer(Canvas, HitTable),
	    gen_tcp:send(Conn, response("ok")), 
	    loop(Sock, Canvas2, HitTable2)
    end.

handle(Parent, Conn, Canvas, HitTable) ->
    %test(Canvas),
    {ok, Packet} = gen_tcp:recv(Conn, 0),
    UserAgent = get_user_agent(Packet),

    case get_req_type(Packet) of
      "POST" -> 
		case hits:is_ready(UserAgent, HitTable) of
		    true ->
			Parent ! {post, Packet},
			Parent ! {hit, UserAgent};
		    false -> io:fwrite("Patience, grasshopper. Your time will come again soon.\n")
		end;
      "GET"  -> gen_tcp:send(Conn,
			     response(get_canvas_response(Canvas)))
                end,
    %gen_tcp:send(Conn, response("Hello World")),
    gen_tcp:close(Conn).

get_canvas_response(Canvas) -> array_to_csv(Canvas).

get_post_info(Data) ->
    Result = string:trim(string:find(Data, "\r\n\r\n")),
    SplitSecond = fun(X) -> string:to_integer(lists:nth(2, string:split(X, "="))) end,
    lists:map(SplitSecond, string:lexemes(Result, "&")).


post_pixel_response(Canvas, Packet) ->
    [{Row, _}, {Col, _}, {Color, _}] = get_post_info(Packet),
    Canvas2 = array_2d:set(Row, Col, Color, Canvas),
    {"ok", Canvas2}.

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
