

*20241127 Missing EX Report *************************************************;
*1. C1D1访视日期有记录，EX 需有记录;
data page1_ex;
set page1;
if foldername = '共同页' 
and pagename in ('HMPL-760研究用药', 'R-GemOx利妥昔单抗给药',
				'R-GemOx吉西他滨给药','R-GemOx奥沙利铂给药');
run;

data ex_from_pg2;
set page2;
if foldername = '共同页' 
and pagename in ('HMPL-760研究用药','R-GemOx利妥昔单抗给药',
				'R-GemOx吉西他滨给药','R-GemOx奥沙利铂给药');
keep usubjid foldername pagename fieldname logline fieldvalue; 
run;

proc sql;
create table cnt_entry as
select distinct usubjid,foldername,pagename,logline, count(fieldvalue) as cnt
from ex_from_pg2
group by usubjid,pagename,logline;
quit;

proc sql;
create table page1_2_ex as
select a.siteid,a.sitename,a.usubjid,a.foldername,a.pagename, 
b.logline,b.cnt as n_entryfield
from page1_ex a
left join cnt_entry b
on a.usubjid=b.usubjid and a.foldername=b.foldername
and a.pagename=b.pagename;
quit;



data c1d1_visdt;
set raw.sv;
if VISIT = 'C01D1';
keep usubjid svstdat;
run;

proc sort data=page1_2_ex;by usubjid;run;
proc sort data=c1d1_visdt;by usubjid;run;

data page_mis_ex_c1d1 ;
merge page1_2_ex(in=a) c1d1_visdt;
by usubjid; if a;
if svstdat ^ ='' and n_entryfield = . 
then qry_ex1 = 'C1D1访视日期有记录，EX 需有记录';

if input(logline,best.) < 7 and logline ^='' then
plan_folder = 'C0'|| strip(logline) || 'D1'; 

if qry_ex1 ^="" then day1=today()-input(svstdat,yymmdd10.);
format curr yymmdd10.;
curr=today();
label qry_ex1 = '给药页面缺失提示' day1 = "给药缺失天数" 
svstdat ='C1D1访视日期' curr="当前日期";
run;

data raw.page_mis_ex;
set page_mis_ex_c1d1;
if qry_ex1 ^="";
drop plan_folder n_entryfield;
run;

*3 R-GemOx用药，给药周期和访视匹配，超过6个周期无需提醒;
data page2;
set pagedatareport;
if var6 ='是';*受试者是否有效;

keep var2 var3 var4 var7 var9 var10 var11 var12 var13 var14;
rename var2 = siteid var3=sitename var4=usubjid var7=foldername 
var9=pagename var10=fieldname
var11=fieldlabel var12=last_modify_dt
var13=logline var14=fieldvalue;

run;

data cycle_svdat;
set page2;
if index(foldername,'C')>0 ;
if pagename = '访视日期' and fieldlabel = '访视日期';

svdat = input(fieldvalue,yymmdd10.);
run;

proc sql;
create table page_mis_ex_c1d1_asv as
select a.siteid,a.sitename,a.usubjid,a.foldername,a.pagename,
a.logline,a.n_entryfield,a.svstdat,a.plan_folder, b.fieldvalue as actual_svdt
from page_mis_ex_c1d1 a
left join cycle_svdat b
on a.usubjid=b.usubjid and a.plan_folder=b.foldername;
quit;

data page_mis_ex_c1d1_asvdt;
set page_mis_ex_c1d1_asv;
if pagename="HMPL-760研究用药" then delete;
if actual_svdt ^ ='' and n_entryfield = . then
qry_ex2 = "周期" || plan_folder ||"的R-GemOx缺失，请核实。";

if qry_ex2 ^="" then day2=today() - input(actual_svdt,yymmdd10.);
format curr yymmdd10.;
curr=today();
label plan_folder = "周期" qry_ex2="R-GemOx缺失提示"
day2="R-GemOx缺失天数"   actual_svdt ="实际访视日期" curr="当前日期";
run;

data raw.mis_ex_Rgemox;
set page_mis_ex_c1d1_asvdt;
if qry_ex2 ^="";
run;

