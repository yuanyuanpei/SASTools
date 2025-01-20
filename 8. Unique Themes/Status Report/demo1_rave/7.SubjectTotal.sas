*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 6.SubjectTotal.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

*********Subject Status Total*********;


proc sql;
*sum of subject;
create table nsub as
select distinct site,sitenumber,count(subject) as nsub
from si
group by sitenumber;

*sum of subjects of screening;
create table nscreen as
select distinct site,sitenumber,count(subject) as nscreen
from subdetail
where DSSFYN = ''
group by sitenumber;

*sum of subjects of enrolled;
create table nenrol as
select distinct sitenumber,count(subject) as nenrol
from dssf
where foldername="Screening" and DSSFYN ='Yes'
group by sitenumber;

*sum of subjects of eot;
create table neot as
select distinct sitenumber,count(subject) as neot
from dseot
where eotdat ^=.
group by sitenumber;

*sum of subjects of eos;
create table neos as
select distinct sitenumber,count(subject) as neos
from dseos
where eosdat ^=.
group by sitenumber;

*sum of subjects of screen failure;
create table nfail as
select distinct sitenumber,count(subject) as nfail
from dssf
where foldername="Screening" and DSSFYN ='No'
group by sitenumber;

***********************;
*count entered pages;
create table nentered as
select distinct StudyEnvironmentSiteNumber  as sitenumber ,count(pagesentered) as entered
from pagestatus
where pagesentered=1
group by StudyEnvironmentSiteNumber;


*count missing page;
create table nmis as
select distinct sitenumber, nall as nmis
from mispgsum
where sitenumber ^= 'Total';
***********************;
***********************;

quit;

/*proc sort data=pgallsdvdetail(where=(instance="Common Pages")) nodupkey out=pgallsdvdetaila;*/
/*by subject instance datapage log;run;*/
/*proc sort data=pgallsdvdetail(where=(instance ^="Common Pages")) nodupkey out=pgallsdvdetailb;*/
/*by subject instance datapage;run;*/
/*data pgallsdvdetail2;set pgallsdvdetaila pgallsdvdetailb;run;*/
/**/
/*proc sort data=pgsdvdetail(where=(instance="Common Pages")) nodupkey out=pgsdvdetaila;*/
/*by subject instance datapage log;run;*/
/*proc sort data=pgsdvdetail(where=(instance ^="Common Pages")) nodupkey out=pgsdvdetailb;*/
/*by subject instance datapage;run;*/
/*data pgsdvdetail2;set pgsdvdetaila pgsdvdetailb;run;*/
data nsdvall;
set nentered;
nsdvall = entered;
keep sitenumber nsdvall;
run;


proc sql;
*count  SDV all page;
/**source change to BO4 report, count by log;*/
/*create table nsdvall as*/
/*select distinct substr(subject,1,2) as sitenumber ,count(requires_verification) as sdvall*/
/*from pgallsdvdetail2*/
/*group by sitenumber*/
/*;*/

*count  notSDVed page;*source need change to BO4 report;
create table nosdved as
select distinct  sitenumber ,count(curr) as nosdved
from pagenosdv
group by sitenumber
;
quit;



proc sql;
***********************;
*count query;
create table Oquery as
select distinct StudyEnvironmentSiteNumber  as sitenumber ,count(name) as open
from querydetail
where QryResponseDateLocalized= . and QryClosedDateLocalized =.
group by StudyEnvironmentSiteNumber;

create table Aquery as
select distinct StudyEnvironmentSiteNumber  as sitenumber ,count(name) as ans
from querydetail
where QryResponseDateLocalized ^=. and QryClosedDateLocalized =.
group by StudyEnvironmentSiteNumber;

create table Cquery as
select distinct StudyEnvironmentSiteNumber  as sitenumber ,count(name) as closed
from querydetail
where QryClosedDateLocalized ^=.
group by StudyEnvironmentSiteNumber;

*count SAE;
create table nsae as
select distinct sitenumber, count(AESER) as nsae
from ae
where sitenumber ^= "" and aeser ='Yes'
group by sitenumber;
quit;

data ds;
infile datalines;
input dname $8.;
datalines;
nsub
nscreen
nenrol
neot
neos
nfail
nentered
nmis
nsdvall
nosdved
oquery
aquery
cquery
nsae
;
run;

%macro srt(a);
proc sort data=&a.;by sitenumber;run;
%mend srt;

data _null_;
set ds;
rc=dosubl(cats('%srt(',dname,')'));
run;


data all;
merge nsub
nscreen
nenrol
neot
neos
nfail
 nentered
nmis
nsdvall
 nosdved
 oquery
 aquery
 cquery
nsae; 
by sitenumber;
run;

data all2;
set all;run;

proc sql;
insert into all(site,sitenumber,nsub,nscreen,nenrol,neot,neos,nfail,entered,nmis,nsdvall,nosdved,open,ans,closed,nsae)
select '' as site, 'Total' as sitenumber,sum(nsub),sum(nscreen) ,sum(nenrol),sum(neot),sum(neos),
sum(nfail),sum(entered),sum(nmis),sum(nsdvall),sum(nosdved),
sum(open),sum(ans),sum(closed),sum(nsae)
from all2;
quit;

data subtotal;
retain site sitenumber nsub nscreen nenrol neot neos nfail entered nmis erate nosdved srate open ans closed nsae;
format erate percent7.1 srate percent7.1;
set all;
array num[*] nsub--nsae;
	do i = 1 to dim(num);
	if num[i]=. then num[i]=0;
	end;
erate=entered/(entered+nmis);
srate=(nsdvall-nosdved)/nsdvall;
keep site sitenumber nsub nscreen nenrol neot neos nfail entered nmis erate nosdved srate open ans closed nsae;
label nsub="#_of_Subjects" nscreen="#_of_Subjects(Screening)" nenrol="#_of_Subjects(Successfully_Enrolled)"
neot= "#_of_Subjects(EOT)" neos="#_of_Subjects(EOS)" nfail="#_of_Subjects(Screen_Failure)" 
entered="#_of_Entered_Pages" nmis="#_of_Missing_Pages" erate="Enter_Rate"  nosdved="#_of_Pages_Not_SDV"
srate="SDV_Rate" open ="#_of_Open_Query" ans="#_of_Answered_Query" closed="#_of_Closed_Query" nsae="#_of_SAE";
run;

data subtotal;
set subtotal;
format TOD date11.;
TOD=today();
label TOD="Run Date";
run;
