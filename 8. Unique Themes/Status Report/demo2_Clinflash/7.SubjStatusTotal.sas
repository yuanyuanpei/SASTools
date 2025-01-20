

***subject status total************************************;
*by site;

*n of subj;
data subj_rep;
set subjectstatusdetailreport;
keep var2 var3 var4;
rename var2=siteid var3=sitename var4=usubjid;
run;

proc sql;
create table n_subj as
select distinct siteid,sitename,count(usubjid) as n_subj
from subj_rep
group by siteid;
quit;
*n of screening;
data total_sv;
set raw.sv;
if VISIT = '筛选期' and svstdat ^= '';
keep siteid usubjid svstdat;
run;

data total_ds;
set raw.ds;
if DSYN ^= '' or DSREASND ^ ='';
keep siteid usubjid;
run;

proc sql;
create table n_screening as
select distinct siteid, count(usubjid) as n_screening 
from total_sv
where usubjid not in (select usubjid from total_ds)
group by siteid;

quit;

*n of rand;
data total_rand;
set raw.rand;
if randyn = '是';
keep siteid usubjid;
run;
proc sql;
create table n_rand as
select distinct siteid, count(usubjid) as n_rand
from total_rand
group by siteid;
quit;
*n of eot;
data total_eot;
set raw.dseot;
if dsendat ^='';
keep siteid usubjid;
run;
proc sql;
create table n_eot as
select distinct siteid, count(usubjid) as n_eot
from total_eot
group by siteid;
quit;
*n of eos;
data total_eos;
set raw.eos;
if dseosdat ^='';
keep siteid usubjid;
run;
proc sql;
create table n_eos as
select distinct siteid, count(usubjid) as n_eos
from total_eos
group by siteid;
quit;
*n of screen fail;
data total_fail;
set raw.ds;
if DSYN = '否';
keep siteid usubjid;
run;
proc sql;
create table n_fail as
select distinct siteid, count(usubjid) as n_fail
from total_fail
group by siteid;
quit;
*n of entered pages;
data total_enter;
set pagestatusreport;
if var8 = '-----------' then delete;
if var9 = '0' then delete;
keep var2 var4 var9;
rename var2=siteid var4=usubjid var9=enter;
run;
proc sql;
create table n_enter as
select distinct siteid, count(enter) as n_enter
from total_enter
group by siteid;
quit;
*n of missing pages;
*==================*;
data total_mis_page;
set raw.page_mis;
if qry ^='';
keep siteid usubjid day;
run;


data total_misv_cycle;
set raw.misv_cycle;
if flag3 ^='';
keep siteid usubjid day;
run;

data total_misv_safe;
set raw.misv_safe;
if flag ^="";
keep siteid usubjid day;
run;
*==================*;
data total_mis_ta;
set raw.page_mis_ta;
if qry_ta ^='';
keep siteid usubjid day;
run;

data total_misv_ta;
set raw.misv_ta;
if flag ^="";
keep siteid usubjid day;
run;
*==================*;
data total_mis_ex;
set raw.page_mis_ex;
keep siteid usubjid day1;
rename day1=day;
run;

data total_mis_ex2;
retain siteid usubjid day2;
set raw.mis_ex_Rgemox;
keep siteid usubjid day2;
rename day2=day;
run;

data total_mis_ex3;
retain siteid usubjid ;
set raw.mis_ex_760;
keep siteid usubjid day;
run;

data total_mis;
set total_mis_page total_misv_cycle total_misv_safe
	total_mis_ta total_misv_ta
	total_mis_ex total_mis_ex2 total_mis_ex3;
if usubjid ="" then delete;
run;

proc sql;
create table n_mis as
select distinct siteid, count(usubjid) as n_mis
from total_mis
group by siteid;
quit;
*enter rate = n of enter / (n of enter + n of missing);

*n of sdv: =N;
*n of not sdv =Y[];
data total_sdv;
set pagestatusreport;
if var8 = '-----------' then delete;

keep var2 var4 var17 var18;
rename var2=siteid var4=usubjid var17=sdved var18=not_sdv;
run;

data total_sdved total_notsdv;
set total_sdv;
if sdved ^ = '0' then output total_sdved;
if not_sdv ^ = '0' then output total_notsdv;
run;

proc sql;
create table n_sdv as
select distinct siteid, count(sdved) as n_sdv from total_sdved
group by siteid;
create table n_notsdv as
select distinct siteid, count(not_sdv) as n_notsdv from total_notsdv
group by siteid;
quit;
/*sdv rate = sdved / (sdved + not sdved);*/

