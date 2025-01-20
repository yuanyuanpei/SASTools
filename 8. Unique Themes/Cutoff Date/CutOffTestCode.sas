dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';
proc datasets lib=work memtype=data kill nolist;quit;run;

*Macro variables to be modified:;
%let SDTMpath=F:\Project\504\2020-504-00CH4\Document\1st DMC\dry run\SDTM\2020-504-00CH4_Draft SDTM Package_20211224\Cut;
%let OUTpath=F:\Project\504\2020-504-00CH4\Document\1st DMC\dry run\SDTM\2020-504-00CH4_Draft SDTM Package_20211224\Cut;
%let cutdate=2022-05-30; *YYYY-MM-DD;

libname cut "&SDTMpath.";

******�Ƚ�����SUPP���ݼ�ת�ã�������CUT����;
proc sql noprint;
select distinct memname,count(distinct memname) into :supplst separated by " ",:count
from sashelp.Vcolumn
where libname="CUT" and index(memname,"SUPP")=1;
quit;

%put &count.;

%macro trSUPP;
%do i = 1 %to &count;
%let dsname=%scan(&supplst,&i,%str( ));
%put &dsname.;
proc sort data=cut.&dsname. out=work.&dsname.;
by usubjid idvar idvarval;
run;

proc transpose data=work.&dsname. out=cut.t_&dsname.;
by usubjid idvar idvarval;
var qval;
id qnam;
idlabel qlabel;
run;
%end;
%mend trSUPP;

%TRSUPP;
*****************************************;

data adm;
  set sashelp.Vcolumn;
  where libname="CUT" and prxmatch("/(date\/)|( date)|(date )/i", label);
run;

/*proc contents data=sashelp.vcolumn;run;*/

proc sql noprint;
 select distinct catt("CUT.", memname, "(keep=",  name, " USUBJID", ")") 
 into: dslst separated by " " 
  from adm
 ;*���������dslst���ڴ��mystudy lib�����е����ݼ���name��keep�ı�����
  e.g.dslst�е�һ��ֵ�ǣ�mystudy.ae(keep=aeendat __SUBJECTKEY);
 select distinct name into: dtlst separated by "," 
  from adm
 ;*���������dtlst���ڴ��ÿ�����ݼ��е����ڿ����;
quit;

data alldtc;*����һ�������������ݵ����ݼ�alldtc;
 set &dslst. indsname=source;
 datasource = source;
 alldtc = coalescec(&dtlst.);
/* if alldtc ^= '';*/
/* if prxmatch("/^(\d\d\d\d-\d\d-\d\d)|(\d\d\d\d-\d\d)|(\d\d\d\d)$/", strip(alldtc));*ֻ����������/����/���ʽ������;*/
run;

proc sort data=alldtc;
by USUBJID;
run;

data cutoff;
set alldtc;
cutdate='&cutdate.';
ncut=input(cutdate,yymmdd10.); 
ncutyr=input(substr(cutdate,1,4),best.);
ncutmos=input(substr(cutdate,6,2),best.);
if alldtc ^='' then do;
uk1=substr(alldtc,1,4);
uk2=substr(alldtc,6,2);*��;
uk3=substr(alldtc,9,2);*��;
end;
else do;
uk1='';
uk2='';
uk3='';
/*flag='���ڱ���Ϊ��';*/
end;
*alldtc���꣨��ֵ�����£���ֵ�������壨��ֵ��;
nuk1=input(uk1,best.);
nuk2=input(uk2,best.);

*alldtc�����վ��У�����cutֱ�ӱ�;
if (uk2 ^='UK' and uk2 ^='') and (uk3 ^= 'UK' and uk3 ^='') then do;
	nall=input(alldtc,yymmdd10.);
	if nall>ncut then flag='���ڱ�������������-��-�գ��Ҹ�������Cut-off Date֮��';
end;
*alldtcֻ���꣬��alldtc�����cut�������;
if uk2='UK' and uk3='UK' or uk2='' and uk3='' then do;
	if nuk1>ncutyr then flag='���ڱ��������꣬�������cut���֮��';else flag='';
end;
*alldtcֻ������£���alldtc����-�¸�cut����-�����;
if uk2 ^='' and uk2 ^='UK' and (uk3='' or uk3='UK') then do;
	if nuk1>ncutyr or nuk1=ncutyr and nuk2>ncutmos then flag='���ڱ���������-�£�����-����cut����-��֮��';else flag='';
end;
/*label alldtc='���ڱ�������' datasource='���ڱ�������Դ' cutdate='CutOff����';*/
drop nall ncut ncutyr ncutmos uk1 uk2 uk3 nuk1 nuk2;
run;

ods _all_ close;
ods excel file="""&OUTpath.""\CutOffTest_%sysfunc(today(),yymmddn8.).xlsx";
ods excel options(sheet_name="Cut Off Test" autofilter="all" frozen_headers="on");
proc report data=cutoff  nowindows;
compute flag;
if flag ^='' then call define(_row_,"style","style=[backgroundcolor=Yellow]");
endcomp;
run;

ods excel close;


proc sql;
select distinct memname,count(distinct memname) into :drplst separated by " ",:count
from sashelp.Vcolumn
where libname="CUT" and index(memname,"T_")=1;
quit;
%put &count.;
%macro dropds;
%do i = 1 %to &count;
%let ds=%scan(&drplst,&i,%str( ));
proc sql;
drop table CUT.&ds.;quit;
%end;
%mend dropds;
%dropds

