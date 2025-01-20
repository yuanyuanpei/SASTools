

*20241127 Page Not SDV Report ************************;


proc  sql;
create table actual_tu as
select distinct usubjid, foldername, fieldvalue as actual_tu
from page2
where foldername='肿瘤评估' and pagename='肿瘤评估-靶病灶'
	and fieldname ='TUDAT' and logline='1';

quit;

data actual_visdt_notu;
set page2;

if pagename = '访视日期' and fieldname = 'SVSTDAT' 
then actual = fieldvalue;

if foldername='治疗结束' and pagename='治疗结束（EOT）'
and fieldname ='DSENDAT' 
then actual = fieldvalue;
*;
if foldername='生存随访' and pagename='生存随访'
and fieldname ='DSDAT' 
then actual = fieldvalue;

if foldername='生存随访' and pagename='后续抗肿瘤治疗'
and fieldname ='CMSTDAT1' 
then actual = fieldvalue;

if foldername='生存随访' and pagename='后续抗肿瘤放疗'
and fieldname ='PRSTDAT' 
then actual = fieldvalue;

if foldername='生存随访' and pagename='后续抗肿瘤手术/操作'
and fieldname ='PRSGDAT' 
then actual = fieldvalue;
*;
if foldername='共同页' and pagename='HMPL-760研究用药'
and fieldname ='EXSTDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='R-GemOx利妥昔单抗给药'
and fieldname ='EX2STDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='R-GemOx吉西他滨给药'
and fieldname ='EX3STDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='R-GemOx奥沙利铂给药'
and fieldname ='EX4STDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='不良事件'
and fieldname ='AESTDAT1' 
then actual = fieldvalue;

if foldername='共同页' and pagename='既往或伴随药物治疗'
and fieldname ='CMSTDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='既往或伴随非药物治疗'
and fieldname ='PRSTDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='血液样本采集'
and fieldname ='BLDDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='肿瘤组织采集'
and fieldname ='TUMDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='其它实验室检查'
and fieldname ='LBDAT' 
then actual = fieldvalue;

if foldername='共同页' and pagename='死亡'
and fieldname ='DDDAT' 
then actual = fieldvalue;

*;
if foldername='研究结束（EOS）' and pagename='研究结束（EOS）'
and fieldname ='DSEOSDAT' 
then actual = fieldvalue;

if foldername="肿瘤评估" then do;
pagename="肿瘤评估-靶病灶";
fieldname="TUDAT";
fieldlabel="检查日期";
logline="1";
end;
keep usubjid foldername pagename fieldname fieldlabel logline actual;
run;
proc sort data=actual_visdt_notu;by usubjid foldername;run;
proc sort data=actual_tu;by usubjid foldername;run;

data actual_visdt;
merge actual_visdt_notu(in=a) actual_tu;
by usubjid foldername;if a;
if foldername='肿瘤评估' then actual = actual_tu;
drop actual_tu ;
if actual ^='';
run;
proc sort data=actual_visdt nodupkey;by _all_;run;
*page last modify date;

data last_modify_log last_modify_nonlog;
set page2;
if logline ='' then output last_modify_nonlog;
else output last_modify_log;
run; 

proc sql;
create table page_last_modify_log as
select distinct  usubjid, foldername, logline, pagename, 
	last_modify_dt, max(last_modify_dt) as page_last
from last_modify_log
group by usubjid, foldername, logline, pagename;

create table page_last_modify_nonlog as
select distinct   usubjid, foldername, logline, pagename, 
	last_modify_dt, max(last_modify_dt) as page_last
from last_modify_nonlog
group by usubjid, foldername, pagename;

quit;

data page_last_modify;
set page_last_modify_log page_last_modify_nonlog;
drop last_modify_dt;
run;

proc sort data=page_last_modify nodupkey;
by usubjid foldername  pagename logline page_last;
run;
*接下来是 将page status里没有SDV的页面，与actual date和page last modify 拼在一起;
data page3;
set pagedatareport;
if var6 ='是';*受试者是否有效;

keep var2 var3 var4 var7 var9 var10 var11 var13 var14 var23;
rename var2 = siteid var3=sitename var4=usubjid var7=foldername 
var9=pagename var10=fieldname
var11=fieldlabel 
var13=logline var14=fieldvalue
var23=SDV_delay;
run;

data sdv_delay_log sdv_delay_nonlog;
set page3;
if logline ='' then output sdv_delay_nonlog;
else output sdv_delay_log;
run; 

proc sql;
create table page_sdv_delay_log as
select distinct siteid, sitename,usubjid, foldername, logline, pagename, 
	sdv_delay, count(sdv_delay) as n_sdv_delay
from sdv_delay_log
where index(SDV_delay,'Y')>0
group by usubjid, foldername, logline, pagename
;

create table page_sdv_delay_nonlog as
select distinct siteid, sitename,usubjid, foldername, logline, pagename, 
	sdv_delay, count(sdv_delay) as n_sdv_delay
from sdv_delay_nonlog
where index(SDV_delay,'Y')>0
group by usubjid, foldername, pagename

;
quit;


data page_sdv_delay;
set page_sdv_delay_log  page_sdv_delay_nonlog;
drop sdv_delay;
run;

proc sort data=page_sdv_delay nodupkey;
by usubjid foldername pagename logline;
run;

proc sort data=page_sdv_delay ;
by usubjid foldername pagename logline;
run;
proc sort data=actual_visdt ;
by usubjid foldername pagename logline;
run;
proc sort data=page_last_modify ;
by usubjid foldername pagename logline;
run;

