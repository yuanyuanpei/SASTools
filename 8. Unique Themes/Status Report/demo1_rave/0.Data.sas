*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 0.Data.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

****Read data***;

**����SAS on demand���ݼ��ļ��У���pgstatus.xlsx,qryaging.xlsx,qrydetail.xlsx;

**get libname old;
filename xxx2 pipe "dir ""&root.\&_mode.\Data\&_Ldate."" /b";
data file2;
infile xxx2 truncover;
input @1 filename $60.;
if index(filename,'2021_760_00CH1')>0; 
run;
proc sql noprint;
select filename into: fnameold from file2;
quit;

libname old "&root.\&_mode.\Data\&_Ldate.\&fnameold.";
**old;

**get libname raw(new);
filename xxx pipe "dir ""&root.\&_mode.\Data\&date."" /b";
data file1;
infile xxx truncover;
input @1 filename $60.;
if index(filename,'Tracking')>0 then dname="StatusTracking";
else if index(filename,'user_list')>0 then dname="UserList";
else if index(filename,'BO4.2')>0 then dname="PGSDV";
else if index(filename,'2021_760_00CH1')>0 then dname="EDC";

else dname=scan(scan(filename,2,'-'),1,' ');
run;
proc sql noprint;
select filename,dname,count(filename) into
:fnames separated by "#",
:dnames separated by "#",
:count
from file1;
quit;

%put &fnames.;%put &dnames.;%put &count.;

%macro imports;

