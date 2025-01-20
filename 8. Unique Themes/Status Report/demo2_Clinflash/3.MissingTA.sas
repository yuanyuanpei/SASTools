

*20241127 Missing TA Report *************************************************;
data page1_ta;
set page1;
if foldername = '肿瘤评估';
run;

data page1_ta_vis(rename=(pagename=vis n_entryfield=n_visentry) )
	page1_ta_oth(rename=(pagename=ta_oth n_entryfield=n_taothentry) );
set page1_ta;
	if pagename = '肿瘤评估访视'  then output page1_ta_vis;
	else output page1_ta_oth;
run;

proc sort data=page1_ta_vis;by usubjid foldername;run;
proc sort data=page1_ta_oth;by usubjid foldername;run;

data page1_ta_vis_oth;
merge page1_ta_vis(in=a) page1_ta_oth;
by usubjid foldername;if a;
if n_visentry ^= '0' and n_taothentry='0' then flag='提醒必填3';
run;


data page_mis_ta_tu ;
set page1_ta_vis_oth;
if flag = '提醒必填3' then qry_ta = '肿瘤评估访视有记录，本页数据必填，请核实。';
drop flag;
label vis='肿瘤评估访视页面' n_visentry='肿瘤评估访视页面字段总数' 
  ta_oth='其他数据页' n_taothentry='其他数据页字段总数' qry_ta = '页面缺失提示';
run;

data tu_tudat;
set raw.tutl;
if line = 1;
keep usubjid tudat;
run;

proc sort data=page_mis_ta_tu; by usubjid;run;
proc sort data=tu_tudat; by usubjid;run;


data page_mis_ta  ;
merge page_mis_ta_tu(in=a) tu_tudat;
by usubjid;
if a;
format curr yymmdd10.;
curr = today();
if qry_ta ^ ='' and tudat ^= '' then
day = curr - input(tudat,yymmdd10.);

label day = "缺失天数 (当前日期-第一个靶病灶检查日期)"
curr ="当前日期"
tudat = "第一个靶病灶检查日期";

run;
data raw.page_mis_ta;
set page_mis_ta;
if qry_ta ^ ='' ;
run;

**以上为页面缺失。;
**以下为访视缺失：;

/*2 C1D1 访视日期为基准，根据肿评时间窗提醒访视缺失，直到PD,死亡，*/
/*开始新的抗肿瘤治疗或EOS；预设到C55D1*/
/*19.	肿瘤评估：在首次用药前28天内完成基线肿瘤评估，*/
/*自首次用药后每3周期（±7天）进行1次肿瘤影像学评估直至第16周期（即C4D1，C7D1，C10D1，C13D1，C16D1），*/
/*之后每5个周期（±7天）进行1次肿瘤影像学评估直至第31周期（即C21D1，C26D1，C31D1），*/
/*之后每8个周期（±7天）进行一次(C39D1,C47D1,C55D1);*/

proc import datafile="&root.\&_mode.\Document\CycleWindow.xlsx"
out=plan_TA
dbms=xlsx;
getnames=yes;
sheet="TA";
run;

data act_ta_vis(keep=usubjid tuvis) 
	act_ta_tudat(keep=usubjid logline tudat) 
	act_ta_rs(keep=usubjid rsres) 
	act_dd(keep=usubjid dddat) 
	act_eos(keep=usubjid eosdat);
set page2;
if foldername="肿瘤评估" then do;
	if fieldname="TUVIS" then do;
	tuvis=fieldvalue;output act_ta_vis;
	end;
	if pagename="肿瘤评估-靶病灶" and fieldname="TUDAT" then do;
	tudat=fieldvalue;output act_ta_tudat;
	end;
	if pagename="总体评估（2014 Lugano）" and fieldname="RSRES" then do;
	rsres=fieldvalue;output act_ta_rs;
	end;
end;
if foldername="共同页" and pagename="死亡" and fieldname = "DDDAT" then do;
	DDDAT=fieldvalue;output act_dd;
end;
if foldername="研究结束（EOS）" and fieldname="DSEOSDAT" then do;
	EOSDAT=fieldvalue;output act_eos;
end;
*keep usubjid fieldname logline fieldvalue;
run;

proc sort data=act_ta_vis;by usubjid;run;
proc sort data=act_ta_tudat;by usubjid;run;
proc sort data=act_ta_rs;by usubjid;run;
proc sort data=act_dd;by usubjid;run;
proc sort data=act_eos;by usubjid;run;
data act_tuvis;
merge act_ta_vis act_ta_tudat act_ta_rs act_dd act_eos;
by usubjid;
plan_cycle=tuvis;
run;
proc sql;
create table subj_tuvis as 
select act_tuvis.usubjid,plan_ta.* from
act_tuvis,plan_ta
order by act_tuvis.usubjid,plan_ta.real;

create table tuvis as
select distinct * from
subj_tuvis a full join act_tuvis b
on a.usubjid = b.usubjid  and a.plan_cycle=b.plan_cycle; 

quit;

data act_c1d1dat;
set raw.sv;
if visit = "C01D1";
keep usubjid svstdat;
run;
proc sql;
create table tuvis_c1d1 as
select a.*,b.svstdat as c1d1dat
from tuvis a left join act_c1d1dat b
on a.usubjid=b.usubjid;
quit;
proc sort data=tuvis_c1d1;by usubjid real logline;run;
data tuvis_c1d1_plan ;
retain siteid;
set tuvis_c1d1;
by usubjid real logline;
siteid=substr(usubjid,1,4);
format plan_min plan_max yymmdd10.;
if tuvis ^="筛选期" then do;
	plan_min=input(c1d1dat,yymmdd10.) + min;
	plan_max=input(c1d1dat,yymmdd10.) + max;
	if plan_max < today() and lag(rsres) ^="PD" and dddat ^="" and eosdat ^=""
	then flag="上一次访视的总评不为PD，且死亡日期为空，且EOS日期为空，缺失本访视的肿评。";
	
end;

if flag ^="" then day=today()-plan_max;
format curr yymmdd10.;
curr = today();
label plan_cycle="计划肿评访视" tuvis="实际肿评访视" tudat="靶病灶评估日期"
rsres="总体评估" dddat="死亡日期" eosdat="EOS日期" c1d1dat="C1D1日期"
plan_min="计划访视日期(最早)" plan_max="计划访视日期(最晚)"
flag = "缺失提示" day="缺失天数" curr="当前日期";
drop min real max;
run;

data raw.misv_ta;
set tuvis_c1d1_plan;
if flag ^="";
run;
