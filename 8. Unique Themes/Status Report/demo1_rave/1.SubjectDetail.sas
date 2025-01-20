*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 1.SubjectDetail.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;


**************Subject detail*********;
*03010受试者没有填写任何表，但状态也为筛选中。该受试者信息需从SI表中抓。20230527 by PYY;
data tmp0;
set si;
keep site sitenumber subject;
run;

data tmp1;
set dssf;
plan=compress(sfdespd||sfdexc);
keep site sitenumber subject  DSSFYN DSSFYG plan;
run;
**ICF;
data tmp2ic;
set dsic;
keep site sitenumber subject  ICFDAT_raw;
run;
**Exploratory ICF;*PM的需求，by yypei, 2023/6/13;
data tmp2eic;
set dseic;
keep site sitenumber subject  EICFDAT_raw;
run;
proc sort data=tmp2ic;by site sitenumber subject;run;
proc sort data=tmp2eic;by site sitenumber subject;run;
data tmp2;
merge tmp2ic tmp2eic;
by site sitenumber subject;
run;

/*proc contents data=raw.mhdiag;run;*/

/*proc datasets library=raw;*/
/*    modify mhdiag/correctencoding=gb2312;*/
/*quit;*/

/*data test;*/
/*set raw.mhdiag;*/
/*run;*/

**MHDIAG;
data tmp3;
set MHDIAG;
keep site sitenumber subject  DIAGTYP;
run;
**DLT;
data tmp4;
set DLT;
keep site sitenumber subject  DLTYN1;
run;

**AE;
data tmp5;
set AE;
keep site sitenumber subject DLTYN;
run;

**EX;
proc sort data=ex; by subject exstdat ;run;

data tmp6f tmp6l;
*retain site sitenumber subject fstex fenex lstex lenex;
set ex;
by subject exstdat;
if first.subject then output tmp6f;
if last.subject then output tmp6l;*(rename=(exstdat_raw=lstex exendat_raw=lenex));

*if fstex ='' and fenex='' and lstex='' and lenex='' then delete;
*if lstex='' then delete;
keep site sitenumber subject exstdat_raw exendat_raw;
run;

proc sort data=tmp6f(rename=(exstdat_raw=fstex exendat_raw=fenex));by site sitenumber subject;run;
proc sort data=tmp6l(rename=(exstdat_raw=lstex exendat_raw=lenex));by site sitenumber subject;run;

data tmp6;
merge tmp6f tmp6l;
by site sitenumber subject;
run;

**VISDAT;
proc sort data=VIS; by subject descending visdat;run;

data tmp7;
set vis;
by subject descending visdat;
if first.subject;
keep site sitenumber subject InstanceName visdat_raw;
rename instancename=VIS;
run;
**EOT;
data tmp8;
set dseot;
keep site sitenumber subject  eotdat_raw eotrea;
run;

**OS;
/*data tmp9;*/
/*set dssur;*/
/*keep site sitenumber subject sfudat sfudat_raw sfusta;*/
/*run;*/
*20240531 by pyy:mark:latest os date取subject所有sfudate的最大日期;
proc sql;
create table tmp9(drop=sfudat1) as
select site,sitenumber,subject,max(sfudat) as sfudat1, sfudat_raw,sfusta
from dssur
group by subject
having sfudat = sfudat1
order by subject;
quit;

**EOS;
data tmp10;
set dseos;
keep site sitenumber subject eosdat_raw eosrea;
run;

%macro sort(a);
proc sort data=&a.;by site sitenumber subject;run;
%mend sort;
%sort(tmp0);
%sort(tmp1);%sort(tmp2);%sort(tmp3);%sort(tmp4);%sort(tmp5);
%sort(tmp6);%sort(tmp7);%sort(tmp8);%sort(tmp9);%sort(tmp10);

data subdetail;
retain site sitenumber subject DSSFYN DSSFYG plan 
ICFDAT_RAW EICFDAT_RAW  DIAGTYP DLTYN1 DLTYN fstex lenex VIS VISDAT_RAW EOTDAT_RAW EOTREA dur;
	merge tmp0-tmp10;
	by site sitenumber subject;
	curr=today();
	if eotdat_raw= "" then do;
	dur=curr-input(fstex,date11.);
	end;
	else do;
	dur=input(eotdat_raw,date11.)-input(fstex,date11.);
	end;


label DSSFYN = "Enroll_or_not?" DSSFYG="Dose_Phase" plan="Plan_Dose_or_Cohort"
ICFDAT_RAW="ICF_Date" EICFDAT_RAW="Exploratory_ICF_Date" DLTYN="Any_DLT_Event?(Y/N)" fstex="First_Dose_Start_Date" fenex="First_Dose_Stop_Date"
lstex="Latest_Dose_Start_Date" lenex="Latest_Dose_Stop_Date"  VIS="Latest_Visit"
VISDAT_RAW="Latest_Visit_Date" EOTDAT_RAW="EOT_Date" dur = "Duration_of_Dosing" SFUDAT_RAW="Latest_OS_Date"
EOSDAT_RAW="EOS_Date" ;
drop fenex lstex curr;
run;

data subdetail;
set subdetail;
format TOD date11.;
TOD=today();
label TOD="Run Date";
run;

proc sort data=subdetail nodupkey;by  subject;run;
