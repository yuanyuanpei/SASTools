
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets nolist memtype=data library=work kill;
quit;

%macro currentroot;
	%global currentroot;
	%let currentroot=%sysfunc(getoption(sysin));
	%if "&currentroot" eq "" %then %do;
		%let currentroot=%sysget(SAS_EXECFILEPATH);
	%end;
%mend;
%currentroot;
%put &currentroot.;
%let root=%substr(%str(&currentroot),1,%index(%str(&currentroot),%str(\combine excel))-1);*combine excel�Ǳ����������;
%put &root.;

%macro nobs(ds);
  %local nobs dsid rc err;
  %let err=ERR%str(OR);
  %let dsid=%sysfunc(open(&ds));
  %if &dsid EQ 0 %then %do;
    %put &err: (nobs) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;

  %else %do;
    %if %sysfunc(attrn(&dsid,WHSTMT)) or
      %sysfunc(attrc(&dsid,MTYPE)) EQ VIEW %then %let nobs=%sysfunc(attrn(&dsid,NLOBSF));
    %else %let nobs=%sysfunc(attrn(&dsid,NOBS));
    %let rc=%sysfunc(close(&dsid));
    %if &nobs LT 0 %then %let nobs=0;
&nobs
  %end;
%mend nobs;

filename xxx pipe "dir ""&root."" /b";
data file;
infile xxx truncover;
input @1 filename $1000.;
dname=scan(filename,1,'.');
if dname="combine excel" then delete; 
run;
proc sql noprint;
select filename,dname,count(filename) into 
:fnames  separated by " ",
:dnames separated by " ",
:count
from file;quit;

%macro import;
%do i=1 %to &count;
%let fs=%scan(&fnames,&i,%str( ));
%let ds=%scan(&dnames,&i,%str( ));
proc import datafile="&root.\&fs."
	out=&ds.
	dbms=xlsx replace;
	getnames=yes;
	run;
%end;
%mend;
%import;

ods excel file="&root.\combine.xlsx"; 
%macro out;
%do i=1 %to &count;
%let ds=%scan(&dnames,&i,%str( ));
ods excel options(sheet_name="&ds." frozen_headers="on" );
%if %nobs(&ds.)=0 %then %do;
	data &ds.;
	length obs $200;
	obs="No record Found";
    run;
	proc report data=&ds. nowindows;
	column obs;      
	run;
%end; 
%else %do;
proc report data=&ds. nowindows;
run;
%end;
%end;
%mend;
%out;
ods excel close;
