dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';
proc datasets lib=work memtype=data kill nolist;quit;run;

*Macro variables to be modified:;
%let SDTMpath=C:\Users\yuanyuanp\Desktop\CUT\Data;
%let OUTpath=C:\Users\yuanyuanp\Desktop\CUT\Output;
%let cutdate=2021-11-30; *YYYY-MM-DD;

libname cut "&SDTMpath.";

*ȡ����domain�����֣�AE, CM, MH, SUPPAE,...;
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
*//////////////һ.�ϲ�ԭdomain��SUPP domain/////////////////////////////////;

%if %index(&dnms.,&ds.)>0 and %index(&dnms.,supp&ds.)>0 %then %do;
	*��SUPPAEת��ΪNEW_SUPPAE;
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

	*��NEW_SUPPAE��AE�ϲ�ΪCO_AE;
	*�ҵ�&ds.�����б�������һ�������������Ƿ���&ds.SEQ������;
	proc sql noprint;
	select distinct name into: varlst separated by "#"
	from sashelp.Vcolumn
	where libname="CUT" and memname=%upcase("&ds.");
	quit;
	*��ԭdomain��XXSEQ��������left joinʱ����on round(a.&ds.seq,1.)=round(b.seq&ds.,1.) ;
	%if %index(&varlst.,&ds.SEQ)>0 %then %do;
		proc sql noprint;
		create table co_&ds. as
		select *
		from cut.&ds. a left join new_supp&ds. as b
		on a.usubjid=b.susubjid and round(a.&ds.seq,1.)=round(b.seq&ds.,1.) and a.domain=b.rdomain;
		quit;
	%end;
	*���û��XXSEQ��������left join usubjid��domain�����ɡ�;
	%if %index(&varlst.,&ds.SEQ)=0 %then %do;
		proc sql noprint;
		create table co_&ds. as
		select *
		from cut.&ds. a left join new_supp&ds. as b
		on a.usubjid=b.susubjid and  a.domain=b.rdomain;
		quit;
	%end;

%end;

*û��SUPP��domain��ֱ�ӽ�ԭdomain��ΪCO_&ds.;
%if %index(&dnms.,&ds.)>0 and %index(&dnms.,supp&ds.)=0 %then %do;
	data co_&ds.;
	set cut.&ds.;
	run;
%end;

*///////////////��.�ϲ����domain��cut�Ƚ�����///////////////////////////////;

*ȡ��CO_&ds.������date������&dtvar.)����cut off date�Ƚϣ���flag;

proc contents data=co_&ds. out=dic_&ds.;run;
*Ԥ������xxvlstΪ��;
%let &ds.vlst=NULL;

proc sql noprint;
select distinct name into: &ds.vlst separated by " "
from dic_&ds.
where prxmatch("/(date\/)|( date)|(date )/i", label) ;
quit;

*CO_&ds.���������ͱ����ģ���������cut�Ƚϣ���out_&ds.;
*����&xxvlst;
%if &&&ds.vlst ^=NULL %then %do;

	data out_&ds.;
	set co_&ds.;
	cutdate="&cutdate.";
	ncut=input(cutdate,yymmdd10.); 
	ncutyr=input(substr(cutdate,1,4),best.);
	ncutmos=input(substr(cutdate,6,2),best.);

	array dtvar &&&ds.vlst; *��ʽ�����±�;
	do over dtvar;*��ʽ�����±�;
		*ȡ���ڱ������꣬�£���;
		uk1=substr(dtvar,1,4);nuk1=input(uk1,best.);
		uk2=substr(dtvar,6,2);nuk2=input(uk2,best.);

		*���������������;
		if prxmatch("/^(\d\d\d\d-\d\d-\d\d)$/", dtvar) then do;
			nall=input(dtvar,yymmdd10.);
			if nall>ncut then flag1='������¼�е����ڱ�������������-��-�գ��Ҹ�������Cut-off Date֮��';else flag1='';
		end;

		*���ֻ�����£���cut����-�����;
		if prxmatch("/^(\d\d\d\d-\d\d)$/", dtvar) then do;
			if nuk1>ncutyr or nuk1=ncutyr and nuk2>ncutmos then flag2='���ڱ���������-�£�����-����cut����-��֮��';else flag2='';
		end;

		*���ֻ���꣬��cut�������;
		if prxmatch("/^(\d\d\d\d)$/", dtvar) then do;
			if nuk1>ncutyr then flag3='���ڱ��������꣬�������cut���֮��';else flag3='';
		end;

	end;
	drop ncut ncutyr ncutmos uk1 uk2 nuk1 nuk2 nall Susubjid seq&ds.;
	run;

%end;

*CO_&ds.��û�������ͱ����ģ���flag;
%if &&&ds.vlst  = NULL %then %do;
	data out_&ds.;
	set co_&ds.;
	flag="��domainû�������ͱ���";
	run;
%end;

%mend;


*����������domain������SUPP);
data _null_;
set file;
rc=dosubl(cats('%exe(',dsnm,')'));
run;






*output���е�out_xx;
%macro output(ds);
ODS...
%mend output;

data _null_;
set file;
rc=dosubl(cats('%output(',dsnm,')'));
run;



