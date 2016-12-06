%%%% -*- Mode: Prolog -*-
%%%% polinomimultivariati.pl --

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% coefficients
% Todo informarsi cosa fare con i doppioni.
coefficients(poly(Monomi), Coefficients) :-
	find_coefficients(Monomi,Coefficients).

find_coefficients([m(C ,_ ,_)|Resto],[C|R]):-
	find_coefficients(Resto,R).

find_coefficients([],[]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% variables
% TODO: bisogna gestire il caso in cui ci sono simboli duplicati.
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
as_monomial(Expression, m(C, TD, NoCoeff)) :-
	as_variable(Expression, Variables),
	find_Coefficent(Variables , C, NoCoeff),
	sumdegree(NoCoeff, TD).

%Costants
as_variable(C, [C]) :- C\= [], integer(C).
as_variable(-C , [R]) :- C\= [] , integer(C), R is C * -1.

%Variables
as_variable(X*Y, L) :-
	as_variable(X, R),
	!,
	as_variable(Y, E),
	append(R,E,L).

as_variable(X, [v(1,X)]):-
	X \= [],
	atom(X),
	is_varpower(v(1,X)).
as_variable(X^0,[]) :- atom(X).

as_variable(X^Y, [v(Y,X)]):- !,
	Y >= 0,
	integer(Y),
	atom(X),
	is_varpower(v(Y,X)).

%Coefficiente
find_Coefficent([C|Var],C ,Var) :- integer(C).
find_Coefficent([C|Var],1 ,Vars) :- not(integer(C)), append([C], Var, Vars).

%somma dei gradi
sumdegree([v(N,_)|Resto], R) :-
	sumdegree(Resto,M),!,
	R is N+M.
sumdegree([v(N,_)],N).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%as polynomial
%TODO: Manca L'ordinamento
%TODO: Manca testare
as_polynomial(Expression, poly(Risultato)) :-
	find_monomials(Expression, Risultato).

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
pprint_polynomial(poly([Monomial])):-
	print_monomial(Monomial).


print_monomial([m(C, _, Variables)|Rest], Result):-
	print_variables(Variables, Var),
	print_monomial(Rest, Monomial),
	append([C], Var , Vars),
	append(Vars, Monomial, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% end of file -- polinomimultivariati.pl --
