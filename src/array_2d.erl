-module(array_2d).
-export([new/2, get/3, set/4]).

new(Rows, Cols)->
    A = array:new(Rows),
    array:map(fun(_X, _T) -> array:new(Cols) end, A).

get(RowI, ColI, A) ->
    Row = array:get(RowI, A),
    array:get(ColI, Row).

set(RowI, ColI, Ele, A) ->
    Row = array:get(RowI, A),
    Row2 = array:set(ColI, Ele, Row),
    array:set(RowI, Row2, A).
