
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

%let old=C:\Users\yuanyuanp\Desktop\OLD;
%let new=C:\Users\yuanyuanp\Desktop\NEW;

libname v1 "&old.";
libname v2 "&new.";

ods _all_ close;
ods pdf;
%macro compare;
filename xxx pipe "dir ""&old."" /b";

data file;
infile xxx truncover;
input @1 filename $1000.;
dsname=scan(filename,1,'.');
run;

proc sql noprint;
select filename, dsname, count(filename) into 
:fnames  separated by " ", :dsnames separated by " ", :count
from file;quit;

%do i=1 %to &count;
%let ds=%scan(&dsnames,&i,%str( ));%put &ds.;
title "&ds.";
proc compare base=v1.&ds. compare=v2.&ds. list error maxprint=32000;run;

%end;
%mend;
%compare;

ods pdf close;
