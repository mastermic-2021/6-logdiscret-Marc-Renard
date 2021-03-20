\\default(parisizemax, 70m);

gMod = Mod(6, 682492462409094395392022581537473179285250139967739310024802121913471471);
A = 245036439927702828116237663546936021015004354074422410966568949608523157;
n=gMod.mod;
Amod=Mod(A,n);


\\########################################################################################################################################################
\\####################################################### Partie non utilisée ############################################################################
\\########################################################################################################################################################

\\Fonction f ok, fonctionne correctement
f(V)={         \\cette fonction prend en paramètre des Mod(a,b)
	xMod=V[1];pg=V[2];pa=V[3];gBaseMod=V[4];aMod=V[5];
	m=lift(xMod)%3;
	mod=xMod.mod;
	\\ on sépare <g> en 3 parties G0,G1,G2 selon la valeur de g^k mod 3
	if(m==0,xMod=xMod^2;pg=(2*pg)%(mod-1);pa=(2*pa)%(mod-1),if(m==1,xMod=xMod*gBaseMod;pg=(pg+1)%(mod-1),xMod=xMod*aMod;pa=(pa+1)%(mod-1)));
	V=[xMod,pg,pa,gBaseMod,aMod];
	return(V);
};

rhoPollard(A,gMod1,p)={ \\on cherche l tel que a=gMod1^l       Je ne comprends définitivement pas ce qui ne va pas dans cet algorithme
	r=random(p-1)+1;
	xMod1=gMod1^(r);
	pg1=r;
	pa1=0;
	aMod=Mod(A,p);
	v=[xMod1,pg1,pa1,gMod1,aMod];
	v2=f(f(v));
	while(v[1]!=v2[1] || gcd(v2[3]-v[3],p)!=1,v=f(v);v2=f(f(v2));print(v,v2));
	print(v[2]," ",v2[2]," ",v[3]," ",v2[3]);
	return (lift(Mod((v[2]-v2[2]),(p-1)/2)/Mod((v2[3]-v[3]),(p-1)/2)));
}

\\########################################################################################################################################################
\\######################################################### Partie utilisée ##############################################################################
\\########################################################################################################################################################



\\ baby step GIANT step
\\ on utilise une map pour faciliter l'acces aux éléments, et ainsi réduire le temps d'execution de l'algorithme
bsgs(A , g , n)={
	B = ceil( sqrt(n) );
	baby = Map();
	for(i = 0 , B - 1 ,mapput( baby , g^(i) , i )); \\création de la liste {g^a0 | 0<=a0<B}
	G = ( g^B )^(-1);
	rep = 1;
	\\ boucle for pour chercher els colisions entre A*G^a1 et g^a0
	for(a1 = 0, B + 1,
		pot = A*(G)^a1;
		test = mapisdefined( baby , pot , &rep );
		if( test == 1 , return( a1*B + rep ));
		
		\\ Si une colision est trouvée, alors g^a0=A*G^a1=A*g^(-a1*B)
		\\ Ainsi en multipliant par g^(a1*B) on obtient: g^(a0+a1*B)=A
		\\ Une solution à notre problème est donc log_g(A)=a0+a1*B
	);
}


\\ Fonction intermédiaire de l'algorithme de Pohlig-Hellman
\\ Travaille uniquement sur des modules de la forme n=p^e avec p premier

sousPohHell( g , p , e , A )={
	si = 0;
	gi = g^(p^(e - 1));
	for( i = 0 , e - 1 ,
		ai = (A*g^(-si))^(p^(e - i - 1));
		logTempo = bsgs( ai , gi , p);
		si = si + logTempo*(p^i);
	);
	return(si);
}


\\ Algorithme de Polhig-Hellman : permet de réduire la taille des nombres sur lesquels on travaille pour gagner en efficacité et ensuite recombiner les résultats obtenus pour avoir la solution finale.
\\ Factorise le nombre n pour diviser le problème en sous problèmes avec des n de la forme n=p^e (c'est le travail de la fonction sousPohHell)

PohHell(g , A , n)={
	f = factor( n - 1 );
	taille = matsize(f)[1];
	listModChinois = vector(taille);
	for( i = 1 , taille ,
		pi = f[ i , 1 ];
		ei = f[ i , 2 ];
		gi = g^(( n - 1 )/(pi^(ei)));
		Ai = Amod^(( n - 1 )/(pi^(ei)));
		logIntermed = sousPohHell( gi , pi , ei , lift(Ai) );
		listModChinois[i] = Mod(logIntermed,pi^(ei));
	);
	logFinal = lift( Mod( lift( chinese(listModChinois) ) , n ) );
	return(logFinal);
}
print( PohHell( gMod , A , n ) );
