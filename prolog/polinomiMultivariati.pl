%%%% -*- Mode: Prolog -*-
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% polinomimultivariati.pl --

%%%% i monomi devono essere rappresentatiti cosi:

%%m(Coefficient, TotalDegree, VarsPowers).

is_monomial(m(_C, TD, VPs)) :-
	integer(TD),  %si accerta che sia un intero
	TD >= 0,      %e maggiore di 0
	is_list(VPs).


%%%% VarsPowers VPs e una lista ed deve essere rappresentata cosi:

%%v(Power, VarSymbol).

is_varpower(v(Power, VarSymbol)):-
	integer(Power),
	Power >= 0,
	atom(VarSymbol).

%%%% I polinomi devono essere rappresentati cosi:

%%poly(Monomials).

is_polynomial(poly(Monomials)):-
	is_list(Monomials),
	foreach(member(M,  Monomials), is_monomial(M)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   monomi è una lista di polinomi
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   as_monomial ()


%%	 Il predicato as_monomial `e vero quando Monomial `e il termine che
%	 rappresenta il monomio risultante dal “parsing” dell’espressione
%	 Expression; il monomio risultante deve essere appropriatamente ordinato

%?- as_monomial(3 * y * w * tˆ3, M). M = m(3, 5, [v(3, t), v(1, w), v(1, y)]).
%?- as_monomial(y * sˆ3 * tˆ3, M). M = m(1, 7, [v(3, s), v(3, t), v(1, y)]).

%as_monomial(Expression, Monomial).

constant(X) :- atomic(X). %% bisogna definere cos'è una costante (può essere sia integer sia double che float)

% is_Var questo metodo deve prendere una stringa di variabili ordinarle
% metterle in un lista di variabili is_VarPower e restituire la somma
% delle dei gradi delle variabli.
%%v(Power, VarSymbol).
is_varpower(v(Power, VarSymbol)):-
	integer(Power),
	Power >= 0,
	atom(VarSymbol).


%%	RICORDARE LE CONDIZIONE DI VARPOWERV!!!!!!!!

is_Var(X*Y, [E|R]) :- is_Var(X,R),!,is_Var(Y,[E]).
is_Var(X^Y, [v(Y,X)]):- !,Y>=0,integer(Y),atom(X).
is_Var(X, [v(1,X)]):- atom(X).

%Ȁ12 ?- is_Var(x^2*y^2*u^3*i^4*z^5,M).
%M = [v(5, z), v(4, i), v(3, u), v(2, y), v(2, x)].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%TUTTA LA PARTE DEDICATA ALL'ORDINAMENTO DEI MONOMI.
merge_sort([v(N,X)],[v(N,X)]).
merge_sort(Lista,Sorted):-
	Lista = [_,_|_],
	divide(Lista,L1,L2),
	merge_sort(L1,Sorted1),
	merge_sort(L2,Sorted2),
	merge(Sorted1,Sorted2,Sorted).

merge([],L,L).
merge(L,[],L) :- L \= [].

merge([v(N,X)|RestX],[v(M,Y)|RestY],[v(N,X)|Rest]) :-
	char_code(X,C1),
	char_code(Y,C2),
	C1 =< C2,
	merge(RestX,[v(M,Y)|RestY],Rest).

merge([v(N,X)|RestX],[v(M,Y)|RestY],[v(M,Y)|Rest]) :-
	char_code(X,C1),
	char_code(Y,C2),
	C1 > C2,
	merge([v(N,X)|RestX],RestY,Rest).

divide(L,A,B) :- d(L,L,A,B).
d([],R,[],R).
d([_],R,[],R).
d([_,_|T],[X|L],[X|L1],R) :- d(T,L,L1,R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%monomi monovariati

%is_monomial(X, X).
%is_monomial(C, X) :- C \= X, constant(C).
%is_monomial(X^N, X) :- integer(N), N >= 0.
%is_monomial(X^N, X) :- atom(N).
%is_monomial(C * X, X) :- constant(C).
%is_monomial(C * X^N, X) :- constant(C), is_monomial(X^N, X).


%%%%funziona%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% is_var funziona accertarsi che ^ deve essere per forza un numero
%%%% intero o anche un altro polinomio.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%	Il predicato coefficients `e vero quando Coefficients `e una lista dei
%	coefficienti di Poly.

coefficients(Poly, Coefficients) :-
	is_polynomial(poly(Poly)).


%%	Il predicato variables `e vero quando Variables `e una lista dei simboli
%	di variabile che appaiono in Poly.

variables(Poly, Variables).


%%	 Il predicato monomials `e vero quando Monomials `e la lista – ordinata, si
%	 veda sotto – dei monomi che appaiono in Poly.

monomials(Poly ,Monomials).


%%	 Il predicato maxdegree `e vero quando Degree `e il massimo grado dei
%	 monomi che appaiono in Poly.

maxdegree(Poly, Degree).


%%	 Il predicato mindegree `e vero quando Degree `e il minimo grado dei monomi
%	 che appaiono in Poly.

mindegree(Poly, Degree).


%%	 Il predicato polyplus `e vero quando Result `e il polinomio somma di Poly1
%	 e Poly2

polyplus(Poly1, Poly2, Result).


%%	 Il predicato polyminus `e vero quando Result `e il polinomio differenza di
%	 Poly1 e Poly2

polyminus(Poly1, Poly2, Result).


%%	 Il predicato polytimes `e vero quando Result `e il polinomio risultante
%	 dalla moltiplicazione di Poly1 e Poly2.

polytimes(Poly1, Poly2, Result).





%%	Il predicato as polynomial `e vero quando Polynomial `e il termine che
%	 rappresenta il polinomio risultante dal “parsing” dell’espressione
%	 Expression; il polinomio risultante deve essere appropriatamente ordinato

as_polynomial(Expression, Polynomial).


%%	 Il predicato polyval `e vero quanto Value contiene il valore del polinomio
%	 Polynomial (che pu`o anche essere un monomio), nel punto n-dimensionale
%	 rappresentato dalla lista VariableValues, che contiene un valore per ogni
%	 variabile ottenuta con il predicato variables/2.

polyval(Polynomial, VariableValues, Values).


%%	 Il predicato pprint polynomial risulta vedo dopo aver stampato (sullo
%	 “standard output”) una rappresentazione tradizionale del termine polinomio
%	 associato a Polynomial. Si pu´o omettere il simbolo di moltiplicazione.

pprint_polynomial(Polynomial).


%%%% end of file -- polinomimultivariati.pl --
