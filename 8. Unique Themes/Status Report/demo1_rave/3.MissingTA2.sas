*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 3.MissingTA.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

*1.自定义plan visit和plan form，并用笛卡尔相乘，得A;

data pweek10;
infile datalines;
input code 2. pweek $55. ;
datalines;
1 Tumor Assessment Week8
2 Tumor Assessment Week16
3 Tumor Assessment Week24
4 Tumor Assessment Week36
5 Tumor Assessment Week48
6 Tumor Assessment Week60
7 Tumor Assessment Week72
8 Tumor Assessment Week84
9 Tumor Assessment Week96
10Tumor Assessment Week120
;
run;
*length must be the same!;
data pform16;
infile datalines;
input code2 2. pform $58. ;
datalines;
1 Tumor Assessment Visit
2 Bone Marrow Aspirate
6 New Lesion Assessment
3 Bone Marrow Biopsy
8 Constitutional Symptoms
4 Target Lesion Assessment
5 Non-Target Lesion Assessment
7 Immunofixation Electrophoresis
9 CLL Bone Marrow Assessment
10Spleen and Liver Assessment-Post Baseline
11Overall Response-CT
12PET-CT Evaluation
13Overall Response Evaluation-Cheson 2014
14Overall Response Evaluation-IWCLL
15Overall Response Evaluation-IWWM-7
16Quantitative Serum Immunoglobulin Levels
;
run;

proc sql;
create table plan as
select pweek10.*,pform16.* from pweek10,pform16;
quit;

*2.SI表中的subjid与1.中的结果A用笛卡尔相乘，得B;

proc sql;
create table subj_plan as 
select si.subject,plan.* from si,plan;
quit;

*4.从数据集中拼表，得到每个受试者的ICFDATE,C1D1DAT,EOTDATE,受试者状态，DIAG选项，TAYN和TAVISIT，为E;

data c1d1;
set vis;
if folder="C1D1";
run;

proc sort data=dsic;by subject;run;
proc sort data=mhdiag;by subject;run;
proc sort data=c1d1;by subject;run;
proc sort data=dseot;by subject;run;
proc sort data=dseos;by subject;run;
proc sort data=tuvis;by subject;run;
proc sort data=mpr1;by subject;run;

data sbinfo;
merge dsic(in=a keep=site sitenumber subject icfdat_raw)
      mhdiag(keep=subject diacat) 
      c1d1(keep=subject visdat_raw) 
      dseot(keep=subject eotdat_raw)  
	  dseos(keep=subject eosdat_raw) 
      mpr1(keep=subject status) ;
by subject;
if a;
rename visdat_raw=C1D1DAT;
run;

*合并subjinfo 和sb_plan;
proc sort data=sbinfo nodupkey;by _all_;run;
proc sort data=subj_plan;by subject;run;

data  sbinfo_plan;
merge sbinfo subj_plan;
by subject;
run;

*3.pgstatus中，保留subjid，avis,aform，是否entered，得C. B merge C, by subjid vis form得D。
 此时D就包含了受试者的理论上所有的TAform，和实际上这些form是否entered;
data  pgss;
set pagestatus;
if index(foldername,'Tumor Assessment')>0;
pform=formname;
pweek=foldername;
keep subjectname foldername formname pagesentered pweek pform;
rename subjectname=subject;
run;

proc sort data=pgss;by subject pweek pform;run;
proc sort data=sbinfo_plan;by subject pweek pform;run;

data  sb_plan_pg;
merge sbinfo_plan(in=a) pgss(in=b);
by subject pweek pform;
if a then flag1="planY";
if b then flag2="actY";
run;

/*proc sql;*/
/*create table sb_plan_pg2 as*/
/*select a.*,b.foldername,b.formname,b.pagesentered from*/
/*sbinfo_plan as a full join pgss as b*/
/*on trim(a.subject)=trim(b.subject) */
/*and trim(a.pweek)=trim(b.foldername) */
/*and trim(a.pform)=trim(b.formname);*/
/*quit;*/

proc sort data=sb_plan_pg;by subject code code2 ;run;

/*sb_plan_pg跟tuvis merge，保留tuvis的TUPERF变量;*/
proc sql;
create table sb_plan_pg_tuvis as
select sb_plan_pg.*,tuvis.TUPERF
from sb_plan_pg as a left join tuvis as b
on a.subject=b.subject and a.pweek=b.instancename

;
quit;
proc sort data=sb_plan_pg_tuvis;by subject pweek;run;
*6.执行判断：
a.缺失访视：pvisit, pform(结合DIAG判断)
b.非缺失访视：enter=0;

data misV;
set sb_plan_pg_tuvis;
curr=today();
format curr yymmddn8.;

n=scan(scan(pweek,-1),1,"Week");
/*if input(n,best.) ^=.;*/
* keep only needed visit;
if (curr-input(c1d1dat,date11.))/7-2>n;

*Judge missing visit;
if foldername="" then misv="Yes";else misv="No";
*已经EOS或EOT了的，无需再计算plan TA;
if input(c1d1dat,date11.)+7*n-7 > input(eosdat_raw,date11.) and ^missing(eosdat_raw) then misv="No";
if input(c1d1dat,date11.)+7*n-7 > input(eotdat_raw,date11.) and ^missing(eotdat_raw) then misv="No";
*TUVIS中TUPERF=No的，也不算missing visit;
if TUPERF="No" then misv="No";
*hard coding for Version1.0;
	if subject ="01001" and code in (1,3) then misv="No";
	if subject ="03001" and code in (1,2) then misv="No";
	if subject ="03002" and code =1  then misv="No";

drop flag1 flag2 ;
run;

data misform;
set misv;

*从全部的TAform中根据DIAG的选项删掉不需要的form;
if DIACAT="IWCLL" and code2 in (7,11,13,15,16) then delete; 
if DIACAT="Cheson 2014" and code2 in (7,8,9,14,15,16) then delete; 
if DIACAT="IWWM-7" and code2 in (9,14,11,13) then delete;

*然后判断missing form;
if misv="No" and pagesentered=0 then misform=formname;
if misv="Yes" then do;
misform=pform ; day=curr-(input(c1d1dat,date11.)+7*n+7);
end;


run;

data mista;
set misform;
if misform ^="" then misf="Yes" ; else misf="No";
label pweek="Planned_TA_Visit" pform="Planned_TA_Form"  curr="Current_Date" 
misv="Missing_Visit" misf="Missing_Page"
Foldername="Actual_TA_Visit" day="Delay_Aging"
formname="Actual_TA_Form";
/*if subject="03004";*/
drop code code2 pagesentered misform n;
run;

proc sort data=mista;by subject;run;

data raw.mista mista;
set mista;
*format TOD yymmddn8.;
TOD=&date.;
label TOD="Run Date";
run;

