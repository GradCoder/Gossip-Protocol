-module(pushsum_actor_creation).
-import(string,[concat/2]).
-export([start/3,init/3,start_pushsum/3]).

start(Node_id,Max_count_nodes,List_of_neighbours) ->
     Pid = spawn_link(?MODULE,init,[Node_id,Max_count_nodes,List_of_neighbours]),
     register(list_to_atom([Node_id]),Pid).

init(NodeId,Max_count_nodes,List_of_neighbours) ->
      receive 
          {rumor,Sum,Weight} ->   
                       Pushsum_Pid = spawn(?MODULE,start_pushsum,[NodeId,Max_count_nodes,List_of_neighbours]),
                       Nodename = concat(integer_to_list(NodeId),"P"),
                       register(list_to_atom(Nodename),Pushsum_Pid),
                       %io:format("Node name ~p and process ~p",[NodeId,Pushsum_Pid]),
                       node_process(0,Sum+NodeId,Weight+1,NodeId,Pushsum_Pid,NodeId)
      end.

% node_process(Count,_,_,_,Gossip_Pid,Node_id) when Count == 11 -> 
%      io:format("Node - ~p is terminated!!!!! \n", [Node_id]),
%      exit(Gossip_Pid,normal);

node_process(Count,Sum,Weight,Old_ratio,Pushsum_Pid,Node_id) ->
     io:format("S: ~p W: ~p R:~p ----- ~p \n",[Sum,Weight,Old_ratio,Node_id]),
     New_ratio = Sum/Weight,
     Delta = abs(New_ratio - Old_ratio),
     Delta_threshold = math:pow(10,-10),
     if 
        Delta > Delta_threshold ->
           Updated_count = 0;
        true -> Updated_count = Count + 1
     end,
   %   if 
   %      Updated_count > 3 -> 
   %          io:format("Node ~p converged!!!!",[Node_id]),
   %          exit(Pushsum_Pid,normal),
   %          exit(Node_id,normal);
   %      true -> 
            Update_sum = Sum/2,
            Update_weight = Weight/2,
            Pushsum_Pid ! {updaterumor,Update_sum,Update_weight,self()},
            Id =   whereis(list_to_atom([Node_id])),
            io:format("~p Sending rumour to ~p with Process Id : ~p && ~p \n",[Node_id,Pushsum_Pid,self(),Id]),
            receive  
            {trans,Sum,Weight} -> 
               New_sum = Update_sum+Sum,
               New_weight = Update_weight + Weight,
               io:format("Rumor Count is ~p in Pid: ~p \n",[Count,Node_id]),
               node_process(Updated_count,New_sum,New_weight,New_ratio,Pushsum_Pid,Node_id)
              after
                10000 -> node_process(Updated_count,Update_sum,Update_weight,New_ratio,Pushsum_Pid,Node_id)
            end.
   %   end.


start_pushsum(Node_id,Max_count_nodes,List_of_neighbours) ->
    {Rec_sum,Rec_weight} = receive 
                {updaterumor,Updated_sum,Updated_weight,SendersProcessId} -> io:format("I :~p Received rumour from ~p \n",[self(),SendersProcessId]),
                                                            {Updated_sum,Updated_weight}
            end,    
    Neighbour_Id = lists:nth(rand:uniform(length(List_of_neighbours)), List_of_neighbours),
    Id = whereis(list_to_atom([Neighbour_Id])),
    % _ = try Id ! {transmittingrumour,Rec_sum,Rec_weight}  of
    %     _ ->  Id
    % catch 
    %     _ErrType:_Err -> errormessage
    % end,
   %  Nodename = concat(integer_to_list(Neighbour_Id),"P"),
   %  Id =   whereis(list_to_atom(Nodename)),
    io:format("transmitting to ~p by Node Id: ~p with Process Id : ~p \n",[Id,Node_id,self()]), 
    Id ! {trans,Rec_sum,Rec_weight},
    start_pushsum(Node_id,Max_count_nodes,List_of_neighbours).
