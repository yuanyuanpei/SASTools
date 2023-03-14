*transform of variable format;
data t1;
c="13.2";
d1="2022-01-01";
n1=0.78;
d2=22887;

*from char to num(best12.,8.1,...);
num1=input(c,best12.);
*from charDate to numDate;
num2=input(d1,yymmdd10.);

*from num to char;
char1=put(n1,best12.);
*from numDate to charDate;
char2=put(d2,yymmdd10.);

run;

*from datetime to num/char date;
data tt;
	dtc="2020-01-01 00:12:34"dt;*1893456754;

	*get num format of date;
	datepart=datepart(dtc);*21915;
	timepart=timepart(dtc);*754;

	*from num date to char date;
	char=put(datepart,yymmdd10.);*"2020-01-01";
run;

*from sysdate to char sysdate.;
data t2;
	a=today();*a=22887;
	b=%sysfunc(today(),best12.);*b=22887;
	date=put(a,date11.);*"30-AUG-2022";
run;

