-module(pushsum_exec).
-export([pushsum_2d/1,pushsum_line/2,pushsum_full/1,pushsum_imp2d/1,start_pushsum/3]).

pushsum_2d(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

pushsum_line(Nodes,Max_count_nodes) when Nodes == 0 ->  start_pushsum(Max_count_nodes,100,0);

pushsum_line(Nodes,Max_count_nodes) ->
   case Nodes of
           1 -> List_of_neighbours = [Nodes+1];
           Max_count_nodes -> List_of_neighbours = [Nodes-1];
           _ -> List_of_neighbours = [Nodes-1,Nodes+1]
        end,
    pushsum_actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    pushsum_line(Nodes-1,Max_count_nodes).

pushsum_full(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

pushsum_imp2d(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

start_pushsum(_,Trigger_node_count,Nodes_started) when Nodes_started == Trigger_node_count -> exit(normal);

start_pushsum(Num_of_nodes,Trigger_node_count,Nodes_started) ->
      RandomNodeId = rand:uniform(Num_of_nodes),
      NodePid = whereis(list_to_atom([RandomNodeId])),
      NodePid ! {rumor,0,0},
      start_pushsum(Num_of_nodes,Trigger_node_count,Nodes_started+1).