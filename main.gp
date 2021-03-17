g = Mod(6, 682492462409094395392022581537473179285250139967739310024802121913471471);
A = 245036439927702828116237663546936021015004354074422410966568949608523157;
n=g.mod;
Amod=Mod(A,n);


f(V)={\\cette fonction prend en paramètre des Mod()
	x=V[1];a=V[2];b=V[3];
	m=lift(x);
	if(m<n/3,y=x^2;r=2*a;s=2*b,if(m<2*n/3,y=x*g;r=a+1,y=x*Amod;s=b+1));
	V=[y,r,s];
	return(V);
};

r1=random(n);
r2=random(n);
Vec1=[(g^r1)*(Amod^r2),Mod(r1,n-1),Mod(r2,n-1)];
Vec2=Vec1;
Vec1=f(Vec1);
Vec2=f(f(Vec2));

while((lift(Vec1[1])!=lift(Vec2[1])),{Vec1=f(Vec1);Vec2=f(f(Vec2));});

rep=lift((Vec2[2]-Vec1[2])/(Vec1[3]-Vec2[3]));
print(rep);
