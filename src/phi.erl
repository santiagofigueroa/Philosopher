%% @author Santiago 
%% @doc @todo Add description to phi.


-module(phi).

%% ====================================================================
%% API functions
%% ====================================================================
-compile([export_all]).
-author("Santiago Figueroa"). %% Dining Philosophers - Assignment 3 %%

%% ====================================================================
%% Internal functions
%% ====================================================================


%R = Report % 
%F1 to 5 Represents the number of forks on the table and there initial state%
college()-> 
R =   spawn (?MODULE, report, []),
F1 =  spawn (?MODULE, fork, [R,"On table"]),
F2 =  spawn (?MODULE, fork, [R,"On table"]),
F3 =  spawn (?MODULE, fork, [R,"On table"]),
F4 =  spawn (?MODULE, fork, [R,"On table"]),
F5 =  spawn (?MODULE, fork, [R,"On table"]),

%Spawn for philoshopers and there initial state%

spawn (?MODULE, philosophers, [aristotle,R,F1,F2,"thinking"]),
spawn (?MODULE, philosophers, [kant,R,F3,F4,"thinking"]),
spawn (?MODULE, philosophers, [spinosa,R,F2,F3,"thinking"]),
spawn (?MODULE, philosophers, [sarx,R,F4,F5,"thinking"]),
spawn (?MODULE, philosophers, [russel,R,F1,F5,"thinking"]).
%Reports the curent state a philosophers at %


report()-> 
	receive
		{msg,Name,M} ->
		io:format ("~s: is ~s.~n", [Name, M]),
		Name ! {self(), ack},
		report();
		{msg,Report, M} ->
		io:format("~w: is ~p.~n",[Report,M]),
		Report ! {self(),ack},
		report();	
		shutdown -> exit(normal)
	end.
	
%The fork functions, the first function describes the is when the fork passes
% the current state that the fork is at and the second function makes the other
% place down the fork. 
	
fork(Report, "On table") ->
	receive 
		{up,Target}	->
			Report ! {msg,"in use"},
			Target ! true ,
			fork(Report, "in use");
		{down,Target} -> 
			Target ! false
	end;
 
			
fork(Report, "in use") ->  
	receive 
		{up,Target}	->
			Target ! false;
		{down,Target} -> 
			Report ! {msg, "On table"},
			Target ! true,
			fork(Report, "On table")
	end.

% Philosophers functions. %

philosophers(Name,Report,Left,Right,"thinking") -> 
	Report ! {msg, self(), "thinking"},
	Left  ! {false,self()},
	Right ! {false,self()},
	random:seed(now()),
	sleep(random:uniform(1000)),
philosophers(Name,Report,Left,Right,"hungry");

philosophers(Name,Report,Left,Right, "hungry") -> 
	Report ! {msg,self(), "hungry"},
	Report ! {msg,self(), "got left","got right"},
philosophers(Name,Report,Left,Right,"eating");

philosophers(Name,Report,Left,Right,"got left ") -> 
	Report ! {msg,self(), "got left"},
	Report ! {msg,self(), "got left","got right"},
philosophers(Report,Name, Left,Right, "got left");

philosophers(Name,Report,Left,Right,"got right") ->
	Report ! {msg,self(), "got left"},
	Report ! {msg,self(), "got left","got right"},
philosophers(Report,Name, Left,Right,"got right");

philosophers(Name,Report,Left,Right,"eating") -> 
	Report ! {msg,self(), "eating"},
	random:seed(now()),
	Left  ! {true,self()},
	Right ! {true,self()},
	sleep(100+random:uniform(900)) ,
philosophers(Name,Report,Left,Right,"thinking").

sleep(T) ->
  receive
	after T ->
		true
	end.
	
	
%End of code%