/**/
/*proc sort data=cycle_svdat; by usubjid descending svdat;run;*/
/**/
/*data maxcycle_svdat;*/
/*set cycle_svdat;*/
/*by usubjid descending svdat;*/
/*if first.usubjid;*/
/*keep usubjid foldername  fieldvalue ;*/
/*rename foldername = maxfolder fieldvalue = maxsvdat ;*/
/*run;*/
/**/
/**/
/**找EOT;*/
/*data eot_eotdat;*/
/*set raw.dseot;*/
/*keep usubjid dsendat;*/
/*run;*/
/**/
/*proc sort data=page_mis_ex_c1d1_asv;by usubjid;run;*/
/*proc sort data=maxcycle_svdat;by usubjid;run;*/
/*proc sort data=eot_eotdat;by usubjid;run;*/

/*data page_mis_ex_all raw.page_mis_ex;*/
/*retain siteid sitename usubjid foldername pagename logline*/
/*	n_entryfield svstdat qry_ex1 day1*/
/*	maxfolder maxsvdat plan_folder  actual_svdt qry_ex2 day2 curr;*/
/*merge page_mis_ex_c1d1_asvdt(in=a) maxcycle_svdat eot_eotdat;*/
/*by usubjid;*/
/*if a;*/
/**qry = qry_ex1 || qry_ex2;*/
/*if qry_ex1 ^ = "" or qry_ex2 ^="";*/
/*format curr yymmdd10.;*/
/*curr = today();*/
/**day = curr - min(input(maxsvdat,yymmdd10.),input(dsendat,yymmdd10.));*/
/**/
/*label maxfolder ="最大访视" */
/*maxsvdat="最大访视日期" dsendat="EOT日期" */
/*n_entryfield = "字段总数" */
/*curr ="当前日期"  ;*qry="页面缺失提示";*/
/**drop qry_ex1 qry_ex2;*/
/*run;*/


*2. HMPL-760研究用药，至少记录到最大常规访视日期前一天或EOT前一天，ongoing用药无结束日期不提醒，;

data act_ex;
set raw.ex;
st=input(exstdat,yymmdd10.);
en=input(exendat,yymmdd10.);
keep siteid usubjid line exstdat exendat exdstxt status en;
run;

proc sql;
create table act_lst_ex as
select *, max(en) as lenex format=yymmdd10.
from act_ex
group by usubjid;
quit;

data act_eot;
set raw.dseot;
keep usubjid dsendat;
run;

*找最大常规访视:;
data act_maxsv;
set page2;
if fieldlabel="访视日期" and (index(foldername,'C')>0 or foldername="筛选期");
maxsv=input(fieldvalue,yymmdd10.);
keep usubjid foldername fieldvalue maxsv;
run;
proc sort data=act_maxsv;by usubjid descending maxsv;run;
data act_maxsvdat;
set act_maxsv;
by usubjid descending maxsv;
if first.usubjid;
run;

proc sql;
create table act_ex_maxsv as
select * from
act_maxsvdat a left join act_lst_ex b
on a.usubjid=b.usubjid;

create table act_ex_maxsv_eot as
select * from
act_ex_maxsv a left join act_eot b
on a.usubjid=b.usubjid;

quit;
/*需要将已录的lenex都呈现，对应同一行的行号和stdate也呈现，*/
/*非ongoing的情况：lenex < 最大常规方式-1，则提示缺失; 7.13 < 7.15 -1,qry*/
/*ongoing的判断:endate = 空，取该的stdate，不需要比较。;*/
/*day = today - lenex;*/

data mis_ex;
set act_ex_maxsv_eot;
lenexc = put(lenex,yymmdd10.);

if lenex ^=. and lenex < maxsv -1 then 
flag="最大访视日期为"||trim(fieldvalue) ||"但最后一次给药结束日期为"|| trim(lenexc)||"，缺失给药记录";

if exstdat ^="" and exendat="" then flag="";

if exstdat ^="";
drop maxsv en lenex;
label lenexc = "最大给药结束日期" foldername="最大常规访视"
fieldvalue="最大常规访视日期" flag="760给药缺失提示";
run;

/*至少记录到最大常规访视日期前一天或EOT前一天*/
data raw.mis_ex_760;
retain siteid usubjid status 
foldername fieldvalue line exstdat exendat 
exdstxt lenexc dsendat flag;
set mis_ex;
day = min(input(dsendat,yymmdd10.),input(fieldvalue,yymmdd10.)) - input(exendat,yymmdd10.);
if flag ^="";
format curr yymmdd10.;
curr=today();
label day="760缺失天数" curr="当前日期";
run;