*n of open query
n of ans query (CRA, MM, DM)
n of close query;
data total_query;
set querydetailreport;
keep var2 var4   var13 var21;
rename var2=siteid var4=usubjid var13 = role var21=status;
run;

data total_openq;
set total_query;
if status='打开质疑';
*keep siteid usubjid;
run;
data total_openq2;
set raw.open_query;
*if status='打开质疑';
*keep siteid usubjid;
run;



data total_ansq total_ans_cra total_ans_mm total_ans_dm total_ans_sys;
set total_query;
if status='回答质疑' then output total_ansq;
if status='回答质疑' and role='CRA->Site' then output total_ans_cra;
if status='回答质疑' and role='MM->Site' then output total_ans_mm;
if status='回答质疑' and role='DM->Site' then output total_ans_dm;
if status='回答质疑' and role='System->Site' then output total_ans_sys;
keep siteid usubjid;
run;

data total_closeq;
set total_query;
if status='关闭质疑';
keep siteid usubjid;
run;

proc sql;
create table n_totalq as
select distinct siteid, count(usubjid) as n_totalq from total_query
group by siteid;

create table n_open as
select distinct siteid, count(usubjid) as n_open from total_openq
group by siteid;

create table n_ansq as
select distinct siteid, count(usubjid) as n_ansq from total_ansq
group by siteid;

create table n_ans_cra as
select distinct siteid, count(usubjid) as n_ans_cra from total_ans_cra
group by siteid;
create table n_ans_mm as
select distinct siteid, count(usubjid) as n_ans_mm from total_ans_mm
group by siteid;
create table n_ans_dm as
select distinct siteid, count(usubjid) as n_ans_dm from total_ans_dm
group by siteid;
create table n_ans_sys as
select distinct siteid, count(usubjid) as n_ans_sys from total_ans_sys
group by siteid;

create table n_closeq as
select distinct siteid, count(usubjid) as n_closeq from total_closeq
group by siteid;
quit;
*n of ae;
data total_ae;
set raw.ae;
if AEYN ='是';
keep siteid usubjid aeYN;
run;

*n of sae;
data total_sae;
set raw.ae;
if AESER ='是';
keep siteid usubjid aeser;
run;
proc sql;
create table n_ae as
select distinct siteid, count(usubjid) as n_ae from total_ae
group by siteid;

create table n_sae as
select distinct siteid, count(usubjid) as n_sae from total_sae
group by siteid;
quit;


%macro sort2(a);
proc sort data=&a.;by siteid;run;
%mend sort2;

%sort2(n_subj) %sort2(n_screening) %sort2(n_rand) %sort2(n_eot) %sort2(n_eos) %sort2(n_fail)
%sort2(n_enter) %sort2(n_mis) %sort2(n_sdv) %sort2(n_notsdv)
%sort2(n_totalq) %sort2(n_open) %sort2(n_ansq) %sort2(n_ans_cra) %sort2(n_ans_mm)
%sort2(n_ans_dm) %sort2(n_ans_sys) %sort2(n_closeq) %sort2(n_ae) %sort2(n_sae)


data subj_total subj_total1;
merge n_subj n_screening n_rand n_eot n_eos n_fail
      n_enter n_mis n_sdv n_notsdv 
      n_totalq n_open n_ansq n_ans_cra n_ans_mm n_ans_dm n_ans_sys n_closeq
	  n_ae n_sae;
by siteid;
run;


proc sql;
insert into subj_total
(siteid, sitename, n_subj, n_screening, n_rand, n_eot, n_eos, n_fail,
      n_enter, n_mis, n_sdv, n_notsdv, n_totalq,
      n_open, n_ansq, n_ans_cra, n_ans_mm, n_ans_dm, n_ans_sys, n_closeq,
	  n_ae, n_sae)
select '    ' as siteid, 'Total    ' as sitename,
sum(n_subj),sum(n_screening) ,
sum(n_rand),sum(n_eot),sum(n_eos),
sum(n_fail),sum(n_enter),sum(n_mis),sum(n_sdv),sum(n_notsdv),
sum(n_totalq),
sum(n_open),sum(n_ansq),sum(n_ans_cra),sum(n_ans_mm),
sum(n_ans_dm),sum(n_ans_sys),sum(n_closeq),sum(n_ae),sum(n_sae)
from subj_total1;
quit;

data subj_total_rate;
set subj_total;
array num[*] n_subj -- n_sae;
	do i = 1 to dim(num);
	if num[i]=. then num[i]=0;
	end;

format enter_rate sdv_rate percent7.2;
enter_rate = n_enter / (n_enter + n_mis);
sdv_rate = n_sdv / (n_sdv + n_notsdv);
if enter_rate=. then enter_rate=0 ;
if sdv_rate=. then sdv_rate=0 ;

