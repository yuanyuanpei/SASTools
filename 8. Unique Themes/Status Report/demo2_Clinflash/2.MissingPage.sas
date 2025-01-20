

**20241125 Missing pages report *****************************************;
data  page1;
set pagestatusreport;
 keep var2 var3 var4 var6  var8 var9;
 if var8 = '-----------' then delete;
 rename var2 = siteid var3=sitename var4 = usubjid 
 var6 = foldername 
 var8 = pagename var9=n_entryfield;
 run;

data page2;
set pagedatareport;
if var6 ='是';*受试者是否有效;

keep var2 var3 var4 var7 var9 var10 var11 var12 var13 var14;
rename var2 = siteid var3=sitename var4=usubjid var7=foldername 
var9=pagename var10=fieldname
var11=fieldlabel var12=last_modify_dt
var13=logline var14=fieldvalue;

run;

data ds_dsyn;
set raw.ds;
keep usubjid dsyn;
run;

proc sort data=page1;by usubjid;run;
proc sort data=ds_dsyn ;by usubjid;run;
*加筛选总结页-是否筛选成功;
data page1_dsyn;
merge page1(in=a) ds_dsyn(in=b);
by usubjid;
if a;
run;
*筛选期;
data page1_scr_dsyn;
set page1_dsyn;
if foldername = '筛选期' ;
run;
data page1_scr_vis(rename=(pagename=vis n_entryfield=n_visentry) drop=DSYN)
	page1_scr_ds(rename=(pagename=ds n_entryfield=n_dsentry) );
set page1_scr_dsyn;
	if pagename = '访视日期'  then output page1_scr_vis;
	if pagename = '筛选总结页'  then output page1_scr_ds;
run;

proc sort data=page1_scr_vis;by usubjid foldername;run;
proc sort data=page1_scr_ds;by usubjid foldername;run;

data page1_scr_vis_vs;
merge page1_scr_vis page1_scr_ds;
by usubjid foldername;
if n_visentry ^= '0' and n_dsentry='0' then flag='提醒必填1';
if n_visentry ^= '0' and n_dsentry^='0' and DSYN = '是' 
	then flag='提醒必填2';
*20241211 suppl:;
if n_visentry ^= '0' and n_dsentry^='0' and DSYN = '否' 
	then flag='提醒必填0';

run;

proc sort data=page1_dsyn;by usubjid foldername;run;
proc sort data=page1_scr_vis_vs;by usubjid foldername;run;

 data page_mis_scr;
 merge  page1_dsyn(in=a) page1_scr_vis_vs;
 by usubjid foldername;

if flag = '提醒必填1' then do;
	if pagename in ('主知情同意书','人口统计学','肿瘤病史',
		'入排标准判定','筛选总结页','随机化') and n_entryfield = '0'  
	then qry_scr = '筛选期访视日期有记录，筛选总结页空白，本页面必填，请核实。';
end;

if flag = '提醒必填2' then do;
	if  n_entryfield = '0'  then qry_scr = '筛选成功受试者筛选期本页面必填，请核实。';
end;

*20241211 suppl:;
/*if n_visentry ^= '0' and n_dsentry^='0'and DSYN = '否' */
/*	then flag='提醒必填0';*/
if flag = '提醒必填0' then do;
	if pagename in ('主知情同意书','人口统计学','肿瘤病史',
		'入排标准判定','筛选总结页','随机化') and n_entryfield = '0'  
	then qry_scr = '筛选失败受试者筛选期本页面必填，请核实。';
end;

drop vis n_visentry ds n_dsentry flag;
run;

*各访视;
data page_othervis;
set page_mis_scr;
if foldername ^ = '筛选期';
if pagename = '访视日期' and n_entryfield ^ ='0';
flag2 = '提醒必填3';
run;
 
proc sort data=page_mis_scr; by usubjid foldername;run;
proc sort data=page_othervis; by usubjid foldername;run;

data page_mis_scr_otvis;
merge page_mis_scr(in=a) page_othervis(drop=n_entryfield DSYN qry_scr);
 by usubjid foldername;
if a;

if flag2 = '提醒必填3' then do;
	if n_entryfield = '0'  then qry_otvis = '该访视访视日期有记录，本页必填，请核实。';
end;

drop flag2;

run;
*共同页;

data eot_eotdt;
set raw.dseot;
keep usubjid dsendat;
run;

