-module(pushsum_exec).
-export([pushsum_2d/2,pushsum_line/2,pushsum_full/2,pushsum_imp2d/1,start_pushsum/3]).

pushsum_2d(Nodes,Max_count_nodes) when Nodes == 0 ->  start_pushsum(Max_count_nodes,50,0);

pushsum_2d(Nodes,Max_count_nodes) ->
  RowCount = round(math:sqrt(Max_count_nodes)),
  Value1 = Max_count_nodes - RowCount + 1,
  Value2 =  Nodes-1 rem RowCount,
  Value3 =  Nodes rem RowCount,
   case Nodes of
            1 -> List_of_neighbours = [Nodes+1,Nodes+RowCount];
            RowCount -> List_of_neighbours = [Nodes-1,Nodes+RowCount];
            Value1 -> List_of_neighbours = [Nodes+1,Nodes-RowCount];
            Max_count_nodes -> List_of_neighbours = [Nodes-1,Nodes-RowCount];
            _ -> 
               if Nodes < RowCount -> List_of_neighbours = [Nodes-1,Nodes+1,Nodes+RowCount];
                  (Nodes > Max_count_nodes - RowCount + 1) and (Nodes < Max_count_nodes) -> List_of_neighbours = [Nodes-1,Nodes+1,Nodes-RowCount];
                  Value2==0 -> List_of_neighbours = [Nodes+1,Nodes-RowCount,Nodes+RowCount];
                  Value3==0 -> List_of_neighbours = [Nodes-1,Nodes-RowCount,Nodes+RowCount];
                  true -> List_of_neighbours = [Nodes-1,Nodes+1,Nodes-RowCount,Nodes+RowCount]
               end 
        end,
   pushsum_actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
   pushsum_2d(Nodes-1,Max_count_nodes).

pushsum_line(Nodes,Max_count_nodes) when Nodes == 0 ->  start_pushsum(Max_count_nodes,50,0);

pushsum_line(Nodes,Max_count_nodes) ->
   case Nodes of
           1 -> List_of_neighbours = [Nodes+1];
           Max_count_nodes -> List_of_neighbours = [Nodes-1];
           _ -> List_of_neighbours = [Nodes-1,Nodes+1]
        end,
    pushsum_actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    pushsum_line(Nodes-1,Max_count_nodes).

pushsum_full(Nodes,Max_count_nodes) when Nodes == 0 ->  start_pushsum(Max_count_nodes,50,0);

pushsum_full(Nodes,Max_count_nodes) ->
    List_of_neighbours = lists:seq(1, Max_count_nodes),
    pushsum_actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    pushsum_full(Nodes-1,Max_count_nodes).


pushsum_imp2d(Nodes) ->
   io:fwrite("2D Nodes:: ~p \n",[Nodes]).

start_pushsum(_,Trigger_node_count,Nodes_started) when Nodes_started == Trigger_node_count -> exit(normal);

start_pushsum(Num_of_nodes,Trigger_node_count,Nodes_started) ->
      RandomNodeId = rand:uniform(Num_of_nodes),
      NodePid = whereis(list_to_atom([RandomNodeId])),
      NodePid ! {rumor,0,0},
      start_pushsum(Num_of_nodes,Trigger_node_count,Nodes_started+1).