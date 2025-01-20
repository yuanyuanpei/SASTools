*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 2.MissingPage.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

****Missing Page Report*********;

********Subject Status*******;
*enrolled: SE \ DSSFYN=1;
*screening: ICF \ ICFDAT ^='';
*screen failed: SE \ DSSFYN=2;
*EOT: EOT \ EOTDAT ^='';
*EOS: EOS \ EOSDAT ^='';
data tmp7b;
set vis;
*if ND ^="1";
keep site sitenumber subject InstanceName visdat_raw ND;
rename instancename=VIS;
run;
proc sort data=tmp7b;by site sitenumber subject;run;
**Status;
data mpr1;
merge tmp1 tmp2 tmp7b tmp8 tmp10;
by site sitenumber subject;
if DSSFYN='No' then Status='Screen Failed';
if DSSFYN='Yes' then do;
	if eosdat_raw ^='' then Status='EOS';
	else if eotdat_raw ^='' then Status='EOT';
	else Status = 'Enrolled';
end; 
if DSSFYN='' then do;
	if icfdat_raw ^='' then Status='Screening';
end;
rename DSSFYG=DosePhase;
drop DSSFYN plan eotrea eosrea  ;*EOSDAT_raw;
run;

**C1D1 visdat;
data mpr2(rename=(visdat_raw=c1d1dat));* mpr3(rename=(visdat_raw=avisdat));
set vis;
/*output mpr3;*/
if foldername='Cycle 1 Day 1';* then output mpr2;
keep site sitenumber subject VISDAT_raw;
run;

%macro sort(a);
proc sort data=&a. ;by site sitenumber subject;run;
%mend sort;
%sort(mpr1);%sort(mpr2);

/*data mpr23;*/
/*merge mpr3 mpr2;*/
/*by site sitenumber subject;*/
/*run;*/

data mpr4;
merge mpr1 mpr2;
by site sitenumber subject;
avis=vis;
rename visdat_raw=avisdat;
run;
*DM Com/2023/7/25:目前受试者最大访视已到cycle 21， 建议缺失访视预设cycle从C20添加到C40;
data fold20;
infile datalines ;
input esca $16. exte $16. ;
datalines;
Screening       Screening
Cycle 0 Day -3              
Cycle 1 Day 1   Cycle 1 Day 1
Cycle 1 Day 8                 
Cycle 1 Day 15  Cycle 1 Day 15
Cycle 1 Day 22               
Cycle 2 Day 1   Cycle 2 Day 1
Cycle 2 Day 15  Cycle 2 Day 15
Cycle 3 Day 1   Cycle 3 Day 1
Cycle 4 Day 1   Cycle 4 Day 1
Cycle 5 Day 1   Cycle 5 Day 1
Cycle 6 Day 1   Cycle 6 Day 1
Cycle 7 Day 1   Cycle 7 Day 1
Cycle 8 Day 1   Cycle 8 Day 1
Cycle 9 Day 1   Cycle 9 Day 1
Cycle 10 Day 1  Cycle 10 Day 1
Cycle 11 Day 1  Cycle 11 Day 1
Cycle 12 Day 1  Cycle 12 Day 1
Cycle 13 Day 1  Cycle 13 Day 1
Cycle 14 Day 1  Cycle 14 Day 1
Cycle 15 Day 1  Cycle 15 Day 1
Cycle 16 Day 1  Cycle 16 Day 1
Cycle 17 Day 1  Cycle 17 Day 1
Cycle 18 Day 1  Cycle 18 Day 1
Cycle 19 Day 1  Cycle 19 Day 1
Cycle 20 Day 1  Cycle 20 Day 1
Cycle 21 Day 1  Cycle 21 Day 1
Cycle 22 Day 1  Cycle 22 Day 1
Cycle 23 Day 1  Cycle 23 Day 1
Cycle 24 Day 1  Cycle 24 Day 1
Cycle 25 Day 1  Cycle 25 Day 1
Cycle 26 Day 1  Cycle 26 Day 1
Cycle 27 Day 1  Cycle 27 Day 1
Cycle 28 Day 1  Cycle 28 Day 1
Cycle 29 Day 1  Cycle 29 Day 1
Cycle 30 Day 1  Cycle 30 Day 1
Cycle 31 Day 1  Cycle 31 Day 1
Cycle 32 Day 1  Cycle 32 Day 1
Cycle 33 Day 1  Cycle 33 Day 1
Cycle 34 Day 1  Cycle 34 Day 1
Cycle 35 Day 1  Cycle 35 Day 1
Cycle 36 Day 1  Cycle 36 Day 1
Cycle 37 Day 1  Cycle 37 Day 1
Cycle 38 Day 1  Cycle 38 Day 1
Cycle 39 Day 1  Cycle 39 Day 1
Cycle 40 Day 1  Cycle 40 Day 1
;
run;