proc sort data=page_mis_scr_otvis;by usubjid;run;
proc sort data=eot_eotdt;by usubjid;run;

data page_mis_scr_otvis_log  ;
merge page_mis_scr_otvis(in=a)  eot_eotdt;
by usubjid; if a;

if dsendat ^ ='' then do;
	if foldername = '共同页' and pagename ^ = '死亡页' and n_entryfield = '0'
	then qry_log = 'EOT日期有记录，共同页中本页必填，请核实。';
end;

qry = trim(qry_scr) || trim(qry_otvis) || trim(qry_log);
drop qry_scr qry_otvis qry_log;
label qry = '页面缺失提示';
run;

data link_visdt;
set page2;
if fieldlabel="访视日期";
keep usubjid foldername fieldvalue;
rename fieldvalue=visdt;
run;



proc sort data=link_visdt;by usubjid foldername;run;
proc sort data=page_mis_scr_otvis_log;by usubjid foldername;run;

data page_mis_day;
merge page_mis_scr_otvis_log(in=a) link_visdt;
by usubjid foldername;
if a;
run;
*仅展示query有内容的观测;
data raw.page_mis;
retain siteid sitename usubjid foldername visdt pagename n_entryfield DSYN
dsendat qry curr day;
set page_mis_day;
if qry ^="";
format curr yymmdd10.;
curr=today();
day=today() - input(visdt,yymmdd10.);
label visdt="该访视的访视日期" day="缺失天数" curr="当前日期";
run;

**以上为页面缺失。;

**以下为访视缺失，显示所有页;
/*1.cycle访视缺失：按照时间窗，预设C50个，EOT前的需做的随访需填写，未做需记录未做；*/
/*2.安全性随访缺失：提醒EOT日期后37天缺失；所有随访已记录未查不作为缺失；*/
/*3.生存随访缺失：若第一次随访有记录，提醒后续每12周（+7）生存随访缺失，预设10次；考虑EOS日期内的缺失；*/


*****;
/*1.cycle访视缺失：按照时间窗，预设C50个，EOT前的需做的随访需填写，未做需记录未做；*/

data act_cycle;
set page1;
if index(foldername,'C')>0 and index(foldername,'D')>0;
act_folder=foldername;
run;



*预设访视:;
proc import datafile="&root.\&_mode.\Document\CycleWindow.xlsx"
out=plan_cycle
dbms=xlsx;
getnames=yes;
sheet="CYCLE";
run;
**combine plan和actual的cycle;
proc sql;
create table subj_plan as
select distinct act_cycle.usubjid, plan_cycle.*
from plan_cycle, act_cycle 
;quit;
/*proc sql;*/
/*create table mg as*/
/*select distinct * from*/
/*subj_plan a left join act_cycle b*/
/*on a.usubjid=b.usubjid and a.foldername=b.foldername;*/
/*quit;*/

proc sort data=subj_plan(rename=(plan_cycle=foldername));by usubjid foldername;run;
proc sort data=act_cycle;by usubjid foldername;run;

data mg;
retain siteid sitename;
merge subj_plan(in=a) act_cycle;
by usubjid foldername;run;

data act_eotdat;
set page2;
if foldername = "治疗结束" and pagename="治疗结束（EOT）" 
and fieldname="DSENDAT";
keep usubjid   fieldvalue;
rename fieldvalue = eotdat;
run;

data act_cycle_nd;
set page2;
if index(foldername,'C')>0 and index(foldername,'D')>0;
if pagename="访视日期" and fieldname ="SVND";
keep usubjid foldername  fieldvalue;
rename fieldvalue = svnd;
run;

data act_cycle_sv;
set page2;
if index(foldername,'C')>0 and index(foldername,'D')>0;
if pagename="访视日期" and fieldname ="SVSTDAT";
keep usubjid foldername  fieldvalue;
rename fieldvalue = svstdat;
run;

data act_c1d1_sv;
set page2;
if foldername='C01D1' and pagename="访视日期" 
 and fieldlabel="访视日期";
keep usubjid  fieldvalue;
rename fieldvalue = c1d1dat;
run;

**加上c1d1dat, svnd, svstdat, eotdat;
proc sql;
create table actual as
select p.*,q.c1d1dat,p.foldername as act_folder from
	(select x.*,y.svstdat from
		(select m.*,n.svnd from
			(select a.*,b.eotdat from
				mg a 
			left join act_eotdat b 
			on a.usubjid=b.usubjid) as m 
		left join act_cycle_nd as n
		on m.usubjid=n.usubjid and m.foldername = n.foldername) as x
	left join act_cycle_sv as y
		on x.usubjid=y.usubjid and x.foldername = y.foldername) as p
