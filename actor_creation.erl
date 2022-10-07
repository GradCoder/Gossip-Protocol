-module(actor_creation).
-export([start/3,init/3,start_gossiping/4]).

start(Node_id,Max_count_nodes,List_of_neighbours) ->
     Pid = spawn_link(?MODULE,init,[Node_id,Max_count_nodes,List_of_neighbours]),
     register(list_to_atom([Node_id]),Pid).

init(NodeId,Max_count_nodes,List_of_neighbours) ->
      receive 
          {rumor,Rumor} -> Gossip_Pid = spawn(?MODULE,start_gossiping,[NodeId,Max_count_nodes,List_of_neighbours,Rumor]),
                       io:format("Node name ~p and process ~p",[NodeId,Gossip_Pid]),
                       node_pr(1,Rumor,Gossip_Pid,NodeId)
      end.

node_pr(Count,_,Gossip_Pid,Node_id) when Count == 11 -> 
     io:format("Node - ~p is terminated!!!!! \n", [Node_id]),
     exit(Gossip_Pid,normal);

node_pr(Count,Rumor,Gossip_Pid,Node_id) ->
     receive  
          {transmittingrumour,Rumor} -> 
               io:format("Rumor Count is ~p in Pid: ~p \n",[Count,Node_id]),
               node_pr(Count+1,Rumor,Gossip_Pid,Node_id)
     end.


%   io:format("~p ~p ~p",[Count,Rumor,Gossip_Pid]).

start_gossiping(Node_id,Max_count_nodes,List_of_neighbours,Rumor) -> 
     %Index = rand:uniform(Max_count_nodes),
     %Neighbour_Id =  lists:nth(Index,List_of_neighbours),
     Neighbour_Id = lists:nth(rand:uniform(length(List_of_neighbours)), List_of_neighbours),
     %io:format(" adding words ~p ~p \n",[Neighbour_Id,Neighbour_Id]),
     NodePid = whereis(list_to_atom([Neighbour_Id])),
     NodePid ! {transmittingrumour,Rumor},
     start_gossiping(Node_id-1,Max_count_nodes,List_of_neighbours,Rumor).