data page_sdv_delay_modify;
merge page_sdv_delay(in=a)  page_last_modify;
by usubjid foldername  pagename logline; if a;
run;

*与actual date拼接;

data group1(rename=(logline=logline1 pagename=pagename1)) 
     group2(rename=(pagename=pagename2)) 
     group3 ;
set page_sdv_delay_modify;
*1.访视日期by foldername;
if foldername in ('筛选期','治疗结束访视','安全性随访','治疗结束','研究结束（EOS）')
	or index(foldername,'C')>0 
	or index(foldername,'计划外访视')>0
then output group1;
*3.治疗结束by foldername;
/*if foldername = '治疗结束'*/
/*then output group3;*/

*2.肿瘤评估by foldername, logline;;
if foldername = '肿瘤评估'
then output group2;

*4.生存随访，共同页by foldername logline pagename;
if foldername in ('生存随访','共同页')
then output group3;
*5.研究结束by foldername;
run;

proc sort data=group1;by usubjid foldername;run;
proc sort data=actual_visdt;by usubjid foldername;run;

data mg1(rename=(logline1=logline pagename1=pagename));
merge group1(in=a)  actual_visdt;
by  usubjid foldername; if a;
drop pagename logline;
run;

proc sort data=group2;by usubjid foldername logline;run;
proc sort data=actual_visdt;by usubjid foldername logline;run;

data mg2(rename=(pagename2=pagename));
merge group2(in=a)  actual_visdt;
by  usubjid foldername logline; if a;
drop pagename;
label fieldname = "TUDAT" 
fieldlabel="第一个靶病灶检查日期";
run;
proc sort data=  mg2 nodupkey; by _all_;run;


proc sort data=group3;by usubjid foldername logline pagename;run;
proc sort data=actual_visdt;by usubjid foldername logline pagename;run;

data mg3;
merge group3(in=a) actual_visdt;
by  usubjid foldername logline pagename; if a;
run;

data page_sdv_delay_modify_actual raw.page_notsdv;
set mg1 mg2 mg3;
format curr yymmdd10.;
curr=today();
page_last_dt = input(substr(page_last,1,10),yymmdd10.);
day=curr - page_last_dt;
label curr = '当前日期'
      day = 'SDV_Delay_Aging'
	  page_last = 'Page_Last_Modify_DateTime'
	  fieldlabel = '实际日期变量'
	  n_sdv_delay = '未SDV字段总数'
	actual = '实际日期';
drop page_last_dt fieldname;
run;


proc sort data=raw.page_notsdv nodupkey;
by _all_;run;
proc sort data=raw.page_notsdv;
by usubjid foldername  pagename logline;
run;

******Not SDV Summary*****************************************;
proc sql;
create table sdvsum as
select distinct siteid, sitename,count(distinct usubjid) as nsub,
count(pagename) as npage, max(day) as maxday
from raw.page_notsdv
group by siteid;
quit;

data sdv_g1 sdv_g2 sdv_g3 sdv_g4;
set raw.page_notsdv;
if day <= 2*7 then output sdv_g1;
if 2*7 < day <= 4*7 then output sdv_g2;
if 4*7 < day <= 8*7 then output sdv_g3;
if day > 8*7 then output sdv_g4;
run;

proc sql;
create table sdvsum1 as
select distinct siteid, count(day) as n_g1
from sdv_g1
group by siteid;

create table sdvsum2 as
select distinct siteid, count(day) as n_g2
from sdv_g2
group by siteid;

create table sdvsum3 as
select distinct siteid, count(day) as n_g3
from sdv_g3
group by siteid;

create table sdvsum4 as
select distinct siteid, count(day) as n_g4
from sdv_g4
group by siteid;
quit;

proc  sort data=sdvsum;by siteid;run;
proc  sort data=sdvsum1;by siteid;run;
proc  sort data=sdvsum2;by siteid;run;
proc  sort data=sdvsum3;by siteid;run;
proc  sort data=sdvsum4;by siteid;run;

data sdv_summary sdv_summary1;
merge sdvsum sdvsum1 sdvsum2 sdvsum3 sdvsum4;
by siteid;
run;


proc sql;
insert into sdv_summary
(siteid, sitename, nsub, npage, maxday,n_g1,n_g2,n_g3,n_g4)
select '    ' as siteid, 'Total    ' as sitename,
sum(nsub) as nsub,
sum(npage) as npage,
max(maxday) as maxday,
sum(n_g1) as n_g1,
sum(n_g2) as n_g2,
sum(n_g3) as n_g3,
sum(n_g4) as n_g4
from sdv_summary1;
quit;

data raw.sdv_summary;
retain siteid sitename nsub npage n_g1 n_g2 n_g3 n_g4 maxday;
set sdv_summary;
array num[*] nsub npage n_g1 n_g2 n_g3 n_g4;
	do i = 1 to dim(num);
	if num[i]=. then num[i]=0;
	end;

curr = today();
drop i;
keep siteid sitename nsub npage n_g1 n_g2 n_g3 n_g4 maxday;
label nsub ="#_of_Subjects" npage="#_of_SDV_Pending_Form"
n_g1 ="SDV_Aging_<=_2_weeks"
n_g2 ="2_weeks_<_SDV_Aging_<=_4_weeks"
n_g3 ="4_weeks_<_SDV_Aging_<=_8_weeks"
n_g4 ="SDV_Aging_>_8_weeks"
maxday="Max_UnSDV_Aging";
run;
