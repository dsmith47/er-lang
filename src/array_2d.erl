-module(array_2d).
-export([new/3, get/3, set/4, array_to_csv/1]).

new(Rows, Cols, Init) ->
    array:new( [{size, Rows}, {default, array:new([{size, Cols}, {default, Init}])}] ).


get(Row, Col, Array) ->
    array:get(Col, array:get(Row, Array)).


set(Row, Col, Value, Array) ->
    R = array:get(Row, Array),
    Edit_R = array:set(Col, Value, R),
    array:set(Row, Edit_R, Array).

%array_to_csv(Array) -> "0,0,0\n0,0,0\n0,0,0\n".
array_to_csv(Array) -> 
    io:fwrite("~p\n", [Array]),
    array:foldl(fun (_, Arr, Acc) ->
        string:concat(Acc, array:foldl(fun (_, T, A) -> 
				      string:concat(A, lists:flatten(io_lib:format("~p,", [T])))
				  end, "\n", Arr))
        end, "", Array).
