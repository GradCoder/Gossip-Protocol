-module(gossip_exec).
-export([gossip_2d/3,gossip_full/3,gossip_line/3,gossip_imp3d/3,get_random_nodeid/3]).


gossip_2d(Nodes,Max_count_nodes,Trigger_node_count) when Nodes==0 -> start_gossip(Max_count_nodes,Trigger_node_count,0);

gossip_2d(Nodes,Max_count_nodes,Trigger_node_count) ->
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
   actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
   gossip_2d(Nodes-1,Max_count_nodes,Trigger_node_count).
 
gossip_line(Nodes,Max_count_nodes,Trigger_node_count) when Nodes == 0 ->  start_gossip(Max_count_nodes,Trigger_node_count,0);

gossip_line(Nodes,Max_count_nodes,Trigger_node_count) ->
        case Nodes of
           1 -> List_of_neighbours = [Nodes+1];
           Max_count_nodes -> List_of_neighbours = [Nodes-1];
           _ -> List_of_neighbours = [Nodes-1,Nodes+1]
        end,
    actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    gossip_line(Nodes-1,Max_count_nodes,Trigger_node_count).

gossip_full (Nodes,Max_count_nodes,Trigger_node_count) when Nodes == 0 ->  start_gossip(Max_count_nodes,Trigger_node_count,0);

gossip_full(Nodes,Max_count_nodes,Trigger_node_count) ->
    List_of_neighbours = lists:seq(1, Max_count_nodes),
    actor_creation:start(Nodes,Max_count_nodes,List_of_neighbours),
    gossip_full(Nodes-1,Max_count_nodes,Trigger_node_count).

gossip_imp3d(Nodes,Max_count_nodes,Trigger_node_count) when Nodes == 0 ->  start_gossip(Max_count_nodes,Trigger_node_count,0);

gossip_imp3d(Nodes,Max_count_nodes,Trigger_node_count) ->
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
   actor_creation:start(Nodes,Max_count_nodes,New_list_of_neighbour),
   gossip_imp3d(Nodes-1,Max_count_nodes,Trigger_node_count).

start_gossip(_,Trigger_node_count,Nodes_started) when Nodes_started == Trigger_node_count -> exit(normal);

start_gossip(Num_of_nodes,Trigger_node_count,Nodes_started) ->
      RandomNodeId = rand:uniform(Num_of_nodes),
      NodePid = whereis(list_to_atom([RandomNodeId])),
      NodePid ! {rumor,"Rumor"},
      start_gossip(Num_of_nodes,Trigger_node_count,Nodes_started+1).

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
