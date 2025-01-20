

**20241128 Query listing;
data page4;
set querydetailreport;

keep var2 var3 var4 var6-var8 var10-var24;
rename var2 = siteid var3=sitename var4=usubjid 
var6=foldername var7=modulename
var8=pagename var10=fieldlabel
var11=logline
var12=fieldvalue
var14=opendate
var18=answerdate;
/*质疑类型	质疑打开时间	打开天数 / 回答天数	质疑打开人员	质疑内容	回答时间	回答人员	回答内容	质疑状态	关闭时间	关闭人员	校验编号	质疑组别*/

run;
*与actual date拼接;

data group4 group5 group6 ;
set page4;
*1.访视日期by foldername;
if foldername in ('筛选期','治疗结束访视','安全性随访','治疗结束','研究结束（EOS）')
	or index(foldername,'C')>0 
	or index(foldername,'计划外访视')>0
then output group4;
*3.治疗结束by foldername;
/*if foldername = '治疗结束'*/
/*then output group3;*/

*2.肿瘤评估by foldername, logline;;
if foldername = '肿瘤评估'
then output group5;

*4.生存随访，共同页by foldername logline pagename;
if foldername in ('生存随访','共同页')
then output group6;
*5.研究结束by foldername;

run;

data actual_visdt2;
set actual_visdt;
*keep usubjid foldername logline pagename actual;
run;


proc sort data=group4;by usubjid foldername;run;
proc sort data=actual_visdt2;by usubjid foldername;run;

data mg4;
merge group4(in=a) actual_visdt2;
by  usubjid foldername; if a;
run;

proc sort data=group5;by usubjid foldername logline;run;
proc sort data=actual_visdt2;by usubjid foldername logline;run;

data mg5;
merge group5(in=a) actual_visdt2;
by  usubjid foldername logline; if a;
run;

proc sort data=group6;by usubjid foldername logline pagename;run;
proc sort data=actual_visdt2;by usubjid foldername logline pagename;run;

data mg6;
merge group6(in=a) actual_visdt2;
by  usubjid foldername logline pagename; if a;
run;

data open_query_list ans_query_list;
set mg4 mg5 mg6;
if var21 = '打开质疑' then output open_query_list;
if var21 = '回答质疑' then output ans_query_list;
run;

data open_query raw.open_query;
set open_query_list;
format curr yymmdd10.;
curr=today();
open_dt = input(substr(opendate,1,10),yymmdd10.);
day = curr - open_dt;
label curr = 'Current_Date'
      day = 'Open_Query_Pending_Aging'
	actual = 'Acutal_Date';  
drop open_dt;
run;
proc sort data=raw.open_query nodupkey;by _all_;run;


data ans_query raw.ans_query;
set ans_query_list;
format curr yymmdd10.;
curr=today();
ans_dt = input(substr(answerdate,1,10),yymmdd10.);
day = curr - ans_dt;
label curr = 'Current_Date'
      day = 'Answered_Query_Pending_Aging'
	actual = 'Acutal_Date';  
drop ans_dt;
run;
proc sort data=raw.ans_query nodupkey;by _all_;run;
*******Query Summary***********;

proc sql;
create table querysum as
select distinct siteid, sitename,
count(distinct usubjid) as nsub
from page4
group by siteid;
quit;

/*open_query*/
/*ans_query;*/

data open_g1 open_g2 open_g3 open_g4;
set open_query;
if day <= 1*7 then output open_g1;
if 1*7 < day <= 2*7 then output open_g2;
if 2*7 < day <= 4*7 then output open_g3;
if day > 4*7 then output open_g4;
run;

proc sql;
create table opensum as
select distinct siteid, count(day) as no_g
from open_query
group by siteid;

create table opensum1 as
select distinct siteid, count(day) as no_g1
from open_g1
group by siteid;

create table opensum2 as
select distinct siteid, count(day) as no_g2
from open_g2
group by siteid;

create table opensum3 as
select distinct siteid, count(day) as no_g3
from open_g3
group by siteid;

create table opensum4 as
select distinct siteid, count(day) as no_g4 
from open_g4
group by siteid;

create table openmax as
select distinct siteid, max(day) as maxod
from open_query
group by siteid;
quit;

