*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 7.Remains.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

****AE Listing****;

Data aelist;
retain site sitenumber subject foldername datapagename recordposition aeyn aeterm aeterm_pt
aestdat_raw aeongo aeendat_raw dltyn aeitoxgr aehtoxgr aedat_raw
AEREL	AEACN	AEOUT	AESER	SAEDAT_raw	SAE01	SAE02	SAE03	SAE04	SAE05	SAE06	AEACN2;

set ae;
keep site sitenumber subject foldername datapagename recordposition aeyn aeterm aeterm_pt
aestdat_raw aeongo aeendat_raw dltyn aeitoxgr aehtoxgr aedat_raw
AEREL	AEACN	AEOUT	AESER	SAEDAT_raw	SAE01	SAE02	SAE03	SAE04	SAE05	SAE06	AEACN2;
run;

data raw.aelist outaelist;
set aelist;
/*format TOD date11.;*/
TOD=&date.;
label TOD="Run Date";
run;


****Pages Not SDVed****;
*20230515 updated by PYY: source changed to BO4 report (with logline in details);

data pgsdvdetail pgallsdvdetail;
length subject $5.;
set pgsdv;
subject = put(subject_name,z5.);
*format dt_last yymmdd10.;
dt_last=Last_Data_Point_Entered_Date;
rename Instance_Name=Instance Data_Page_Name=DataPage Log__=log;
if requires_verification in (1,0) then output pgallsdvdetail;*所有需要做SDV的。BO4导出的逻辑已筛选is touched =1;
if requires_verification=1 then output pgsdvdetail;*需要做SDV但未做的;
drop subject_name;
run;







*20240418 by pyy:common pages里的form，每个logline也算作一页计数Notsdv;
proc sql;
create table pgsdvdet1 as
select distinct subject,instance,datapage,log,max(dt_last) as lastdp format=date11. 
from pgsdvdetail
where instance = "Common Pages"
group by subject,instance,datapage,log;

create table pgsdvdet2 as
select distinct subject,instance,datapage,log,max(dt_last) as lastdp format=date11. 
from pgsdvdetail
where instance ^= "Common Pages"
group by subject,instance,datapage;
quit;
proc sort data=pgsdvdet1 nodupkey;by subject instance datapage log;run;
proc sort data=pgsdvdet2 nodupkey;by subject instance datapage;run;
proc sql;
create table  pgsdvnew as
select * from pgsdvdet1
union
select * from pgsdvdet2
;
quit;






*20240408 by mx: vis:基于DCO需求，更新vis中的visidat逻辑;
**1*******;
data xxtutl;
set raw.tutl;
if recordposition=1;
keep subject instancename datapagename recordposition tlbdat_raw;
rename   tlbdat_raw=date_raw;
run;

%macro group1(ds,dsdp);
data xx&ds.;
set raw.&ds.;
keep subject instancename  datapagename recordposition &dsdp._raw;
rename &dsdp._raw=date_raw;
run;
%mend group1;
%group1(pc5,pcstdat1)
%group1(dseic,eicfdat)
%group1(pebrief,pedat)
%group1(dd,dthdat)
%group1(dseos,eosdat)
%group1(dseot,eotdat)

data xxpebrief;*经查matrix#Full CRF,PEBRIEF domain在不止一个访视里有，需限定;
set xxpebrief;
if index(instancename,"PFS Follow-up")>0;
run;

**Group1***;
data xxgroup1;
set xxtutl xxpc5 xxdseic xxdd xxdseos xxdseot xxpebrief;
run;


%macro group2(ds,dsdp);
data xx&ds.;
set raw.&ds.;
keep subject instancename datapagename recordposition &dsdp._raw;
rename &dsdp._raw=date_raw;
run;
%mend group2;
%group2(dsric,ricfdat)
%group2(ex,exstdat)
%group2(ae,aestdat)
%group2(cm,cmstdat)
%group2(pr,cpstdat)
%group2(dssur,sfudat)
%group2(prsub,prdat)
%group2(prrtsub,prstdat)
%group2(cmsub,tustdat)
**Group2***;
data xxgroup2;
set xxdsric xxex xxae xxcm  xxpr xxdssur xxprsub xxprrtsub xxcmsub;
run;

data xxgroup0;
set vis;
keep subject instancename datapagename recordposition visdat_Raw;
rename visdat_raw = date_raw;
run;

data dcodate1;
set xxgroup0 xxgroup1;* xxgroup2;
keep subject instancename date_Raw;
rename instancename=instance;
run;
proc sort data=pgsdvnew;by subject instance;run;
proc sort data=dcodate1;by subject instance;run;
data pgfinal_1;
merge pgsdvnew(in=a) dcodate1;
by subject instance;
if a;
/*if subject = "05013";*/
run;


data dcodate2;
set xxgroup2;
rename instancename=instance  datapagename=datapage
	recordposition=log date_raw=date_raw2;
run;

proc sort data=pgfinal_1;by subject instance datapage log;run;
proc sort data=dcodate2;by subject instance  datapage log;run;
data pgfinal;
merge pgfinal_1(in=a) dcodate2;
by subject instance datapage log;
if a;
visdat_raw = coalescec (date_raw,date_raw2);
format curr yymmdd8.;
curr=today();
day=curr - lastdp;
drop date_raw date_raw2;
run;

/**/
/*proc sql;*/
/*create table pgfinal1 as*/
/*select a.*,b.date_raw,today() as curr format=yymmdd8., today()-lastdp as day*/
/*from pgsdvnew as a left join dcodate as b*/
/*on a.subject=b.subject and a.instance=b.instancename;* and a.datapage=b.datapagename and (a.log - b.recordposition) = 0;*/
/**/
/*quit;*/

proc sort data=pgfinal;by subject;run;
proc sort data=si;by subject;run;


data raw.PageNoSDV pagenosdv;
retain site sitenumber subject instance datapage log lastdp visdat_raw curr day;
merge pgfinal(in=a) si;
by subject;
if a;
/*curr=today();*/
/*if visdat_raw ^='' then day=curr-input(visdat_raw,date11.);*/
/*day=curr-lastdp;*/
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
*format TOD date11.;
TOD=&date.;
label TOD="Run Date";

keep  site sitenumber subject instance datapage log lastdp visdat_raw curr day tod;
label subject="Subject_ID" instance="Folder_Name" datapage="Pages_Not_SDV"
log="log_line" lastdp= "Page_Last_Modify_Date"
visdat_raw="Actual_Start_Date" curr="Run_Date" day="SDV_Delay_Aging";
run;

proc sort data=pagenosdv   nodupkey;by _all_;run;


