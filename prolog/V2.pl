%% %%%% -*- Mode: Prolog -*-
%% %%%% V2.pl

%coefficient
coefficient(poly(Monomials), Coefficients) :-
	find_coefficients(Monomials, Coefficients), !.

coefficient(Expression, Coefficients) :-
	as_polynomial(Expression, Polynomial),
	coefficient(Polynomial, Coefficients).

find_coefficients([], []).
find_coefficients([m(C, _, _)| Rest], [C| Tail]) :-
	find_coefficients(Rest, Tail).

						%variables
variables(poly(Monomials), Variables) :-
	find_monomials(Monomials, Variables),!.

variables(Expression, Variables) :-
	as_polynomial(Expression, Polynomial),
	variables(Polynomial, Variables).

find_monomials([], []).
find_monomials([m(_, _, Var)| Rest], Monomials) :-
	find_variables(Var, Variables),
	find_monomials(Rest, RestMon),
	append(Variables, RestMon, Monomials).

find_variables([], []).
find_variables([v(_, Symbol)| Rest], [Symbol| RestSym]) :-
	find_variables(Rest, RestSym).
						%
						% TODO: FARE DUPLICATES che rimuove i duplicate all'interno di una lista
						%
						%monomials
monomials(poly(Monomials), Monomials).

monomials(Expression, MonomialsList) :-
	as_polynomial(Expression, poly(MonomialsList)).

						%maxdegree
maxdegree(poly(Monomials), MaxDegree) :-
	degreeList(Monomials, Degrees),
	max_list(Degrees, MaxDegree), !.

maxdegree(Expression, Maxdegree) :-
	as_polynomial(Expression, Polynomial),
	maxdegree(Polynomial, Maxdegree).

						%mindegree
mindegree(poly(Monomials), Mindegree) :-
	degreeList(Monomials, Degrees),
	min_list(Degrees, Mindegree), !.

mindegree(Expression, Mindegree) :-
	as_polynomial(Expression, Polynomial),
	mindegree(Polynomial, Mindegree).

degreeList([], []).
degreeList([m(_, Degree, _)| Rest], [Degree| Rec]) :-
	degreeList(Rest, Rec).

						%polyplus
polyplus(poly(Monomials1), poly(Monomials2), poly(List)) :-
	append(Monomials1, Monomials2, List),
	!.

polyplus(Expression1, Expression2, Sum) :-
	as_polynomial(Expression1, Polynomial1),
	as_polynomial(Expression2, Polynomial2),
	polyplus(Polynomial1, Polynomial2, Sum).

						%polyminus
polyminus(Polynomial1, Polynomial2, Minimum) :-
	polytimes(poly(m(-1, 0, [])), Polynomial2, Poly2PerMinusOne),
	polyplus(Polynomial1, Poly2PerMinusOne, Minimum), !.

polyminus(Expression1, Expression2, Minus) :-
	as_polynomial(Expression1, Polynomial1),
	as_polynomial(Expression2, Polynomial2),
	polyminus(Polynomial1, Polynomial2, Minus).

						%polytimes
polytimes(poly([]), _, poly([])).

polytimes(poly(Monomials1), poly(Monomials2), poly(Polytimes)) :-
	dotProduct(Monomials1, Monomials2, Polytimes),!.

polytimes(Expression1, Expression2, Polytimes) :-
	as_polynomial(Expression1, Polynomial1),
	as_polynomial(Expression2, Polynomial2),
	polytimes(Polynomial1, Polynomial2, Polytimes).

dotProduct([Monomial| Rest], Monomials, Polytimes) :-
	product(Monomial, Monomials, Solution),
	dotProduct(Rest, Monomials, RicSolution),
	append(Solution, RicSolution, Polytimes).

product(m(_, _, _), [], []).
product(m(C1, TD1, Var1), [m(C2, TD2, Var2)| Rest], [m(C, TD, Var)| Rec]) :-
	C is C1 * C2,
	TD is TD1 + TD2,
	append(Var1, Var2, Var),
	product(m(C1, TD1, Var1), Rest, Rec).

						%as_monomials
as_monomial(Expression, m(C, TD, Sorted)) :-
	as_variable(Expression, Variables),
	find_coefficients(Variables, Coe, ListVar),
	C is round(Coe * 1000) / 1000,
	sumdegree(ListVar, TD),
	monomial_sort(ListVar, Sorted),!.

						%as_variable
as_variable(X*Y, Solution) :-
	as_variable(X, R), !,
	as_variable(Y, E),
	append(R, E, Solution).

as_variable(X^Y, [v(Y,X)]) :-
	Y > 0,
	integer(Y),
	X \= pi,
	atom(X), !.

as_variable(X, [v(1,X)]):- atom(X), X \=  pi.
as_variable(X^0,[1]) :- atom(X), X \=  pi.
as_variable(+X, [v(1,X)]):- atom(X), X \=  pi.
as_variable(+X^0,[1]) :- atom(X), X \=  pi.
as_variable(-X, [v(1,X)]):- atom(X), X \=  pi.
as_variable(-X^0,[1]) :- atom(X), X \=  pi.
as_variable(C, R) :- as_coefficient(C, R).

						%find_coefficient
find_coefficients([], 1, []).
find_coefficients([Coefficient| Rest], Product, Variables) :-
	number(Coefficient), !,
	find_coefficients(Rest, RecSol, Variables),
	Product is Coefficient * RecSol.
find_coefficients([C| Rest], Product, [C| Variables]) :-
	find_coefficients(Rest, Product, Variables).

						%sumdegree