format curr yymmdd10.;
curr = today();
drop i;
run;

data raw.subj_total_rate;
retain siteid sitename n_subj n_screening n_rand n_eot n_eos n_fail
      n_enter n_mis enter_rate n_sdv n_notsdv sdv_rate  n_totalq
      n_open n_ansq n_ans_cra n_ans_mm n_ans_dm n_ans_sys n_closeq
	  n_ae n_sae curr;
set subj_total_rate;
label n_subj="#_of_Subjects" n_screening="#_of_Subjects(Screening)" n_rand="#_of_Subjects(Successfully_Rand)"
n_eot= "#_of_Subjects(EOT)" n_eos="#_of_Subjects(EOS)" n_fail="#_of_Subjects(Screen_Failure)" 
n_enter="#_of_Entered_Pages" n_mis="#_of_Missing_Pages" enter_rate="Enter_Rate"  
n_sdv = "#_of_Pages_SDVed" n_notsdv="#_of_Pages_Not_SDV(Page)" sdv_rate="SDV_Rate" 
n_totalq ="#_of_Total_Query" n_open ="#_of_Open_Query" n_ansq="#_of_Answered_Query" n_closeq="#_of_Closed_Query" n_ae="#_of_AE" n_sae="#_of_SAE"
n_ans_cra="#_of_Answered_Query(CRA)"  n_ans_mm="#_of_Answered_Query(MM)"  n_ans_dm="#_of_Answered_Query(DM)"  n_ans_sys="#_of_Answered_Query(Sys)"
curr = "Current_Date";
run;
***20241129 SAE List********;
data raw.saelist;
set raw.ae;
*if aeser= '是';
run;


***20250110 Mis Aging Summary***;
data mis_aging;
set total_mis;
run;



data mis_g1 mis_g2 mis_g3 mis_g4;
set mis_aging;
if day <= 1*7 then output mis_g1;
if 1*7 < day <= 2*7 then output mis_g2;
if 2*7 < day <= 4*7 then output mis_g3;
if day > 4*7 then output mis_g4;
run;

proc sql;
create table misagesum_a as
select distinct siteid, count(distinct usubjid) as nsub,
count(day) as nmis, max(day) as maxday
from mis_aging
group by siteid;

create table misagesum as
select distinct misagesum_a.*,subj_rep.sitename 
from misagesum_a left join subj_rep
on misagesum_a.siteid = subj_rep.siteid;

quit;

proc sql;
create table missum1 as
select distinct siteid, count(day) as n_g1
from mis_g1
group by siteid;

create table missum2 as
select distinct siteid, count(day) as n_g2
from mis_g2
group by siteid;

create table missum3 as
select distinct siteid, count(day) as n_g3
from mis_g3
group by siteid;

create table missum4 as
select distinct siteid, count(day) as n_g4
from mis_g4
group by siteid;
quit;

proc  sort data=misagesum;by siteid;run;

proc  sort data=missum1;by siteid;run;
proc  sort data=missum2;by siteid;run;
proc  sort data=missum3;by siteid;run;
proc  sort data=missum4;by siteid;run;

data mis_summary mis_summary1;
retain siteid sitename nsub nmis maxday;
merge misagesum missum1 missum2 missum3 missum4;
by siteid;
run;


proc sql;
insert into mis_summary
(siteid, sitename, nsub, nmis, maxday,n_g1,n_g2,n_g3,n_g4)
select '    ' as siteid, 'Total    ' as sitename,
sum(nsub) as nsub,
sum(nmis) as nmis,
max(maxday) as maxday,
sum(n_g1) as n_g1,
sum(n_g2) as n_g2,
sum(n_g3) as n_g3,
sum(n_g4) as n_g4
from mis_summary1;
quit;

data raw.mis_summary;
retain siteid sitename nsub nmis n_g1 n_g2 n_g3 n_g4 maxday;
set mis_summary;
array num[*] nsub nmis n_g1 n_g2 n_g3 n_g4;
	do i = 1 to dim(num);
	if num[i]=. then num[i]=0;
	end;
format curr yymmdd10.;
curr = today();
drop i;
keep siteid sitename nsub nmis n_g1 n_g2 n_g3 n_g4 maxday curr;
label nsub ="#_of_Subjects" nmis="#_of_Missing_Form"
n_g1 ="Missing_Aging_<=_2_weeks"
n_g2 ="2_weeks_<Missing_Aging_<=_4_weeks"
n_g3 ="4_weeks_<Missing_Aging_<=_8_weeks"
n_g4 ="Missing_Aging_>_8_weeks"
maxday="Max_Missing_Aging" curr="当前日期";
run;
