-module(gossip_exec).
-export([gossip_2d/1,gossip_full/1,gossip_line/2,gossip_imp2d/1,pushsum_2d/1,pushsum_line/1,pushsum_full/1,pushsum_imp2d/1]).

gossip_2d(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).
 
gossip_line(Nodes,_) when Nodes == -1 -> ok;

gossip_line(Nodes,Max_count_nodes) ->
        case Nodes of
           0 -> List_of_neighbours = [Nodes+1];
           Max_count_nodes -> List_of_neighbours = [Nodes-1];
           _ -> List_of_neighbours = [Nodes-1,Nodes+1]
        end,
    actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    gossip_line(Nodes-1,Max_count_nodes).

gossip_full(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

gossip_imp2d(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

pushsum_2d(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

pushsum_line(Nodes) ->
   io:fwrite("2D Nodes:: ~p \sn",[Nodes]).

pushsum_full(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

pushsum_imp2d(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).