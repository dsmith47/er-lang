-module(array_2d).
-export([new/3, get/3, set/4]).

new(Rows, Cols, Init) ->
    array:new( [{size, Rows}, {default, array:new([{size, Cols}, {default, Init}])}] ).


get(Row, Col, Array) ->
    array:get(Col, array:get(Row, Array)).


set(Row, Col, Value, Array) ->
    R = array:get(Row, Array),
    Edit_R = array:set(Col, Value, R),
    array:set(Row, Edit_R, Array).
