%%%% -*- Mode: Prolog -*-
%%%% polinomimultivariati.pl --

%%	monomi
%%      m(Coefficient, TotalDegree, VarsPowers).
is_monomial(m(_C, TD, VPs)) :-
	integer(TD),  %si accerta che sia un intero
	TD >= 0,      %e maggiore di 0
	is_list(VPs).

%%	Variabili
%%	v(Power, VarSysmbol).
is_varpower(v(Power, VarSymbol)):-
	integer(Power),
	Power >= 0,
	atom(VarSymbol).

%%	Polinomi
%%	poly(Monomials).
is_polynomial(poly(Monomials)):-
	is_list(Monomials),
	foreach(member(M,  Monomials), is_monomial(M)).

%%	as_monomial(Expression, Monomial).
%	Il predicato as_monomial `e vero quando Monomial `e il termine che
%	rappresenta il monomio risultante dal “parsing” dell’espressione
%	Expression; il monomio risultante deve essere appropriatamente ordinato
as_monomial(Expression, m(Coe, Tot, Var)) :-
	as_variable(Expression, Variable),
	formalizzazione(Variable, Coe, Tot, Var).

%%	as_variable(Var ,VPs).
%%	Il predicato as_variable è vero quando Vps è il una lista di
%	termini che rappresenta delle variabili risultanti dal "parsing"
%	dell'espressione Var.
as_variable(X*Y, L) :-
	as_variable(X, R),
	!,
	as_variable(Y, E),
	append(R,E,L).

as_variable(C, [C]) :- C\= [], integer(C).
as_variable(X, [v(1,X)]):- X \= [], atom(X).
as_variable(X^Y, [v(Y,X)]):- !, Y >= 0, integer(Y), atom(X).

%%	formalizzazione(Espressione,Coefficiente,SommaGrado,VPs)
%%	il predicato formalizzazione data una una lista di variabili
%	esso è vero quando è in grado trasformare l'espressione in un
%	monomio ordinato.

formalizzazione([Coe|Resto], Coe, Tot, Variabili) :-
	integer(Coe),
	merge_sort(Resto,Variabili),
	sumdegree(Variabili,Tot).

formalizzazione(Var, 1, Tot, Variabili) :-
	merge_sort(Var,Variabili),
	sumdegree(Variabili,Tot).

formalizzazione([Coe], Coe, 0, []) :- integer(Coe).

%%	sumdegree(Variables,Sum).
%%	Il predicato sumdegree è vero quando sum è la somma dei gradi
%%	di variables

sumdegree([v(N,_)|Resto], R) :-
	sumdegree(Resto,M),!,
	R is N+M.
sumdegree([v(N,_)],N).

%%	TUTTA LA PARTE DEDICATA ALL'ORDINAMENTO DEI MONOMI.
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
	C1 < C2,
	merge(RestX,[v(M,Y)|RestY],Rest).

merge([v(N,X)|RestX],[v(M,Y)|RestY],[v(G,X)|Rest]):-
	char_code(X,C1),
	char_code(Y,C2),
	C1 = C2,
	G is N+M,
	merge(RestX,RestY,Rest).

merge([v(N,X)|RestX],[v(M,Y)|RestY],[v(M,Y)|Rest]) :-
	char_code(X,C1),
	char_code(Y,C2),
	C1 > C2,
	merge([v(N,X)|RestX],RestY,Rest).

divide(L,A,B) :- d(L,L,A,B).
d([],R,[],R).
d([_],R,[],R).
d([_,_|T],[X|L],[X|L1],R) :- d(T,L,L1,R).

%%%% end of file -- polinomimultivariati.pl --
