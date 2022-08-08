*Run the following 4 lines of code:;
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';
proc datasets lib=work memtype=data kill nolist;quit;run;

*1.Define path of your SDTM datasets:;
%let SDTMpath=F:\Project\504\2020-504-00CH3\DM\SDTM\SACHI unblinded and blinded SDTM_05Jul2022_Update\03.1 Split unblinded SDTM1;
*2.Define path of the output .xlsx path:;
%let OUTpath=F:\Project\504\2020-504-00CH3\DM\SDTM\SACHI unblinded and blinded SDTM_05Jul2022_Update\03.1 Split unblinded SDTM1;
*3.Define Cut off date (format:YYYY-MM-DD);
%let cutdate=2022-06-08; 

libname cut "&SDTMpath.";

*Transpose SUPP- domain datastes;
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

%TRSUPP

*Find all all 'date' variables;
data adm;
  set sashelp.Vcolumn;
  where libname="CUT" and prxmatch("/(date\/)|( date)|(date )/i", label);
run;

proc sql noprint;
 select distinct catt("CUT.", memname, "(keep=",  name, " USUBJID", ")") 
 into: dslst separated by " " 
  from adm
 ;
 select distinct name into: dtlst separated by "," 
  from adm
 ;
quit;

data alldtc;
 set &dslst. indsname=source;
 datasource = source;
 alldtc = coalescec(&dtlst.);
run;

proc sort data=alldtc;
by USUBJID;
run;

*Cut off condition;

data cutoff;
set alldtc;
cutdate="&cutdate.";
ncut=input(cutdate,yymmdd10.); 
ncutyr=input(substr(cutdate,1,4),best.);
ncutmos=input(substr(cutdate,6,2),best.);
if alldtc ^='' then do;
uk1=substr(alldtc,1,4);
uk2=substr(alldtc,6,2);
uk3=substr(alldtc,9,2);
end;
else do;
uk1='';
uk2='';
uk3='';
end;
nuk1=input(uk1,best.);
nuk2=input(uk2,best.);

if (uk2 ^='UK' and uk2 ^='') and (uk3 ^= 'UK' and uk3 ^='') then do;
	nall=input(alldtc,yymmdd10.);
	if nall>ncut then flag='xCut-off Datex';
end;
if uk2='UK' and uk3='UK' or uk2='' and uk3='' then do;
	if nuk1>ncutyr then flag='x';else flag='';
end;
if uk2 ^='' and uk2 ^='UK' and (uk3='' or uk3='UK') then do;
	if nuk1>ncutyr or nuk1=ncutyr and nuk2>ncutmos then flag='x';else flag='';
end;
drop nall ncut ncutyr ncutmos uk1 uk2 uk3 nuk1 nuk2;
run;

*Output xlsx;

*Method1:;

/*ods _all_ close;*/
/**ods excel file="&OUTpath.\CutOffTest_%sysfunc(today(),yymmddn8.).xlsx";*/
/*ods excel file="&OUTpath.\ttt.xlsx";*/
/**/
/*ods excel options(sheet_name="Cut Off Test" autofilter="all" frozen_headers="on");*/
/*proc report data=cutoff  nowindows;*/
/*compute flag;*/
/*if flag ^='' then call define(_row_,"style","style=[backgroundcolor=Yellow]");*/
/*endcomp;*/
/*run;*/
/**/
/*ods excel close;*/

*Method2:;

proc export data=cutoff outfile="&OUTpath.\Cut Off Test_%sysfunc(today(),yymmddn8.).xlsx"
dbms=xlsx replace label;
run;

*Drop new created temporary datasets;
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

