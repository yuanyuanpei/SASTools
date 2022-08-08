*Three methods to include several sas programs in one program.;
***Method 1*********************;
%include "C:\Users\yuanyuanp\Desktop\test\p1.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p2.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p3.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p4.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p5.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p6.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p7.sas";
%include "C:\Users\yuanyuanp\Desktop\test\p8.sas";

****Method 2********************;
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

****Method 3********************;
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