left join act_c1d1_sv as q
on p.usubjid=q.usubjid

;
quit;

proc sort data=actual;by usubjid real;run;

data  misv_cycle;
set actual;
format plan_min plan_max yymmdd10.;
plan_min = input(c1d1dat,yymmdd10.) + min;
plan_max = input(c1d1dat,yymmdd10.) + max;

***EOT不为空的;
*EOT之后的plan不算缺失访视;
if eotdat ^= "" and  plan_min > input(eotdat,yymmdd10.) 
	then flag = "EOT之后的plan不算缺失访视";

*EOT之前的，SVND=1的不算缺失访视;
if eotdat ^= "" and plan_min <= input(eotdat,yymmdd10.) 
 	and svnd ="1" 
	then flag2 = "EOT之前的访视，勾选了未查，不算缺失";
***EOT为空的;
if eotdat ="" and svnd ^="1" and foldername ^="C01D1" then do;
	if plan_max ^=. and plan_max < today() 
	and n_entryfield =0
	then flag3 = "EOT为空，未选择未查，计划访视的最大日期<当前日期，该访视缺失";
end;


if flag ^="" then delete;
if flag2 ^="" then delete;
if flag3 ^="" then do; misv = "Y"; output;end;
drop min real max act_folder flag flag2 misv;
label foldername="数据节" flag3 = "缺失提示" eotdat="EOT日期" 
svnd="未查" svstdat="访视日期" c1d1dat="C1D1访视日期"
plan_min="计划访视日期(最早)" plan_max="计划访视日期(最晚)";
run;


*只保留整个访视都未填的;
proc sql;
create table xx as
select distinct usubjid,foldername,count(n_entryfield) as count,
sum(n_entryfield) as sum
from act_cycle
group by usubjid,foldername;
quit;

proc sort data=misv_cycle; by usubjid foldername;run;
proc sort data=xx; by usubjid foldername;run;

data raw.misv_cycle;
merge misv_cycle(in=a) xx;
by usubjid foldername;if a;
if flag3 ^="";
if sum ^= 0 then delete;
format curr yymmdd10.;
curr=today();
day=today() - plan_max;
drop count sum;
label day="缺失天数" curr="当前日期";
run;



/*2.安全性随访缺失：提醒EOT日期后37天缺失；所有随访已记录未查不作为缺失；*/
data safefu;
set page1;
if foldername = "安全性随访";
run;

data act_safe_nd;
set page2;
if foldername ="安全性随访" and fieldname="SVND" ;
svnd=fieldvalue;
keep usubjid svnd;
run;
proc sql;
create table act_safe as
select m.*,n.svnd from
	(select a.*,b.eotdat from
	safefu a left join act_eotdat b
	on a.usubjid=b.usubjid) as m
	left join act_safe_nd n
	on m.usubjid=m.usubjid
;
quit;

data misv_safe;
set act_safe;
if eotdat ^= "" then do;
	eot_37 = input(eotdat,yymmdd10.) +37;
	if eot_37 <= today() and svnd ^= "1" and n_entryfield =0 
	then flag = "EOT日期后37天至今未填安全性随访，且未查未勾选";
end;
label eot_37 ="EOT后37天" eotdat="EOT日期" svnd="未查" flag = "缺失提示";
run;

data raw.misv_safe;
set misv_safe;
if flag ^="";
run;

*以下未完成，20250103;
/*3.生存随访缺失：
若第一次随访有记录，提醒后续每12周（+7）生存随访缺失，预设10次；
考虑EOS日期内的缺失；*/
proc import datafile="&root.\&_mode.\Document\CycleWindow.xlsx"
out=plan_sur
dbms=xlsx;
getnames=yes;
sheet="SUR";
run;

data first_su;
set page2;
if foldername = "生存随访" and fieldname="DSDAT" and logline="1";
first_sudat=fieldvalue;
keep usubjid first_sudat;
run;

proc sql;
create table subj_plan_su as
select * from
first_su,plan_sur;
quit;

data act_su;
set page2;
if foldername = "生存随访";
run;

/*data mg2;*/
/*merge subj_plan_su act_su;*/
/*by usubjid logline;*/
/*run;*/