proc sort data=mpr4;by vis;run;
proc sort data=fold20;by esca;run;

data xx;
merge mpr4(rename=(vis=esca)) fold20;
by esca;
if subject ^='';
run;
proc sort data=xx;by  subject site sitenumber;run;
/*data xx2;*/
/*set xx;*/
/*retain tmp1-tmp8;*/
/*if subject ^='' then tmp1=subject; else subject=tmp1;*/
/*if site ^='' then tmp2=site; else site=tmp2;*/
/*if sitenumber ^='' then tmp3=sitenumber; else sitenumber=tmp3;*/
/*if dosephase ^='' then tmp4=dosephase; else dosephase=tmp4;*/
/**if ICFDAT_RAW ^='' then tmp5=ICFDAT_RAW; *else ICFDAT_RAW=tmp5;*/
/**if EOTDAT_RAW ^='' then tmp6=EOTDAT_RAW; *else EOTDAT_RAW=tmp6;*/
/**if status ^='' then tmp7=status; *else status=tmp7;*/
/**if c1d1dat ^='' then tmp8=c1d1dat; *else c1d1dat=tmp8;*/
/*drop tmp:;*/
/*run;*/


data mpr5;
retain site sitenumber subject status icfdat_raw c1d1dat dosephase folder n min max avisdat;
format min date11. max date11. folder $60.;;
set xx;
if dosephase='Dose Extension' then folder=exte;
if dosephase='Dose Escalation' then folder=esca;

if index(folder,'Screening')>0 or index(folder,'End of Treatment')>0 or
index(folder,'Safety Follow-up')>0 or index(folder,'Unscheduled')>0  
    then n=.;
else n=input(substr(folder,7,2),best.);

if  n=. then do; 
min=.;max=.;
end;
else if n=0 then do;
	min=input(c1d1dat,date11.)-3;max=input(c1d1dat,date11.)-3;
end;
else if n=1 then do;
	if folder='Cycle 1 Day 1' then do;min=input(c1d1dat,date11.);max=input(c1d1dat,date11.);end;
	if folder='Cycle 1 Day 8' then do;min=input(c1d1dat,date11.)+7-1;max=input(c1d1dat,date11.)+7+1;end;
	if folder='Cycle 1 Day 15' then do;min=input(c1d1dat,date11.)+14-1;max=input(c1d1dat,date11.)+14+1;end;
	if folder='Cycle 1 Day 22' then do;min=input(c1d1dat,date11.)+21-1;max=input(c1d1dat,date11.)+21+1;end;
end;
else if n=2 then do;
	if folder='Cycle 2 Day 1' then do;min=input(c1d1dat,date11.)+28-3;max=input(c1d1dat,date11.)+28+3;end;
	if folder='Cycle 2 Day 15' then do;min=input(c1d1dat,date11.)+28+14-3;max=input(c1d1dat,date11.)+28+14+3;end;
end;
else do;
	min=input(c1d1dat,date11.) + (n-1)*28 - 3;
	max=input(c1d1dat,date11.) + (n-1)*28 + 3;
end;
drop esca exte avis;
run;

proc sort data=mpr5;by subject folder;run;

