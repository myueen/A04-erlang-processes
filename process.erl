%team("edlyn jeyaraj, yueen ma, thomas kung")

-module(p1).
-export([serv1/0, start/0, serv2/1, sum_numbers/2, mul_numbers/2]).

serv1() -> receive
    {add, X, Y} ->
        io:format("Math handling: ~p + ~p = ~p~n", [X,Y,X+Y]),
        serv1();
    {sub, X, Y} ->
        io:format("Math handling: ~p - ~p = ~p~n", [X,Y,X-Y]),
        serv1();
    {mult, X, Y} ->
        io:format("Math handling: ~p * ~p = ~p~n", [X,Y,X*Y]),
        serv1();
    {div, X, Y} ->
        io:format("Math handling: ~p / ~p = ~p~n", [X,Y,X/Y]),
        serv1();
    {neg, X} ->
        io:format("Math handling: -~p = ~p~n", [X,-1*X]),
        serv1();
    {sqrt, X} ->
        io:format("Math handling: sqrt(~p) = ~p~n", [X,math:pow(X,1/2)]),
        serv1()
    end.

start() ->
    Pid1 = spawn(?MODULE, serv1, []),
    {ok, Message} = io:read("Enter a message: "),
    Pid1 ! Message,
    okay.

% loop() ->
%     end.


serv2(P) -> 
    receive
        [Head | Tail] when is_integer(Head) -> 
            summation = sum_numbers([Head|Tail], 0),
            io:format(">>summation of all numbers ~p~n", [summation]);
        [Head | Tail] when is_float(Head) ->
            product = mul_numbers([Head|Tail], 1),
            io:format(">>products of all numbers ~p~n", [product])
    end.



serv3(Count) ->
    receive
        {error, X} ->
            io:format("Error: ~p", [X]),
            serv3(Count);

        halt->
            io:format("(serv3) Receivedd ~p unprocessed messages.~n", [Count]),
            io:format("(serv3) Halting.~n");

        Message->
        io:format("(serv3) Not handledd: ~p~n", [Message]),
        serv3(Count+1)
    end.







sum_numbers([H|T], acc) when is_number(H) ->
    sum_numbers(T, H + acc);

sum_numbers([], acc) ->
    acc.
    
mul_numbers([H|T], prod) when is_number(H) ->
    mul_numbers(T, H * prod);

mul_numbers([], prod) ->
    prod.