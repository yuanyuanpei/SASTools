dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';
proc datasets lib=work memtype=data kill nolist;quit;run;

*Macro variables to be modified:;
%let SDTMpath=C:\Users\yuanyuanp\Desktop\CUT\Data;
%let OUTpath=C:\Users\yuanyuanp\Desktop\CUT\Output;
%let cutdate=2021-11-30; *YYYY-MM-DD;

libname cut "&SDTMpath.";

*取所有domain的名字：AE, CM, MH, SUPPAE,...;
filename xxx pipe "dir ""&SDTMpath."" /b";

data fileall file;
infile xxx truncover;
input @1 filenm $15.;
dsnm=scan(filenm,1,'.');output fileall;
if index(dsnm,"supp")=0 then output file;
run;

proc sql noprint;
select distinct dsnm,count(distinct dsnm)into:dnms separated by "#",:count
from fileall;
quit;


%macro exe(ds);
*//////////////一.合并原domain和SUPP domain/////////////////////////////////;

%if %index(&dnms.,&ds.)>0 and %index(&dnms.,supp&ds.)>0 %then %do;
	*把SUPPAE转置为NEW_SUPPAE;
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

	*把NEW_SUPPAE跟AE合并为CO_AE;
	*找到&ds.的所有变量放在一个宏变量里，查找是否有&ds.SEQ变量。;
	proc sql noprint;
	select distinct name into: varlst separated by "#"
	from sashelp.Vcolumn
	where libname="CUT" and memname=%upcase("&ds.");
	quit;
	*如原domain有XXSEQ变量，则left join时条件on round(a.&ds.seq,1.)=round(b.seq&ds.,1.) ;
	%if %index(&varlst.,&ds.SEQ)>0 %then %do;
		proc sql noprint;
		create table co_&ds. as
		select *
		from cut.&ds. a left join new_supp&ds. as b
		on a.usubjid=b.susubjid and round(a.&ds.seq,1.)=round(b.seq&ds.,1.) and a.domain=b.rdomain;
		quit;
	%end;
	*如果没有XXSEQ变量，则left join usubjid和domain名即可。;
	%if %index(&varlst.,&ds.SEQ)=0 %then %do;
		proc sql noprint;
		create table co_&ds. as
		select *
		from cut.&ds. a left join new_supp&ds. as b
		on a.usubjid=b.susubjid and  a.domain=b.rdomain;
		quit;
	%end;

%end;

*没有SUPP的domain，直接将原domain作为CO_&ds.;
%if %index(&dnms.,&ds.)>0 and %index(&dnms.,supp&ds.)=0 %then %do;
	data co_&ds.;
	set cut.&ds.;
	run;
%end;

*///////////////二.合并后的domain与cut比较日期///////////////////////////////;

*取出CO_&ds.的所有date变量（&dtvar.)，与cut off date比较，加flag;

proc contents data=co_&ds. out=dic_&ds.;run;
*预设宏变量xxvlst为空;
%let &ds.vlst=NULL;

proc sql noprint;
select distinct name into: &ds.vlst separated by " "
from dic_&ds.
where prxmatch("/(date\/)|( date)|(date )/i", label) ;
quit;

*CO_&ds.中有日期型变量的，将日期与cut比较，出out_&ds.;
*调用&xxvlst;
%if &&&ds.vlst ^=NULL %then %do;

	data out_&ds.;
	set co_&ds.;
	cutdate="&cutdate.";
	ncut=input(cutdate,yymmdd10.); 
	ncutyr=input(substr(cutdate,1,4),best.);
	ncutmos=input(substr(cutdate,6,2),best.);

	array dtvar &&&ds.vlst; *隐式数组下标;
	do over dtvar;*隐式数组下标;
		*取日期变量的年，月，日;
		uk1=substr(dtvar,1,4);nuk1=input(uk1,best.);
		uk2=substr(dtvar,6,2);nuk2=input(uk2,best.);

		*如果有完整年月日;
		if prxmatch("/^(\d\d\d\d-\d\d-\d\d)$/", dtvar) then do;
			nall=input(dtvar,yymmdd10.);
			if nall>ncut then flag1='本条记录中的日期变量有完整的年-月-日，且该日期在Cut-off Date之后';else flag1='';
		end;

		*如果只有年月，跟cut的年-月相比;
		if prxmatch("/^(\d\d\d\d-\d\d)$/", dtvar) then do;
			if nuk1>ncutyr or nuk1=ncutyr and nuk2>ncutmos then flag2='日期变量仅有年-月，且年-月在cut的年-月之后';else flag2='';
		end;

		*如果只有年，跟cut的年相比;
		if prxmatch("/^(\d\d\d\d)$/", dtvar) then do;
			if nuk1>ncutyr then flag3='日期变量仅有年，且年份在cut年份之后';else flag3='';
		end;

	end;
	drop ncut ncutyr ncutmos uk1 uk2 nuk1 nuk2 nall Susubjid seq&ds.;
	run;

%end;

*CO_&ds.中没有日期型变量的，加flag;
%if &&&ds.vlst  = NULL %then %do;
	data out_&ds.;
	set co_&ds.;
	flag="本domain没有日期型变量";
	run;
%end;

%mend;


*适用于所有domain（不含SUPP);
data _null_;
set file;
rc=dosubl(cats('%exe(',dsnm,')'));
run;






*output所有的out_xx;
%macro output(ds);
ODS...
%mend output;

data _null_;
set file;
rc=dosubl(cats('%output(',dsnm,')'));
run;



