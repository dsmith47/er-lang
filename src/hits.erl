-module(hits).
-export([new/0, update/2, is_ready/2, cleanup/1]).

new() ->
	dict:new().

update(UserAgent,Dict) ->
	dict:store(UserAgent,os:system_time(),Dict).

is_ready(UserAgent, Dict) ->
	case dict:is_key(UserAgent, Dict) of
		true ->
			os:system_time() - dict:fetch(UserAgent, Dict) > 500000000;
		false ->
			true
	end.

check(Keys,Dict) ->
	Key = lists:nth(0,Keys),
	Keys2 = lists:delete(Key, Keys),
	
	case is_ready(Key, Dict) of 
		true ->
			Dict2 = dict:erase(Key,Dict);
		false ->
			Dict2 = Dict
	end,

	case length(Keys2)<1 of 
		true ->
			Dict2;
		false ->
			check(Keys2, Dict2)
	end.

cleanup(Dict) ->
	Keys = dict:fetch_keys(),
	check(Keys, Dict).

