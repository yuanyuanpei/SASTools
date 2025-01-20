
proc import datafile="&root.\&_mode.\Output\2.Translated_List\translated_All_Lists_&date..xlsx"
out=trscsNA1
dbms=xlsx replace;getnames=yes;
sheet="CSspecify(LAB)";run;

data trscsna1;
set trscsna1;
rename allvalue=trans;
run;

*combine unique CN and EN;
proc sql noprint;
create table trscsna3 as
select a.* ,b.trans from
ndpcsna a left join trscsna1 b
on a.subject=b.subject and a.recordID=b.recordID and a.formOID=b.formOID and a.fieldseq=b.fieldseq;
quit;

*from unique to all obs;
proc sql noprint;
create table trscsna2 as
select a.*,b.trans 
from trscsna a left join trscsna3 b
on a.allvalue=b.allvalue;
quit;

data trscsna2;
set trscsna2;
rec=put(recordID,best. -l);
seq=put(fieldseq,best. -l);
rename  rec=recordID seq=fieldseq;
drop recordid fieldseq;
run;

proc sql noprint;
select  'if subject = "'||trim(subject)||'" and recordID = "'||strip(recordid)||'" and fieldOrdinal = "'|| strip(fieldseq) || '" then  ClinSigComment = "' ||TRIM(trans) || '"; '
into: lablstna separated by ' '
from trscsna2 ;
quit;

data trslabcs;
set raw.lab;
&lablstna.;
run;




***analytevalue;
*翻译后导入;
proc import datafile="&root.\&_mode.\Output\2.Translated_List\translated_All_Lists_&date..xlsx"
out=trslabvNA1
dbms=xlsx replace;getnames=yes;
sheet="LabValue(LAB)";
run;
*改翻译后的变量名为trans;
data trslabvna1;
set trslabvna1;
rename  analytevalue=trans;
run;

*combine unique CN and EN;
proc sql noprint;
create table trslabvna3 as
select a.* ,b.trans from
ndplabvna a left join trslabvna1 b
on a.subject=b.subject and a.recordID=b.recordID 
and a.form=b.form and a.fieldseq=b.fieldseq ;
quit;

*from unique to all obs;
proc sql noprint;
create table trslabvna2 as
select a.*,b.trans 
from trslabvna a left join trslabvna3 b
on a.analytevalue=b.analytevalue;
quit;
*将数值型recordID改为字符型;
data trslabvna2;
set trslabvna2;
rec=put(recordID,best. -l);
ordinal=put(fieldseq,best. -l);
rename  rec=recordID ordinal=fieldseq;
drop recordid fieldseq;
run;
*取替换信息为宏变量;
proc sql noprint;
select  'if subject = "'||trim(subject)||'" and recordID = "'||strip(recordid)||'" and fieldOrdinal = "'|| strip(fieldseq) || '" then  analytevalue = "' ||TRIM(trans) || '"; '
into: lablstna2 separated by ' '
from trslabvna2 ;
quit;
*替换;
data trslabv;
set trslabcs;
&lablstna2.;
run;

***labunits;


*翻译后导入;
proc import datafile="&root.\&_mode.\Output\2.Translated_List\translated_All_Lists_&date..xlsx"
out=trslabuNA1
dbms=xlsx replace;getnames=yes;
sheet="LabUnits(LAB)";run;

*改翻译后的变量名为trans;
data trslabuna1;
set trslabuna1;
rename labunits=trans;
run;

*combine unique CN and EN;
proc sql noprint;
create table trslabuna3 as
select a.* ,b.trans from
ndplabuna a left join trslabuna1 b
on a.subject=b.subject and a.recordID=b.recordID 
and a.form=b.form and a.fieldseq=b.fieldseq ;
quit;

*from unique to all obs;
proc sql noprint;
create table trslabuna2 as
select a.*,b.trans 
from trslabuna a left join trslabuna3 b
on a.labunits=b.labunits;
quit;
*将数值型recordID改为字符型;
data trslabuna2;
set trslabuna2;
rec=put(recordID,best. -l);
ordinal=put(fieldseq,best. -l);
rename  rec=recordID ordinal=fieldseq;
drop recordid fieldseq;
run;
*取替换信息为宏变量;
proc sql noprint;
select  'if subject = "'||trim(subject)||'" and recordID = "'||strip(recordid)||'" and fieldOrdinal = "'|| strip(fieldseq) || '" then  labunits = "' ||TRIM(trans) || '"; '
into: lablstna3 separated by ' '
from trslabuna2 ;
quit;
*替换;
data trslabu;
set trslabv;
&lablstna3.;
run;

/***********通用变量替换*****************************/;
*1.sitename,foldername,insname,datapagename,formname;
*2.analytename （ALS/fields/AnalyteName）,labname;



data lblst;
set LBBI.sheet1;
keep labname translate_Labname;
rename labname=labCN translate_labname=labEN;
run;

data analst;
set alsbi.fields;
where analytename ^= "";
keep formOID fieldOID ordinal analytename translate_analytename;
rename analytename=anaCN  translate_analytename=anaEN;
run;


*does not by domain;

proc sql noprint;
	select 'if form = "' ||trim(formOID)||'" and analytename = "' ||trim(anaCN)||'" then analytename = "'||trim(anaEN)||'" ;'
	into: analst separated by ' '
	from analst;

	select 'if labname = "'||trim(labCN)||'" then labname = "'||trim(labEN)||'" ;' 
	into: lblst separated by ' '
	from lblst;

select 'if FormName = "' || trim(FormNameCN) ||'" then FormName = "'||trim(FormNameEN) ||'" ;'
	into : Fmlst separated by ' '
	from form;

select 'if DataPageName = "' || trim(FormNameCN) ||'" then DataPageName = "'||trim(FormNameEN) ||'" ;'
	into : pglst separated by ' '
	from form;

select 'if FolderName = "' || trim(FolderNameCN) ||'" then FolderName = "'||trim(FolderNameEN) ||'" ;'
	into : Fdlst separated by ' '
	from folder ;

select 'if InstanceName = "' || trim(FolderNameCN) ||'" then InstanceName = "'||trim(FolderNameEN) ||'" ;'
	into : inslst separated by ' '
	from folder where FoldernameCN ^= "计划外访视";

select 'if SiteNumber= "2021-TAZ-00CH1_'||trim(SiteNo)||'" then Site= "'||trim(SiteNameEN)||'" ;'
	into : sitelst separated by ' '
	from sitelst where sitenameCN ^= "";

quit;

*data trans.lab;
data trans.lab;
set trslabu;

&sitelst.;
&inslst.;
&fdlst.;
&pglst.;
&fmlst.;
	if index(InstanceName,"计划外访视")>0 then 
		instancename=prxchange('s/计划外访视/Unscheduled Visit/i',-1,instancename);
	if index(InstanceName,"肿瘤评估访视")>0 then 
		instancename=prxchange('s/肿瘤评估访视/Tumor Assessment Visit/i',-1,instancename);
	if index(InstanceName,"筛选期")>0 then 
		instancename=prxchange('s/筛选期/Tumor Assessment Visit/i',-1,instancename);

	if index(InstanceName,"计划外第")>0 then do;
		instancename1=prxchange('s/计划外第/Unscheduled Visit/i',-1,instancename);
		instancename=prxchange('s/次//i',-1,instancename1);
	end;
	if index(InstanceName,"治疗结束（EOT）")>0 then 
		instancename=prxchange('s/治疗结束（EOT）/End of treatment (EOT)/i',-1,instancename);
&analst.;
&lblst.;
run;
