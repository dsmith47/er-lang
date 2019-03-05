-module(server).
-import(array_2d, [new/3, get/3, set/4, array_to_csv/1]).
-import(hits, [new/0, update/2, get/2, cleanup/1]).
-export([start/0]).


start() -> start(80, 20).

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
	    loop(Sock, Canvas2, HitTable2)
    end.

handle(Parent, Conn, Canvas, HitTable) ->
    {ok, Packet} = gen_tcp:recv(Conn, 0),
    UserAgent = get_user_agent(Packet),
    case get_req_type(Packet) of
      "OPTION" -> gen_tcp:send(Conn,
                               generate_option_response(Packet));
      "POST" -> 
		case hits:is_ready(UserAgent, HitTable) of
		    true ->
			Parent ! {post, Packet},
			Parent ! {hit, UserAgent},
		        gen_tcp:send(Conn, response("updated", Packet));
		    false -> gen_tcp:send(Conn,
                                          response("Patience, young " ++
                                                   "grasshopper. Your time will " ++
						   "come again soon.",
						   Packet))
		end;
      "GET"  -> (case get_req_data(Packet) of
		    "/" -> gen_tcp:send(Conn, response(file_to_string("../Client/index.html"),Packet));
		    "_" -> gen_tcp:send(Conn,
			     response(get_canvas_response(Canvas),
                                                          Packet))
		 end)
	end,
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

extract_packet_field(Packet, Key) ->	
    Field = string:find(Packet, Key),
    try lists:nth(2, string:split(
                   lists:nth(1, string:split(Field, "\r\n")), ": ")) of
	_ -> lists:nth(2, string:split(
                   lists:nth(1, string:split(Field, "\r\n")), ": ")) 
    catch
	_:_ -> ""
    end.

	 
get_req_type(String) ->
    lists:nth(1, string:split(lists:nth(1, string:split(String, "\r\n")), " ")).

get_req_data(String) ->
    Cdr = lists:nth(2, string:split(lists:nth(1, string:split(String, "\r\n")), " ")),
    lists:nth(1, string:split(Cdr, " ")).

generate_option_response(Str) ->
  iolist_to_binary(
    io_lib:fwrite("HTTP/1.0 200 OK\n\n", [])).

file_to_string(String) ->
	{ok, FileHandler} = file:open(String, [read]),
	try get_lines(FileHandler)
	after file:close(FileHandler)
	end.

get_lines(FileHandler) ->
	case io:get_line(FileHandler, "") of
		eof -> [];
		Line -> Line ++ get_lines(FileHandler)
	end.


response(Str, Request) ->
    B = iolist_to_binary(Str),
    iolist_to_binary(
      io_lib:fwrite(
         "HTTP/1.0 200 OK\n" ++
         "Content-Type: text/html\n" ++
	 "Access-Control-Allow-Origin: " ++
	   extract_packet_field(Request, "Origin") ++ "\n" ++
	 "Access-Control-Allow-Methods: GET, POST\n" ++
	 "Access-Control-Allow-Headers: Content-Type, Content-Length\n" ++
         "Content-Length: ~p\n\n~s",
         [size(B), B])).
