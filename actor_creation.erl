-module(actor_creation).
-export([start/3,init/3,start_gossiping/3]).

start(Node_id,Max_count_nodes,List_of_neighbours) ->
     Pid = spawn_link(?MODULE,init,[Node_id,Max_count_nodes,List_of_neighbours]),
     register(list_to_atom([Node_id]),Pid).

init(NodeId,Max_count_nodes,List_of_neighbours) ->
      receive 
          {rumor,Rumor} -> Gossip_Pid = spawn(?MODULE,start_gossiping,[Max_count_nodes,List_of_neighbours,Rumor]),
                       node_process(1,Rumor,Gossip_Pid,NodeId)
      end.

node_process(Count,_,Gossip_Pid,Node_id) when Count == 11 -> 
     io:format("Node - ~p is converged!!!!! \n", [Node_id]),
     {EndTime,_} = statistics(wall_clock),
     io:format("Time  ~w \n", [EndTime]),
     exit(Gossip_Pid,normal);

node_process(Count,Rumor,Gossip_Pid,Node_id) ->
     receive  
          {transmittingrumour,Rumor} -> 
               node_process(Count+1,Rumor,Gossip_Pid,Node_id)
     end.

start_gossiping(Max_count_nodes,List_of_neighbours,Rumor) -> 
    Neighbour_Id = lists:nth(rand:uniform(length(List_of_neighbours)), List_of_neighbours),
    Id = whereis(list_to_atom([Neighbour_Id])),
     _ = try Id ! {transmittingrumour,Rumor}  of
           _ ->  Id
     catch 
          _ErrType:_Err -> start_gossiping(Max_count_nodes,List_of_neighbours,Rumor),
               errormessage
     end,
     start_gossiping(Max_count_nodes,List_of_neighbours,Rumor).
