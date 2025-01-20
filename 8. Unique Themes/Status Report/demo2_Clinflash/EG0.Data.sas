*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2024-760-00CH1
Program Name    :  Study Status Report Program: Run.sas
Program Address : 
Author Name     :  Yuanyuan Pei
Creation Date   :  2024/11/18
Validator Name  :  Xiangyun Xie
Description     :  This program is used to set up %nobs and %imports macros for final report.
*******************************************************************************************;

%macro nobs(ds);
  %local nobs dsid rc err;
  %let err=ERR%str(OR);
  %let dsid=%sysfunc(open(&ds));
  %if &dsid EQ 0 %then %do;
    %put &err: (nobs) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;

  %else %do;
    %if %sysfunc(attrn(**&dsid,WHSTMT)) or
      %sysfunc(attrc(&dsid,MTYPE)) EQ VIEW %then %let nobs=%sysfunc(attrn(&dsid,NLOBSF));
    %else %let nobs=%sysfunc(attrn(&dsid,NOBS));
    %let rc=%sysfunc(close(&dsid));
    %if &nobs LT 0 %then %let nobs=0;
&nobs
  %end;
%mend nobs;


data xxx; 
   *keep pname; 
   length pname   $100 FileRef $8; 
    /* Assign the fileref */ 
   call missing(FileRef); /* Blank, so SAS will assign a file name */ 
   rc1 = filename(FileRef, "&root.\&_mode.\&_file.\&_Date."); /* Associate the file name with the directory */ 
   if rc1 ^= 0 then 
      abort; 
    /* Open the directory for access by SAS */ 
   DirectoryID = dopen(FileRef); 
   if DirectoryID = 0 then 
      abort; 
    /* Get the count of directories and datasets */ 
   MemberCount = dnum(DirectoryID); 
   if MemberCount = 0 then 
      abort; 
    /* Get all of the entry names ... directories and datasets */ 
   do MemberIndex = 1 to MemberCount; 
      pname = dread(DirectoryID, MemberIndex); 
      if missing(pname) then 
         abort; 
       output; 
   end; 

   /* Close the directory */ 
   rc2 = dclose(DirectoryID); 
   if rc2 ^= 0 then 
      abort; 
run; 


data file;
set xxx;
length dname $30.;
var2=scan(pname,2,'_');
if var2 in('DEV','UAT')  then dname=scan(pname,3,'_');
else if var2 = "" then dname="sas";
else dname=scan(pname,2,'_');
if dname='tracking.xlsx'  then dname='Status_tracking';
run;


%macro imp(pname,dname);
proc import datafile="&root.\&_mode.\&_file.\&_Date.\&pname."
out=&dname.
dbms=xlsx replace;
getnames=yes;
run;
%mend imp;

data _null_;
set file;
if dname ^="sas";
rc=dosubl(cats('%imp(',pname,',',dname,')'));
run;
 
proc sql noprint;
select pname into: sasds 
from file
where dname = "sas";
quit;

%put &root.;
%put &_mode.;
%put &_Date.;
%put &sasds.;

libname raw "&root.\&_mode.\&_file.\&_Date.\&sasds.";

***follows to be update 20241118***;
/*	data sasds;set raw.ds1;run;*/
/*	data sasae;set raw.ae;run;*/
/*	data sasex;set raw.ex;run;*/
/*	data saseot;set raw.ds2;run;*/
/*	data sasie;set raw.ie;run;*/
/*	data sasos;set raw.os;run;*/
/*	data sasPicf;set raw.dm0;run;*/
/*	data sasicf;set raw.dm1;run;*/
/*	data saseos;set raw.eos;run;*/
/*	data sassv;set raw.sv1;run;*/
/*	data sasdlt;set raw.dlt;run;*/
/*	data sastr4;set raw.tr4;run;*/
