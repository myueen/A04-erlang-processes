%team("edlyn jeyaraj, yueen ma, thomas kung")

-module(process).
-export([serv1/1, start/0, serv2/1, serv3/1, sum_numbers/2, mul_numbers/2]).

serv1(Pid2) -> receive
    {add, X, Y} ->
        io:format("(serv1) Math handling: ~p + ~p = ~p~n", [X,Y,X+Y]),
        serv1(Pid2);
    {sub, X, Y} ->
        io:format("(serv1) Math handling: ~p - ~p = ~p~n", [X,Y,X-Y]),
        serv1(Pid2);
    {mult, X, Y} ->
        io:format("(serv1) Math handling: ~p * ~p = ~p~n", [X,Y,X*Y]),
        serv1(Pid2);
    {'div', X, Y} ->
        io:format("(serv1) Math handling: ~p / ~p = ~p~n", [X,Y,X/Y]),
        serv1(Pid2);
    {neg, X} ->
        io:format("(serv1) Math handling: -~p = ~p~n", [X,-1*X]),
        serv1(Pid2);
    {sqrt, X} ->
        io:format("(serv1) Math handling: sqrt(~p) = ~p~n", [X,math:pow(X,1/2)]),
        serv1(Pid2);
    halt ->
        io:format("(serv1) Forwarding halt message. ~n"),
        Pid2 ! halt,
        io:format("(serv1) Halting. ~n"); 
    Message ->
        io:format("(serv1) Forwarding message to server2: ~p~n", [Message]),
        Pid2 ! Message,
        serv1(Pid2)
    end.

start() ->
    Pid3 = spawn(?MODULE, serv3, [0]),
    Pid2 = spawn(?MODULE, serv2, [Pid3]),
    Pid1 = spawn(?MODULE, serv1, [Pid2]),
    
    loop(Pid1),
    loop(Pid2),
    loop(Pid3),
    okay.

 loop(P) ->
    {ok, Message} = io:read("Enter a message: "),
    if
        Message =:= all_done ->
            P ! halt;
        Message =/= all_done ->
            P ! Message,
            loop(P)
    end.


serv2(Pid3) -> 
    receive
        [Head | Tail] when is_integer(Head) -> 
            Summation = sum_numbers([Head|Tail], 0),
            io:format(">>(serv2) summation of all numbers ~p~n", [Summation]),
            serv2(Pid3);
        [Head | Tail] when is_float(Head) ->
            Product = mul_numbers([Head|Tail], 1),
            io:format(">>(serv2) products of all numbers ~p~n", [Product]),
            serv2(Pid3);
        halt ->
            io:format("(serv2) Forwarding halt message. ~n"),
            Pid3 ! halt,
            io:format("(serv2) Halting. ~n");
        Message ->
            io:format("(serv2) Forwarding message to server3: ~p~n", [Message]),
            Pid3 ! Message,
            serv2(Pid3)
    end.



serv3(Count) ->
    receive
        {error, X} ->
            io:format("(serv3) Error: ~p~n", [X]),
            serv3(Count);

        halt->
            io:format("(serv3) Received ~p unprocessed messages.~n", [Count]),
            io:format("(serv3) Halting.~n");

        Message->
            io:format("(serv3) Not handled: ~p~n", [Message]),
            serv3(Count+1)
    end.




sum_numbers([H|T], Acc) when is_number(H) ->
    sum_numbers(T, H + Acc);

sum_numbers([H|T], Acc) when not is_number(H) ->
    sum_numbers(T, Acc);

sum_numbers([], Acc) ->
    Acc.
    
mul_numbers([H|T], Prod) when is_number(H) ->
    mul_numbers(T, H * Prod);

mul_numbers([H|T], Prod) when not is_number(H) ->
    mul_numbers(T, Prod);

mul_numbers([], Prod) ->
    Prod.