data mpr8;
set pagestatus;
if pagesentered = '0';
keep subjectname foldername formname pagesentered;
rename subjectname=subject foldername=folder;
run;

proc sort data=mpr8;by subject folder;run;

data mpr9;
retain site sitenumber subject status icfdat_raw c1d1dat dosephase 
folder n min max avisdat eotdat_raw formname misv curr day;
merge  mpr8 mpr5(in=a);
by  subject folder;
if a=1 and folder ^= '';
format curr yymmddn8.;
curr=today();
*筛败or筛选中的受试者;
if status in ('Screen Failed', 'Screening') then do; 
	if folder ^= 'Screening' then delete;
	if folder= 'Screening' and 
		formname not in ('Visit Date',' Informed Consent Form','Demographics','Inclusion/Exclusion Criteria','Subject Enrollment') then delete;
	if avisdat ^='' then do; misv='N';day=curr-input(avisdat,date11.);end;
end;
*入组，EOT EOS的受试者;
else do;
	*若actual visit date不为空，则misv='N';
	if avisdat ^='' then do; 
		misv='N';day=curr-input(avisdat,date11.);

	end;
	*若actual visit date为空，则进一步判断;
	else do;
		if eotdat_raw ^='' and max<input(eotdat_raw,date11.) and ND ^= "1"
		or eotdat_raw ='' and max<curr and ND ^= "1"
		then do;misv='Y';day=curr-max;end;
		else do;misv='';day=.;end;
	end;
end;

if index(folder,'Unscheduled')>0 then delete;

keep site sitenumber subject status icfdat_raw c1d1dat dosephase 
folder n min max avisdat ND eotdat_raw formname misv curr day;
label subject='Subject_ID' status='Subject_Status' icfdat_raw ='ICF_Date' c1d1dat='C1D1_Visit_Date' dosephase ='Dose_Phase'
folder='Planned_Folder_Name'  min ='Planned_Min_Visit_Date' max='Planned_Max_Visit_Date' avisdat='Actual_Visit_Date' eotdat_raw='EOT_Date' 
formname='Missing_Page_Name' misv='Missing_Visit(YN)' curr='Current_Date' day='Delay_Aging';

run;

proc sort data=mpr9;by subject n;run;

*****单独判断访视是否缺失 20240325 by pyy*************************************************;
*actual;
data mpr4b;
set mpr4;
folder=avis;
keep subject   avis avisdat folder nd;
run;

*plan;
proc sql;
create table xx01 as
select distinct mpr4.subject,fold20.esca as folder from mpr4,fold20
where mpr4.dosephase = "Dose Escalation";

create table xx02 as
select distinct mpr4.subject,fold20.exte as folder from mpr4,fold20
where mpr4.dosephase = "Dose Extension" and fold20.exte ^= "";
quit;
data xx00;
set xx01 xx02;
if index(folder,'Screening')>0 or index(folder,'End of Treatment')>0 or
index(folder,'Safety Follow-up')>0 or index(folder,'Unscheduled')>0  
    then nplan=.;
else nplan=input(substr(folder,7,2),best.);

run;

proc sort data=xx00;by subject folder;run;
proc sort data=mpr4b;by subject folder;run;

data misv_pl_ac;
merge xx00(in=pl) mpr4b(in=ac);
by subject folder;
if pl then flag="planY";
if ac then flag="actY";
run;
*subject message;
data mpr4c;
set mpr4;
keep site sitenumber subject icfdat_raw dosephase c1d1dat eotdat_raw eosdat_raw status;
run;

proc sort data=misv_pl_ac;by subject;run;
proc sort data=mpr4c nodupkey;by subject;run;

data misv_judge ;
merge misv_pl_ac(in=a) mpr4c;
by subject ;*if a;
curr=today();
format curr yymmddn8.;

*plan visit的访视窗：;
if  nplan=. then delete;
else if nplan=0 then do;
	min=input(c1d1dat,date11.)-3;max=input(c1d1dat,date11.)-3;
