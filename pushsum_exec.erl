-module(pushsum_exec).
-export([pushsum_2d/3,pushsum_line/3,pushsum_full/3,pushsum_imp3d/3,start_pushsum/3]).

pushsum_2d(Nodes,Max_count_nodes,Trigger_node_count) when Nodes == 0 ->  start_pushsum(Max_count_nodes,Trigger_node_count,0);

pushsum_2d(Nodes,Max_count_nodes,Trigger_node_count) ->
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
   pushsum_2d(Nodes-1,Max_count_nodes,Trigger_node_count).

pushsum_line(Nodes,Max_count_nodes,Trigger_node_count) when Nodes == 0 ->  start_pushsum(Max_count_nodes,Trigger_node_count,0);

pushsum_line(Nodes,Max_count_nodes,Trigger_node_count) ->
   case Nodes of
           1 -> List_of_neighbours = [Nodes+1];
           Max_count_nodes -> List_of_neighbours = [Nodes-1];
           _ -> List_of_neighbours = [Nodes-1,Nodes+1]
        end,
    pushsum_actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    pushsum_line(Nodes-1,Max_count_nodes,Trigger_node_count).

pushsum_full(Nodes,Max_count_nodes,Trigger_node_count) when Nodes == 0 ->  start_pushsum(Max_count_nodes,Trigger_node_count,0);

pushsum_full(Nodes,Max_count_nodes,Trigger_node_count) ->
    List_of_neighbours = lists:seq(1, Max_count_nodes),
    pushsum_actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    pushsum_full(Nodes-1,Max_count_nodes,Trigger_node_count).

pushsum_imp3d(Nodes,Max_count_nodes,Trigger_node_count) when Nodes == 0 ->  start_pushsum(Max_count_nodes,Trigger_node_count,0);

pushsum_imp3d(Nodes,Max_count_nodes,Trigger_node_count) ->
  RowCount = round(math:sqrt(Max_count_nodes)),
  Value1 = Max_count_nodes - RowCount + 1,
  Value2 =  Nodes-1 rem RowCount,
  Value3 =  Nodes rem RowCount,
   case Nodes of
            1 -> List_of_neighbours = [Nodes+1,Nodes+RowCount,Nodes+RowCount+1];
            RowCount -> List_of_neighbours = [Nodes-1,Nodes+RowCount,Nodes+RowCount-1];
            Value1 -> List_of_neighbours = [Nodes+1,Nodes-RowCount,Nodes-RowCount+1];
            Max_count_nodes -> List_of_neighbours = [Nodes-1,Nodes-RowCount,Nodes-RowCount-1];
            _ -> 
               if Nodes < RowCount -> List_of_neighbours = [Nodes-1,Nodes+1,Nodes+RowCount,Nodes+RowCount+1,Nodes+RowCount-1];
                  (Nodes > Max_count_nodes - RowCount + 1) and (Nodes < Max_count_nodes) -> List_of_neighbours = [Nodes-1,Nodes+1,Nodes-RowCount,Nodes-RowCount-1,Nodes-RowCount+1];
                  Value2==0 -> List_of_neighbours = [Nodes+1,Nodes-RowCount,Nodes+RowCount,Nodes+RowCount+1,Nodes-RowCount+1];
                  Value3==0 -> List_of_neighbours = [Nodes-1,Nodes-RowCount,Nodes+RowCount,Nodes+RowCount-1,Nodes-RowCount-1];
                  true -> List_of_neighbours = [Nodes-1,Nodes+1,Nodes-RowCount,Nodes+RowCount,Nodes+RowCount+1,Nodes+RowCount-1,Nodes-RowCount+1,Nodes-RowCount-1]
               end 
        end,  
   RandomNodeId = get_random_nodeid(Max_count_nodes,List_of_neighbours,Nodes),
   New_list_of_neighbour = List_of_neighbours ++ [RandomNodeId],
   pushsum_actor_creation:start(Nodes,Max_count_nodes,New_list_of_neighbour),
   pushsum_imp3d(Nodes-1,Max_count_nodes,Trigger_node_count).

start_pushsum(_,Trigger_node_count,Nodes_started) when Nodes_started == Trigger_node_count -> exit(normal);

start_pushsum(Num_of_nodes,Trigger_node_count,Nodes_started) ->
      RandomNodeId = rand:uniform(Num_of_nodes),
      NodePid = whereis(list_to_atom([RandomNodeId])),
      NodePid ! {rumor,0,0},
      start_pushsum(Num_of_nodes,Trigger_node_count,Nodes_started+1).


get_random_nodeid(Max_count_nodes,_,_) when Max_count_nodes == 0 -> 1;

get_random_nodeid(Max_count_nodes,List_of_neighbours,NodeId) ->
   RandomNodeId = rand:uniform(Max_count_nodes),
   Random_isnt_itself = [NodeId] =/= [RandomNodeId],
   List_contains_node = lists:member(RandomNodeId,List_of_neighbours),
   if 
      (List_contains_node == true) and (Random_isnt_itself == true) ->
       RandomNodeId;
      true -> get_random_nodeid(Max_count_nodes-1,List_of_neighbours,NodeId)
   end.
