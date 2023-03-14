dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';
proc datasets lib=work memtype=data kill nolist;quit;run;

*Macro variables to be modified:;
%let SDTMpath=C:\Users\yuanyuanp\Desktop\SDTM;
%let OUTpath=C:\Users\yuanyuanp\Desktop\Output;
%let cutdate=2021-11-30; *YYYY-MM-DD;

libname cut "&SDTMpath.";

*fetch all domain names: i.e. AE, CM, MH, SUPPAE,...;
filename xxx pipe "dir ""&SDTMpath."" /b";

data fileall file;
infile xxx truncover;
input @1 filenm $15.;
dsnm=scan(filenm,1,'.');
output fileall;
if index(dsnm,"supp")=0 then output file;
run;

proc sql noprint;
select distinct dsnm,count(distinct dsnm)into
:dnms separated by "#",
:count
from fileall;
quit;


%macro exe(ds);
*//////////////1.Combine origin domain and SUPPxx domain/////////////////////////////////;

*//A: both origin domain and SUPP domain exist;
%if %index(&dnms.,&ds.)>0 and %index(&dnms.,supp&ds.)>0 %then %do;
	*transpose SUPPxx to NEW_SUPPxx datasets;
	proc sort data=cut.SUPP&ds. out=SUPP&ds.;
	by usubjid rdomain idvar idvarval;
	run;

	proc transpose data=SUPP&ds. out=NEW_SUPP&ds.;
	by usubjid rdomain idvar idvarval;
	var qval;
	id qnam;
	idlabel qlabel;
	run;

	data NEW_SUPP&ds.;
	set NEW_SUPP&ds.;
	SUSUBJID=USUBJID;
	SEQ&ds.=input(IDVARVAL,best.);
	drop USUBJID IDVAR IDVARVAL _NAME_ _LABEL_;
	run;

	*combine NEW_SUPPAE and AE to CO_AE dataset;

	**gather all variables from &ds.into Single macro variable, check whether '&ds.SEQ' variable exists;
	proc sql noprint;
	select distinct name into: varlst separated by "#"
	from sashelp.Vcolumn
	where libname="CUT" and memname=%upcase("&ds.");
	quit;

	**if xxSEQ variable of origin domain exists, then 
	  left join origin domain with new_supp domain
	  on usubjid, domainname and xxSEQ ;

	%if %index(&varlst.,&ds.SEQ)>0 %then %do;
		proc sql noprint;
		create table co_&ds. as
		select *
		from cut.&ds. a left join new_supp&ds. as b
		on a.usubjid=b.susubjid and round(a.&ds.seq,1.)=round(b.seq&ds.,1.) and a.domain=b.rdomain;
		quit;
	%end;
	**if XXSEQ variable of origin domain doesn't exist, then
	  left join on usubjid and domain;
	%if %index(&varlst.,&ds.SEQ)=0 %then %do;
		proc sql noprint;
		create table co_&ds. as
		select *
		from cut.&ds. a left join new_supp&ds. as b
		on a.usubjid=b.susubjid and  a.domain=b.rdomain;
		quit;
	%end;

%end;


*//B: Only origin domain exist;
*transfer origin domain as CO_&ds.;;
%if %index(&dnms.,&ds.)>0 and %index(&dnms.,supp&ds.)=0 %then %do;
	data co_&ds.;
	set cut.&ds.;
	run;
%end;

*///////////////2.Compare date variables of combined domain With cut off date. //////////////////;

*fetch all date variables(&dtvar.) from CO_&ds., compare them with cutoff date, add flag;

proc contents data=co_&ds. out=dic_&ds.;run;

*pre-define macro variable &ds.vlst as null;
%let &ds.vlst=NULL;

proc sql noprint;
select distinct name into: &ds.vlst separated by " "
from dic_&ds.
where prxmatch("/(date\/)|( date)|(date )/i", label) ;
quit;

*CO_&ds.: once date variable exists, compare it with cutoff date;
*invoke &xxvlst;
%if &&&ds.vlst ^=NULL %then %do;

	data out_&ds.;
	set co_&ds.;
	cutdate="&cutdate.";
	ncut=input(cutdate,yymmdd10.); 
	ncutyr=input(substr(cutdate,1,4),best.);
	ncutmos=input(substr(cutdate,6,2),best.);

	array dtvar &&&ds.vlst; *implicit array subscript;
	do over dtvar;*implicit array subscript;
		*fetch year, month, day of date variables;
		uk1=substr(dtvar,1,4);nuk1=input(uk1,best.);
		uk2=substr(dtvar,6,2);nuk2=input(uk2,best.);

		*if date is intact;
		if prxmatch("/^(\d\d\d\d-\d\d-\d\d)$/", dtvar) then do;
			nall=input(dtvar,yymmdd10.);
			if nall>ncut then flag1='The date variable of this obseravation is intact, and the date is after cut off date.';else flag1='';
		end;

		*if only year-month exists;
		if prxmatch("/^(\d\d\d\d-\d\d)$/", dtvar) then do;
			if nuk1>ncutyr or nuk1=ncutyr and nuk2>ncutmos then flag2='Only year and month of the date variable exist, and is after cut off year-month.';else flag2='';
		end;

		*if only year exists;
		if prxmatch("/^(\d\d\d\d)$/", dtvar) then do;
			if nuk1>ncutyr then flag3='Only year of the date variable exists, and is after the cut off year.';else flag3='';
		end;

	end;
	drop ncut ncutyr ncutmos uk1 uk2 nuk1 nuk2 nall Susubjid seq&ds.;
	run;

%end;

*No date variable exists in the CO_&ds.dataset, add flag;
%if &&&ds.vlst  = NULL %then %do;
	data out_&ds.;
	set co_&ds.;
	flag="No date variable exists in this domain.";
	run;
%end;

%mend;


*the %exe macro applied to all domain(exclude SUPPxx);
data _null_;
set file;
rc=dosubl(cats('%exe(',dsnm,')'));
run;






*output all out_xx;
%macro output(ds);
ODS...
%mend output;

data _null_;
set file;
rc=dosubl(cats('%output(',dsnm,')'));
run;



