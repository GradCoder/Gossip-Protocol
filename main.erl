-module(main).
-import(string,[replace/4,str/2]).
-import(math,[pow/2,sqrt/1]).
-export([start/0]).

start() ->
    [NumOfNodes,_,_] = string:replace(io:get_line("Enter number of nodes"),"\n","",all),
    [Topology,_,_] = string:replace(io:get_line("Enter the topology..."),"\n","",all),
    [Algorithm,_,_] = string:replace(io:get_line("Enter the algorithm..(Gossip/PushSum)"),"\n","",all),
    Strfound = (string:str(Topology,"2D")),
    Nodes = if(Strfound>0) -> round(math:pow(round(math:sqrt(list_to_integer(NumOfNodes))),2)); true -> list_to_integer(NumOfNodes) end,
    case Topology of
        "2D" -> if Algorithm=="Gossip" -> gossip_exec:gossip_2d(Nodes,Nodes); true -> pushsum_exec:pushsum_2d(Nodes,Nodes) end;
        "FULL" -> if Algorithm=="Gossip"-> gossip_exec:gossip_full(Nodes,Nodes); true -> pushsum_exec:pushsum_full(Nodes,Nodes) end;
        "IMP2D" -> if Algorithm=="Gossip"-> gossip_exec:gossip_imp2d(Nodes); true -> pushsum_exec:pushsum_imp2d(Nodes,Nodes) end;
        "LINE" -> if Algorithm=="Gossip"-> gossip_exec:gossip_line(Nodes,Nodes); true -> pushsum_exec:pushsum_line(Nodes,Nodes) end
    end.

   