sumdegree([], 0).
sumdegree([v(Degree, _)| Rest], Solution) :-
	sumdegree(Rest, RecSol),
	Solution is Degree + RecSol.

						%ordinamento dei monomi
monomial_sort([], []).
monomial_sort([Variable], [Variable]).
monomial_sort(Monomials, Sorted) :-
	Monomials = [_, _| _],
	divide(Monomials, Monomial1, Monomial2),
	monomial_sort(Monomial1, Sorted1),
	monomial_sort(Monomial2, Sorted2),
	monomial_compare(Sorted1, Sorted2, Sorted), !.

monomial_compare([], Variable, Variable).
monomial_compare(Variable, [], Variable) :- Variable \= [].
monomial_compare([v(G1,S1)|T1],[v(G2,S2)|T2],[v(G1,S1)|Tail]) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 < C2,
	monomial_compare(T1,[v(G2,S2)|T2],Tail).

monomial_compare([v(G1,S1)|T1],[v(G2,S2)|T2],[v(G2,S2)|Tail]) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 > C2,
	monomial_compare([v(G1,S1)|T1],T2,Tail).

monomial_compare([v(G1,S1)|T1],[v(G2,S2)|T2],[v(Sum,S2)|Tail]):-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 = C2,
	Sum is G1 + G2,
	monomial_compare(T1,T2,Tail).

						%divide
divide(L,A,B) :- d(L,L,A,B).
d([],R,[],R).
d([_],R,[],R).
d([_,_|T],[X|L],[X|L1],R) :- d(T,L,L1,R).

						%coefficient
as_coefficient(C, [R]) :- R is C.

as_coefficient(C^E, [R]) :-
	is_number(C, [C1]),
	is_number(E, [E1]),
	R is C1^E1,!.
as_coefficient(C/D, [R]) :-
	is_number(C, [C1]),
	is_number(D, [D1]),
	R is C1 rdiv D1, !.

						%ricorsione di as_coefficient
is_number(C, [C]) :- number(C), !.
is_number(C, R) :- as_coefficient(C,R), !.

						%as_polynomial
as_polynomial(Expression, poly(Sorted)) :-
	get_Monomials(Expression, Monomials),
	polynomial_sort(Monomials, Sorted), !.

get_Monomials(Expression1+Expression2, Monomial) :-
	as_monomial(Expression1, Monomial1),
	get_Monomials(Expression2, Monomial2),
	append(Monomial2, [Monomial1], Monomial).

get_Monomials(Expression1-Expression2, Monomial) :-
	as_monomial(Expression1, Monomial1),
	Monomial1 = m(Coefficient, Power, Variables),
	CoeNeg is Coefficient * -1,
	get_Monomials(Expression2, Monomial2),
	append(Monomial2, [m(CoeNeg, Power, Variables)], Monomial).

get_Monomials(Expression, [Monomial]) :-
	as_monomial(Expression, Monomial).

						%polynomial_sort
polynomial_sort([], []).
polynomial_sort([Monomial], [Monomial]).
polynomial_sort(Monomials, Sorted) :-
	Monomials = [_, _| _],
	divide(Monomials, Monomial1, Monomial2),
	polynomial_sort(Monomial1, Sorted1),
	polynomial_sort(Monomial2, Sorted2),
	lexical_order(Sorted1, Sorted2, Sorted).

lexical_order([], Monomial, Monomial).
lexical_order(Monomial, [], Monomial) :- Monomial \= [].
lexical_order([M1| T1], [M2| T2], [M1| Tail]):-
	compare_rules(M1, M2, -1),
	lexical_order(T1, [M2| T2], Tail).

lexical_order([M1| T1], [M2| T2], [M2 |T]) :-
	compare_rules(M1, M2, 1),
	lexical_order([M1| T1], T2, T).

lexical_order([m(C1, TD, V)| T1],[m(C2, TD, V)| T2],[m(Sum, TD, V)| Tail]):-
	Sum is C1 + C2,
	lexical_order(T1, T2, Tail).

lexical_order([M1| T1], [M2| T2], [M1, M2| Tail]):-
	compare_rules(M1, M2, 0),
	lexical_order(T1, T2, Tail).

compare_rules(m(_, _, [v(G, S)| T1]), m(_, _, [v(G, S)| T2]), Tail) :-
	compare_rules(m(_, _, T1), m(_, _, T2), Tail).
compare_rules(m(_, _, []),m(_, _, []), 0).

compare_rules(m(_, _, [v(_, S1)| _]), m(_, _, [v(_, S2)| _]), -1) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 < C2.
compare_rules(m(_, _, [v(G1, S)| _]), m(_, _, [v(G2, S)| _]), -1) :-
	G1 < G2.
compare_rules(m(_, _, []), m(_, _, M), -1):- M \= [].

compare_rules(m(_, _, [v(_, S1)| _]), m(_, _, [v(_, S2)| _]), 1) :-
	char_code(S1, C1),
	char_code(S2, C2),
	C1 > C2.
compare_rules(m(_, _, [v(G1, S)| _]), m(_, _, [v(G2, S)| _]), 1) :-
	G1 > G2.
compare_rules(m(_, _, M),m(_, _, []), 1) :- M \= [].

						%polyval

						%pprint_polynomial
pprint_polynomial(poly(Monomial)):-
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
% TODO: MANCA FARE IL POLYVAL
% TODO: INSERIRE DENTRO polynomials_sort sort(2, @=< , Risultato, Sorted)
% TODO: FARE LA FUNZIONE polynomials_sort
%%%% End of file -- polinomimultivariati.pl --