%do i=1 %to &count;
%let fname=%scan(&fnames,&i,%str(#));%put &fname.;
%let dname=%scan(&dnames,&i,%str(#));%put &dname.;

%if &dname. = %str(EDC) %then %do;
	libname raw "&root.\&_mode.\Data\&date.\&fname.";
%end;
%else %if &dname.= %str(StatusTracking)  %then %do;
	proc import datafile="&root.\&_mode.\Data\&date.\&fname."
	out=&dname. dbms=xlsx
	replace;
	getnames=NO;
	run;
%end;
%else %do;
	proc import datafile="&root.\&_mode.\Data\&date.\&fname."
	out=&dname. dbms=xlsx
	replace;
	getnames=yes;
/*	delimiter='09'x;*/
	run;
%end;

%end;
%mend imports;
%imports


proc datasets library=raw;
    modify mhdiag/correctencoding=utf8;
quit;

data querydetail(rename=(StudyEnvironmentSiteNumber1=StudyEnvironmentSiteNumber subjectname1=subjectname));
format SubjectName1 $5. StudyEnvironmentSiteNumber1 $2.;
set querydetail;
if StudyEnvironmentSiteNumber=1 then StudyEnvironmentSiteNumber1='01';
if StudyEnvironmentSiteNumber=2 then StudyEnvironmentSiteNumber1='02';
if StudyEnvironmentSiteNumber=3 then StudyEnvironmentSiteNumber1='03';
if StudyEnvironmentSiteNumber=4 then StudyEnvironmentSiteNumber1='04';
if StudyEnvironmentSiteNumber=5 then StudyEnvironmentSiteNumber1='05';

if StudyEnvironmentSiteNumber=7 then StudyEnvironmentSiteNumber1='07';
if StudyEnvironmentSiteNumber=8 then StudyEnvironmentSiteNumber1='08';
if StudyEnvironmentSiteNumber=9 then StudyEnvironmentSiteNumber1='09';
if StudyEnvironmentSiteNumber=10 then StudyEnvironmentSiteNumber1='10';
if StudyEnvironmentSiteNumber=11 then StudyEnvironmentSiteNumber1='11';
if StudyEnvironmentSiteNumber=12 then StudyEnvironmentSiteNumber1='12';
if StudyEnvironmentSiteNumber=14 then StudyEnvironmentSiteNumber1='14';
if StudyEnvironmentSiteNumber=16 then StudyEnvironmentSiteNumber1='16';

if StudyEnvironmentSiteNumber=17 then StudyEnvironmentSiteNumber1='17';
if StudyEnvironmentSiteNumber=19 then StudyEnvironmentSiteNumber1='19'; 
if StudyEnvironmentSiteNumber=21 then StudyEnvironmentSiteNumber1='21'; 
if StudyEnvironmentSiteNumber=23 then StudyEnvironmentSiteNumber1='23';
if StudyEnvironmentSiteNumber=25 then StudyEnvironmentSiteNumber1='25';

if StudyEnvironmentSiteNumber=26 then StudyEnvironmentSiteNumber1='26';
if StudyEnvironmentSiteNumber=28 then StudyEnvironmentSiteNumber1='28';
if StudyEnvironmentSiteNumber=30 then StudyEnvironmentSiteNumber1='30'; 
if StudyEnvironmentSiteNumber=32 then StudyEnvironmentSiteNumber1='32'; 

*n=put(subjectname,5.);
subjectName1 = put(subjectname,z5.);
/*if substr(StudyEnvironmentSiteNumber1,1,1) = "1" then subjectName1 = put(subjectname,5.);*/
/*if substr(StudyEnvironmentSiteNumber1,1,1) = "0" then subjectName1 = compress('0'||put(subjectname,4.));*/

*SubjectName1=compress('0'||n);
drop   StudyEnvironmentSiteNumber subjectname;
run;

data pagestatus(rename=(StudyEnvironmentSiteNumber1=StudyEnvironmentSiteNumber subjectname1=subjectname));
set pagestatus;
if StudyEnvironmentSiteNumber=1 then StudyEnvironmentSiteNumber1='01';
if StudyEnvironmentSiteNumber=2 then StudyEnvironmentSiteNumber1='02';
if StudyEnvironmentSiteNumber=3 then StudyEnvironmentSiteNumber1='03';
if StudyEnvironmentSiteNumber=4 then StudyEnvironmentSiteNumber1='04';
if StudyEnvironmentSiteNumber=5 then StudyEnvironmentSiteNumber1='05';
if StudyEnvironmentSiteNumber=7 then StudyEnvironmentSiteNumber1='07';
if StudyEnvironmentSiteNumber=8 then StudyEnvironmentSiteNumber1='08';
if StudyEnvironmentSiteNumber=9 then StudyEnvironmentSiteNumber1='09';
if StudyEnvironmentSiteNumber=10 then StudyEnvironmentSiteNumber1='10';

if StudyEnvironmentSiteNumber=11 then StudyEnvironmentSiteNumber1='11';
if StudyEnvironmentSiteNumber=12 then StudyEnvironmentSiteNumber1='12';
if StudyEnvironmentSiteNumber=14 then StudyEnvironmentSiteNumber1='14';
if StudyEnvironmentSiteNumber=16 then StudyEnvironmentSiteNumber1='16';

if StudyEnvironmentSiteNumber=17 then StudyEnvironmentSiteNumber1='17';
if StudyEnvironmentSiteNumber=19 then StudyEnvironmentSiteNumber1='19';
if StudyEnvironmentSiteNumber=21 then StudyEnvironmentSiteNumber1='21'; 
if StudyEnvironmentSiteNumber=23 then StudyEnvironmentSiteNumber1='23';
if StudyEnvironmentSiteNumber=25 then StudyEnvironmentSiteNumber1='25';

if StudyEnvironmentSiteNumber=26 then StudyEnvironmentSiteNumber1='26';
if StudyEnvironmentSiteNumber=28 then StudyEnvironmentSiteNumber1='28';
if StudyEnvironmentSiteNumber=30 then StudyEnvironmentSiteNumber1='30'; 
if StudyEnvironmentSiteNumber=32 then StudyEnvironmentSiteNumber1='32'; 
subjectName1 = put(subjectname,z5.);
/*if substr(StudyEnvironmentSiteNumber1,1,1) = "1" then subjectName1 = put(subjectname,5.);*/
/*if substr(StudyEnvironmentSiteNumber1,1,1) = "0" then subjectName1 = compress('0'||put(subjectname,4.));*/

drop   StudyEnvironmentSiteNumber subjectname;
run;

data ds;
infile datalines;
input dname $8.;
datalines;
SI
AE
DLT
DSIC
DSEIC
DSSF
DSEOS
DSEOT
EX
MHDIAG
DSSUR
TUVIS
TUTL
VISCYL
VIS
;
run;

%macro ds(a);
data &a;
set raw.&a;
if SiteNumber='RJJT' then SiteNumber='01';
if SiteNumber='SCHA' then SiteNumber='02';
if SiteNumber='TJHZ' then SiteNumber='03';
if SiteNumber='CQUC' then SiteNumber='04';
if SiteNumber='HNC' then SiteNumber='05';
if SiteNumber='GXMC' then SiteNumber='07';
if SiteNumber='XMAH' then SiteNumber='08';
if SiteNumber='SXBH' then SiteNumber='09';
if SiteNumber='SYUC' then SiteNumber='10';
if SiteNumber='JLCH' then SiteNumber='11';
if SiteNumber='JXTH' then SiteNumber='12';
if SiteNumber='CMUA' then SiteNumber='14';
if SiteNumber='HACH' then SiteNumber='16';
if SiteNumber='DLSA' then SiteNumber='17';
if SiteNumber='CDMH' then SiteNumber='19';
if SiteNumber='QLSD' then SiteNumber='21';
if SiteNumber='HPCZ' then SiteNumber='23';
if SiteNumber='BJCY' then SiteNumber='25';
if SiteNumber='WCSC' then SiteNumber='26';
if SiteNumber='HZFP' then SiteNumber='28';
if SiteNumber='CZPH' then SiteNumber='30';
if SiteNumber='ZZFA' then SiteNumber='32';
run;
%mend ds;

data _null_;
	set ds;
	rc=dosubl(cats('%ds(',dname,')'));
run;
