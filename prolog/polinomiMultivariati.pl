%%%% -*- Mode: Prolog -*-
%%%% polinomimultivariati.pl --

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% coefficients
% Todo: informarsi cosa fare con i doppioni.
coefficients(poly(Monomi), Coefficients) :-
	find_coefficients(Monomi,Coefficients).

find_coefficients([m(C ,_ ,_)|Resto],[C|R]):-
	find_coefficients(Resto,R).

find_coefficients([],[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% variables
% TODO: bisogna gestire il caso in cui ci sono simboli duplicati.
% TODO: bisogna capise se il polinomio � gia ordinato.
variables(poly(Monomi), Variables):-
	find_monomi(Monomi,Variables).

find_monomi([],[]).
find_monomi([m(_, _, Var)| Resto], Soluzione):-
	find_variables(Var,Variables),
	find_monomi(Resto, Ricorsione),
	append(Variables, Ricorsione, Soluzione).

find_variables([],[]).
find_variables([v(_,Symbol)|Resto],[Symbol|Ricorsione]):-
	find_variables(Resto,Ricorsione).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%monomials(Poly, Monomials)
% TODO: risolvere il problema dell'ordinamento qui molto probabilmente
% ci dar� un monomio non ordinato.
monomials(poly(Monomials), Monomials).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% maxdegree(Poly, Degree)
maxdegree(poly(Monomi), Soluzione):-
	find_degree(Monomi, Degrees),
	max_list(Degrees, Soluzione)  .

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%mindegree(Poly, Degree).
mindegree(poly(Monomi), Soluzione):-
	find_degree(Monomi, Degrees),
	min_list(Degrees, Soluzione).

find_degree([],[]).
find_degree([m(_, Degree, _)| Resto], [Degree|Ric]):-
	find_degree(Resto, Ric).

%Questa parte deve essere guardata molto bene fino a scalare
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%polyplus(Poly1, Poly2, Result)
%TODO: fare l'ordinamento
%TODO: Manca testare
polyplus(Poly1, Poly2, poly(Soluzione)) :-
	Poly1 = poly(Monomi1),
	Poly2 = poly(Monomi2),
	append(Monomi1, Monomi2, Soluzione).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%polyminus
%TODO: Manca testare
polyminus(Poly1, Poly2, poly(Soluzione)):-
	polytimes(poly(m(-1,0,[])), Poly2, Poly2PerMinusOne),
	polyplus(Poly1, Poly2PerMinusOne, poly(Soluzione)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%polytimes(Poly1, Poly2, Result)
%TODO: ritorna un polinomio bisogna ordinarlo.
%TODO: manca Testare
%TODO: bisogna controllare il caso in cui ho un coefficiente in mezzo
% al monomio e quando ho e quando ho un "as_coeffiecent" all interno di
% un altro coefficiente
polytimes(poly([]), _ ,poly([])).

polytimes(poly([M|Resto]), poly(Monomi2), poly(Soluzione)) :-
	scalare(M, Monomi2, Primo),
	polytimes(poly(Resto) ,poly(Monomi2), poly(SoluzioneRic)),
	append(Primo ,SoluzioneRic, Soluzione).

scalare(m(_, _, _), [] , []).
scalare(m(C1, TD1, Var1), [m(C2, TD2, Var2)|Resto], [m(C, TD, Var)|Ric]) :-
	C is C1 * C2,
	TD is TD1 + TD2,
	append(Var1,  Var2, Var),
	scalare(m(C1, TD1, Var1), Resto, Ric).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%as_monomial(Expression, Monomial).
%TODO: Manca l'ordinamento
%TODO: Manca testare
as_monomial(Expression, m(C, TD, Sorted)) :-
	as_variable(Expression, Variables),
	find_coefficient(Variables , Coe, NoCoeff),
	C is round(Coe * 1000) / 1000,
	sumdegree(NoCoeff, TD),
	sort_monomio(NoCoeff, Sorted).

%tipi di coefficienti
as_coefficient([],[]).
as_coefficient(C, [C]) :- number(C),!.
as_coefficient(+C, [R]) :- is_number(C, [C1]), R is C1, !.
as_coefficient(-C, [R]) :- is_number(C, [C1]), R is C1 * -1,!.
as_coefficient(C/D, [R]) :- is_number(C, [C1]), is_number(D, [D1]),  R is C1 rdiv D1, !.
as_coefficient(sqrt(C), [R]) :- is_number(C, [C1]),R is sqrt(C1),!.
as_coefficient(sin(C), [R]) :- is_number(C, [C1]),R is sin(C1),!.
as_coefficient(sen(C), [R]) :- is_number(C, [C1]),R is sin(C1),!.
as_coefficient(cos(C), [R]) :- is_number(C, [C1]),R is cos(C1),!.
as_coefficient(tan(C), [R]) :- is_number(C, [C1]),R is tan(C1),!.
as_coefficient(asin(C), [R]) :- is_number(C, [C1]), R is asin(C1),!.
as_coefficient(acos(C), [R]) :- is_number(C, [C1]), R is acos(C1),!.
as_coefficient(atan(C), [R]) :- is_number(C, [C1]), R is atan(C1),!.
as_coefficient(sinh(C), [R]) :- is_number(C, [C1]), R is sinh(C1),!.
as_coefficient(cosh(C), [R]) :- is_number(C, [C1]), R is cosh(C1),!.
as_coefficient(tanh(C), [R]) :- is_number(C, [C1]), R is tanh(C1),!.
as_coefficient(asinh(C), [R]) :- is_number(C, [C1]), R is asinh(C1),!.
as_coefficient(acosh(C), [R]) :- is_number(C, [C1]), R is acosh(C1),!.
as_coefficient(atanh(C), [R]) :- is_number(C, [C1]), R is atanh(C1),!.
as_coefficient(log(C), [R]) :- is_number(C, [C1]), R is log(C1),!.
as_coefficient(log10(C), [R]) :- is_number(C, [C1]),R is log10(C1), !.
as_coefficient(exp(C), [R]) :- is_number(C, [C1]), R is exp(C1), !.
as_coefficient(pi, [R]) :- R is pi, !.
as_coefficient(C^E, [R]) :- is_number(C, [C1]),is_number(E, [E1]), R is C1^E1,!.

% qui c'� un problemma questo predicato dovrebbe avere arieta 2 in caso
% non sia un numero ritorna il numero in modo ricorsivo.
is_number(C, [C]) :- number(C).
is_number(C, R) :- as_coefficient(C,R).

%Variables

as_variable(X*Y, L) :-
	as_variable(X, R),
	!,
	as_variable(Y, E),
	append(R,E,L).

as_variable(X, [v(1,X)]):- atom(X), X \=  pi.
as_variable(X^0,[]) :- atom(X), X \=  pi.
as_variable(+X, [v(1,X)]):- atom(X), X \=  pi.
as_variable(+X^0,[]) :- atom(X), X \=  pi.


as_variable(X^Y, [v(Y,X)]):-
	Y >= 0,
	integer(Y),
	X \=  pi,
	atom(X),!.

as_variable(C, R) :- as_coefficient(C, R).

%Coefficiente trova un coefficiente
find_coefficient([], 1, []).
find_coefficient([C|Rest], S, Var) :-
	coefficient(C),!,
	find_coefficient(Rest, R, Var),
	S is C*R.
find_coefficient([C|Rest], R, [C|Vars]) :-
	find_coefficient(Rest, R, Vars).

coefficient(C) :- number(C).

%somma dei gradi
sumdegree([], 0).
sumdegree([v(N,_)|Resto], R) :-
	sumdegree(Resto,M),!,
	R is N+M.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%as polynomial
%TODO: Manca L'ordinamento
%TODO: Manca testare
as_polynomial(Expression, poly(Sorted)) :-
	find_monomials(Expression, Monomi),
	sort_polinomio(Monomi, Risultato),
	sort(2, @=< , Risultato, Sorted),!.

%find_monomial
find_monomials(Ex2+Ex1, Monomi) :-
	!,as_monomial(Ex1, Mo1),
	find_monomials(Ex2, Mo2),
	append(Mo2, [Mo1], Monomi).

find_monomials(Ex2-Ex1, Monomi) :-
	!,as_monomial(Ex1, Mo1),
	Mo1 = m(C,P,L),
	Cneg is C * -1,
	find_monomials(Ex2, Mo2),
	append(Mo2, [m(Cneg,P,L)], Monomi).

find_monomials(Exp,[Monomio]) :- as_monomial(Exp,Monomio).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%polyval(Polynomial, VariableValues, Value)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%pprint_polynomial(Polynomial).

% TODO: ATTENZIONE NELLA CONSEGNA QUESTO PREDICATO DEVE ESSERE UNARIO
% PER FARE CIO BASTER� CANCELLARE EXPRESSION
pprint_polynomial(poly(Monomial), Expression):-
	print_monomial(Monomial, ListChars),
	atomics_to_string(ListChars, Expression),
	write(Expression).

print_monomial([],[]).
print_monomial([m(C, _, Variables)|Rest], Result):-
	C >= 0,!,
	print_variables(Variables, Var),
	print_monomial(Rest, Monomial),
	append([+,C], Var , Vars),
	append(Vars, Monomial, Result).

print_monomial([m(C, _, Variables)|Rest], Result):-
	C < 0,!,
	print_variables(Variables, Var),
	print_monomial(Rest, Monomial),
	append([C], Var , Vars),
	append(Vars, Monomial, Result).

print_variables([],[]).
print_variables([v(1, Symbol)|Rest], [*,Symbol| R]) :-
	print_variables(Rest, R), !.
print_variables([v(TD, Symbol)|Rest], [*,Symbol,^,TD|R]) :-
	print_variables(Rest,R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ordinamento dei monomi.

sort_monomio([],[]).
sort_monomio([X],[X]).
sort_monomio(List,Sorted):-
	List=[_,_|_],
	divide(List,L1,L2),
	sort_monomio(L1,Sorted1),
	sort_monomio(L2,Sorted2),
	monomio_cmp(Sorted1,Sorted2,Sorted),!.

%regole per il confronto
monomio_cmp([], Var, Var).
monomio_cmp(Var, [], Var) :- Var \=  [].
monomio_cmp([v(G1,S1)|T1],[v(G2,S2)|T2],[v(G1,S1)|Tail]) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 < C2,
	monomio_cmp(T1,[v(G2,S2)|T2],Tail).
monomio_cmp([v(G1,S1)|T1],[v(G2,S2)|T2],[v(G2,S2)|Tail]) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 > C2,
	monomio_cmp([v(G1,S1)|T1],T2,Tail).
monomio_cmp([v(G1,S1)|T1],[v(G2,S2)|T2],[v(Sum,S2)|Tail]):-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 = C2,
	Sum is G1 + G2,
	monomio_cmp(T1,T2,Tail).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Ordinamento polinomi
sort_polinomio([],[]).
sort_polinomio([X],[X]).
sort_polinomio(List,Sorted):-
	List=[_,_|_],
	divide(List,L1,L2),
	sort_polinomio(L1,Sorted1),
	sort_polinomio(L2,Sorted2),
	ord_polinomio(Sorted1,Sorted2,Sorted).

ord_polinomio([],L,L).
ord_polinomio(L,[],L):- L \= [].
ord_polinomio([M1|T1],[M2|T2],[M1|Tail]):-
	polinomio_cmp(M1, M2, -1),
	ord_polinomio(T1,[M2|T2],Tail).

ord_polinomio([M1|T1],[M2|T2],[M2|T]):-
	polinomio_cmp(M1, M2, 1),
	ord_polinomio([M1|T1],T2,T).

ord_polinomio([m(C1,TD,Var)|T1],[m(C2,TD,Var)|T2],[m(Sum,TD,Var)|Tail]):-
	Sum is C1 + C2,
	ord_polinomio(T1,T2,Tail).

ord_polinomio([M1|T1],[M2|T2],[M1,M2|Tail]):-
	polinomio_cmp(M1,M2,0),
	ord_polinomio(T1,T2,Tail).

%Regole da usare per il compare
polinomio_cmp(m(_,_,[v(G,S)|T1]), m(_,_,[v(G,S)|T2]), Tail) :-
	polinomio_cmp(m(_,_,T1), m(_,_,T2), Tail).
polinomio_cmp(m(_,_,[]),m(_,_,[]),0).


polinomio_cmp(m(_,_,[v(_,S1)|_]), m(_,_,[v(_,S2)|_]), -1) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 < C2.
polinomio_cmp(m(_,_,[v(G1,S)|_]), m(_,_,[v(G2,S)|_]), -1) :-
	G1 < G2.
polinomio_cmp(m(_,_,[]),m(_,_,M),-1):- M \= [].


polinomio_cmp(m(_,_,[v(_,S1)|_]), m(_,_,[v(_,S2)|_]), 1) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 > C2.
polinomio_cmp(m(_,_,[v(G1,S)|_]), m(_,_,[v(G2,S)|_]), 1) :-
	G1 > G2.
polinomio_cmp(m(_,_,M),m(_,_,[]),1):- M \= [].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%predicato divide una a meta
divide(L,A,B) :- d(L,L,A,B).
d([],R,[],R).
d([_],R,[],R).
d([_,_|T],[X|L],[X|L1],R) :- d(T,L,L1,R).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% End of file -- polinomimultivariati.pl --
