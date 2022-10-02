-module(actor_creation).
-export([start/3,init/3]).

start(Node_id,Max_count_nodes,List_of_neighbours) ->
     Pid = spawn_link(?MODULE,init,[Node_id,Max_count_nodes,List_of_neighbours]),
     register(list_to_atom([Node_id]),Pid).

init(Nodes,Max_count_nodes,List_of_neighbours) ->
    io:fwrite("2D List Of Neighbours:: ~w \n",[List_of_neighbours]),
    io:fwrite("2D List Of Node:: ~p \n",[Nodes]),
    io:fwrite("2D List Of Max_Count_Nodes:: ~p \n",[Max_count_nodes]).