end;
else if nplan=1 then do;
	if folder='Cycle 1 Day 1' then do;min=input(c1d1dat,date11.);max=input(c1d1dat,date11.);end;
	if folder='Cycle 1 Day 8' then do;min=input(c1d1dat,date11.)+7-1;max=input(c1d1dat,date11.)+7+1;end;
	if folder='Cycle 1 Day 15' then do;min=input(c1d1dat,date11.)+14-1;max=input(c1d1dat,date11.)+14+1;end;
	if folder='Cycle 1 Day 22' then do;min=input(c1d1dat,date11.)+21-1;max=input(c1d1dat,date11.)+21+1;end;
end;
else if nplan=2 then do;
	if folder='Cycle 2 Day 1' then do;min=input(c1d1dat,date11.)+28-3;max=input(c1d1dat,date11.)+28+3;end;
	if folder='Cycle 2 Day 15' then do;min=input(c1d1dat,date11.)+28+14-3;max=input(c1d1dat,date11.)+28+14+3;end;
end;
else do;
	min=input(c1d1dat,date11.) + (nplan-1)*28 - 3;
	max=input(c1d1dat,date11.) + (nplan-1)*28 + 3;
end;
*判断是否为缺失访视：;
if c1d1dat ^= "";
run;
data misv_jd;
set misv_judge;
*筛败or筛选中的受试者;
if status in ('Screen Failed', 'Screening') then do; 
	if folder ^= 'Screening' then delete;
	if folder= 'Screening' and 
		formname not in ('Visit Date',' Informed Consent Form','Demographics','Inclusion/Exclusion Criteria','Subject Enrollment') then delete;
	if avisdat ^='' then do; misv='N'; end;
end;
*入组，EOT EOS的受试者;
else do;
	*若actual visit date不为空，则misv='N';
	if avisdat ^='' then do; 
		misv='N';day=curr-input(avisdat,date11.);

	end;
	*若actual visit date为空，则进一步判断;
	else do;
		if eotdat_raw ^='' and max<input(eotdat_raw,date11.) and max > 0 and ND ^= "1"
		or eotdat_raw ='' and max<curr and max > 0 and ND ^= "1"
		then do;misv='Y';day=curr-max;end;
		else do;misv='';day=.;end;
	end;
end;

if index(folder,'Unscheduled') >0 then delete;
*已经EOS或EOT了的，无需再计算plan TA;

if input(c1d1dat,date11.)+7*nplan-7 > input(eosdat_raw,date11.) and ^missing(eosdat_raw) then misv="N";
if input(c1d1dat,date11.)+7*nplan-7 > input(eotdat_raw,date11.) and ^missing(eotdat_raw) then misv="N";

if misv="Y" then output;
n=nplan;
formname="";
keep site sitenumber subject status icfdat_raw c1d1dat dosephase 
folder n min max avis avisdat ND eotdat_raw formname misv curr day;
label subject='Subject_ID' status='Subject_Status' icfdat_raw ='ICF_Date' c1d1dat='C1D1_Visit_Date' dosephase ='Dose_Phase'
folder='Planned_Folder_Name'  min ='Planned_Min_Visit_Date' max='Planned_Max_Visit_Date' avisdat='Actual_Visit_Date' eotdat_raw='EOT_Date' 
formname='Missing_Page_Name' misv='Missing_Visit(YN)' curr='Current_Date' day='Delay_Aging';

run;

********缺失页和缺失访视合并*********************************************;
data misspage;
set mpr9 misv_jd;
if misv='Y' then output;
if misv='N' and formname ^='' then output;
drop n avis;
run;
proc sort data = misspage;by subject ;run;
data raw.misspage misspage;
	retain site sitenumber subject status icfdat_raw c1d1dat dosephase 
	folder   min max avisdat ND eotdat_raw formname misv curr day tod;
	set misspage;
	TOD=&date.;
	label TOD="Run Date";
run;
%put &date.;
/*proc export data=misspage outfile = "F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Prd\Output\testmisv2.xlsx"*/
/*dbms=xlsx replace label;*/
/*run;*/
