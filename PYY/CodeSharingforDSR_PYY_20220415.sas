/*Sharing On Apr15,2022 By Yuanyuan Pei*/
/*Topic: SAS Tool for Status Report*/

*****Gain All Needed Data*****;

*Define Raw dataset library:;
libname raw "...";

*Import .xlsx;
proc import datafile="..." out =... dbms=xlsx replace;getnames=yes;run;

*Import .csv with Unicode;
proc import datafile="..." out =... dbms=xlsx replace;getnames=yes;delimiter='09'x;run;


*****Product Per Report*****;

*Cartesian Product;
proc sql;
create table multi as
select A.*,B.* from A,B;
quit;

*Count Total;
proc sql;
insert into C (var1,var2,var3)
select ... from ...;
quit;


*****Output Report.xlsx*****;
ods excel options(sheet_name="xxx" frozen_header="on" embedded_titles="yes" hidden_rows='3');


*****Organize Programs*****;

*Get Current Root;
%macro currentroot;
	%global currentroot;
	%let currentroot=%sysfunc(getoption(sysin));
	%if "&currentroot" eq "" %then %do;
	%let currentroot=%sysget(SAS_EXECFILEPATH);
	%end;
%mend;
%currentroot;

*Three methods to include several sas programs in one program.;

***Method 1*;
%include "C:\Users\yuanyuanp\Desktop\test\p1.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p2.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p3.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p4.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p5.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p6.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p7.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p8.sas";

****Method 2*;
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';
proc datasets nolist memtype=all library=work kill;quit;

filename xx pipe "dir C:\Users\yuanyuanp\Desktop\test /b";
data pname;
infile xx truncover;
input @1 pnm $100.;
if index(pnm,"run")=0;
run;

proc sql noprint;
select pnm,count(pnm) into: pnms separated by "#",:count
from pname;
quit;

%put &pnms.;

%macro loops;
%do i=1 %to &count;
%let pg=%scan(&pnms,&i,%str(#));
%put &pg.;
%include "C:\Users\yuanyuanp\Desktop\test\&pg.";
%end;
%mend loops;
%loops;

****Method 3*;
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';
proc datasets nolist memtype=data library=work kill;quit;

filename xx pipe "dir C:\Users\yuanyuanp\Desktop\test /b";
data pname;
infile xx truncover;
input @1 pnm $10.;
if index(pnm,"run")=0;
run;

%macro xinclu(a);
%include "C:\Users\yuanyuanp\Desktop\test\&a.";
%mend xinclu;

data _null_;
set pname;
rc=dosubl(cats('%xinclu(',pnm,')'));
run;
