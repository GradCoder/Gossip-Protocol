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
                       %   Nodename = concat(integer_to_list(NodeId),"P"),
                       % register(list_to_atom(Nodename),Pushsum_Pid),
                       %register(list_to_atom(integer_to_list(NodeId)),Pushsum_Pid),
                       node_process(0,Sum+NodeId,Weight+1,NodeId,Pushsum_Pid,NodeId)
      end.

node_process(Count,Sum,Weight,Old_ratio,Pushsum_Pid,Node_id) ->
     New_ratio = Sum/Weight,
     Delta = abs(New_ratio - Old_ratio),
     Delta_threshold = math:pow(10,-10),
     if 
        Delta > Delta_threshold ->
           Updated_count = 0;
        true -> Updated_count = Count + 1
     end,
     if 
        Updated_count > 3 -> 
            io:format("Node ~p converged!!!! \n",[Node_id]),
            exit(Pushsum_Pid,normal);
        true -> 
            Update_sum = Sum/2,
            Update_weight = Weight/2,
            Pushsum_Pid ! {updaterumor,Update_sum,Update_weight},
            receive  
            {trans,Rec_sum,Rec_weight} -> 
               io:fwrite("Rumor received with Sum:~p and Weight:~p",[Rec_sum,Rec_weight]),
               New_sum = Update_sum+Rec_sum,
               New_weight = Update_weight + Rec_weight,
               node_process(Updated_count,New_sum,New_weight,New_ratio,Pushsum_Pid,Node_id)
              after
                1000 -> node_process(Updated_count,Update_sum,Update_weight,New_ratio,Pushsum_Pid,Node_id)
            end
      end.


start_pushsum(Node_id,Max_count_nodes,List_of_neighbours) ->
    {Rec_sum,Rec_weight} = receive 
                {updaterumor,Updated_sum,Updated_weight} -> {Updated_sum,Updated_weight}
            end,    
    Neighbour_Id = lists:nth(rand:uniform(length(List_of_neighbours)), List_of_neighbours),
    Id = whereis(list_to_atom([Neighbour_Id])),
    _ = try Id ! {transmittingrumour,Rec_sum,Rec_weight}  of
      _ ->  Id
    catch 
       _ErrType:_Err -> 
          start_pushsum(Node_id,Max_count_nodes,List_of_neighbours)
    end,
    start_pushsum(Node_id,Max_count_nodes,List_of_neighbours).