data ans_g1 ans_g2 ans_g3 ans_g4;
set ans_query;
if day <= 1*7 then output ans_g1;
if 1*7 < day <= 2*7 then output ans_g2;
if 2*7 < day <= 4*7 then output ans_g3;
if day > 4*7 then output ans_g4;
run;

proc sql;
create table anssum as
select distinct siteid, count(day) as na_g
from ans_query
group by siteid;

create table anssum1 as
select distinct siteid, count(day) as na_g1
from ans_g1
group by siteid;

create table anssum2 as
select distinct siteid, count(day) as na_g2
from ans_g2
group by siteid;

create table anssum3 as
select distinct siteid, count(day) as na_g3
from ans_g3
group by siteid;

create table anssum4 as
select distinct siteid, count(day) as na_g4
from ans_g4
group by siteid;

create table ansmax as
select distinct siteid, max(day) as maxad
from ans_query
group by siteid;
quit;

proc  sort data=querysum;by siteid;run;
proc  sort data=opensum;by siteid;run;
proc  sort data=opensum1;by siteid;run;
proc  sort data=opensum2;by siteid;run;
proc  sort data=opensum3;by siteid;run;
proc  sort data=opensum4;by siteid;run;
proc  sort data=openmax;by siteid;run;
proc  sort data=anssum;by siteid;run;
proc  sort data=anssum1;by siteid;run;
proc  sort data=anssum2;by siteid;run;
proc  sort data=anssum3;by siteid;run;
proc  sort data=anssum4;by siteid;run;
proc  sort data=ansmax;by siteid;run;

data query_summary query_summary1;
merge querysum 
	opensum opensum1 opensum2 opensum3 opensum4 openmax
	anssum anssum1 anssum2 anssum3 anssum4 ansmax;
by siteid;
run;


proc sql;
insert into query_summary
(siteid, sitename, nsub,
	no_g,no_g1,no_g2,no_g3,no_g4,maxod,
	na_g,na_g1,na_g2,na_g3,na_g4,maxad)

select '    ' as siteid, 'Total    ' as sitename,
		sum(nsub) as nsub,
		sum(no_g) as no_g,
		sum(no_g1) as no_g1,
		sum(no_g2) as no_g2,
		sum(no_g3) as no_g3,
		sum(no_g4) as no_g4,
		max(maxod) as maxod,
		sum(na_g) as na_g,
		sum(na_g1) as na_g1,
		sum(na_g2) as na_g2,
		sum(na_g3) as na_g3,
		sum(na_g4) as na_g4,
		max(maxad) as maxad

from query_summary1;
quit;

data raw.query_summary;
retain siteid sitename nsub 
	no_g no_g1 no_g2 no_g3 no_g4 maxod
	na_g na_g1 na_g2 na_g3 na_g4 maxad curr;
set query_summary;
array num[*] nsub no_g no_g1 no_g2 no_g3 no_g4 maxod
	na_g na_g1 na_g2 na_g3 na_g4 maxad;
	do i = 1 to dim(num);
	if num[i]=. then num[i]=0;
	end;
format curr yymmdd10.;
curr = today();
drop i;
keep siteid sitename nsub 
	no_g no_g1 no_g2 no_g3 no_g4 maxod
	na_g na_g1 na_g2 na_g3 na_g4 maxad curr;
label nsub ="#_of_Subjects"  
no_g ="#_of_Open_Query"
no_g1 ="Open_Query_Pending_Aging_(<=1_weeks)"
no_g2 ="Open_Query_Pending_Aging_(1_week-2_weeks)"
no_g3 ="Open_Query_Pending_Aging_(2_week-4_weeks)"
no_g4 ="Open_Query_Pending_Aging_(>=4_weeks)"
maxod="Max_Open_Query_Aging"
na_g ="#_of_Answered_Query"
na_g1 ="Answered_Query_Pending_Aging_(<=1_weeks)"
na_g2 ="Answered_Query_Pending_Aging_(1_week-2_weeks)"
na_g3 ="Answered_Query_Pending_Aging_(2_week-4_weeks)"
na_g4 ="Answered_Query_Pending_Aging_(>=4_weeks)"
maxad="Max_Answered_Query_Aging"
curr = "Run_Date";
run;
