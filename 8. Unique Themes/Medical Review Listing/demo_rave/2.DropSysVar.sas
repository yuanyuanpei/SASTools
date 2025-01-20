********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2023-506-00CH1
Program Name    :  Medical Listing Project: 2.DropSysVar.sas
Program Address :  F:\Project\506\2023-506-00CH1\DM\3-4 Ongoing\37_MR_Data_Listing\Dev\Program
Author Name     :  Yuanyuan Pei/Ender Wu
Creation Date   :  2024/6/13
Tester Name     :  Echo Gu
Description     :  This is the 2nd program for Medical Listing Project.
Modification    :  
*********************************************************************************************;

*2.update raw dataset to drop variables;
%macro upd(a);
*//////////////////Calculate CCR in LBB//////////////////////////;
data dm;
set &a..dm;
keep subject age sex;
run;

data vswg;
set &a..vswg;
keep subject instancename folderseq vswg;
run;

data lbb;
set &a..lbb;
keep subject instancename folderseq CR CR_UN;
run;

proc sort data=dm; by subject;run;
proc sort data=vswg;by subject;run;

data dmwg;
merge dm vswg;
by subject;
run;

proc sort data=dmwg;by subject instancename;run;
proc sort data=lbb;by subject instancename;run;

data mg;
merge dmwg lbb(in=a);
by subject instancename;
run;

proc sort data=mg;by subject folderseq instancename;run;


data fill;
length tmp1 - tmp3 $30.;
set mg;
by subject ;
retain tmp1 - tmp3;
array char age sex vswg;
array tmp tmp1 - tmp3;
if subject=lag(subject) and index(instancename,"Unscheduled")=0 then do;
	do i=1 to 3;
		if char[i] ^='' then tmp[i]=char[i];
		else char[i]=tmp[i];
	end;
end;

drop i tmp:;
run;

data CCR;
set fill;
format CCR 5.1;
if CR_UN ="umol/L" then do;
	if SEX="Male" then CCR=((140-input(AGE,best12.))*input(VSWG,best12.)*1.23)/(input(CR,best12.));
	if SEX="Female" then CCR=((140-input(AGE,best12.))*input(VSWG,best12.)*1.23*0.85)/(input(CR,best12.));
end;
if CR_UN ="mg/dl" then do;
	if SEX="Male" then CCR=((140-input(AGE,best12.))*input(VSWG,best12.))/(input(CR,best12.)*72);
	if SEX="Female" then CCR=((140-input(AGE,best12.))*input(VSWG,best12.)*0.85)/(input(CR,best12.)*72);
end;
run;

proc sort data=&a..lbb;by subject folderseq instancename CR;run;
proc sort data=ccr;by subject folderseq instancename CR;run;

data &a..lbb;
merge &a..lbb(in=a) ccr;
by subject folderseq instancename CR;
if a;
run;

*/////////////End Calculate CCR in LBB////////////////////////////;

proc contents data=&a.._all_ out=ds1(keep=memname name) DIRECTORY NOPRINT MEMTYPE=data CENTILES;run;

data x1 xlab;
set ds1;
*LAB:;
if memname="LAB" then do;
	if name not in ('SiteNumber','Site','Subject','DataPageName',
	'FolderName','InstanceName','RecordDate','Form','FormName',
'fieldOrdinal','AnalyteName','AnalyteValue','LabLow','LabHigh','LabUnits',
'LabFlag','ClinSigValue','ClinSigComment') then dp=name;
output xlab;
end;
*else;
else do;
	UP=upcase(NAME);
	if index(name,'_STD')>0 then dp=name;
	if UP ^= name and name not in ('SiteNumber','Site','Subject','DataPageName',
	'FolderName','InstanceName','RecordPosition') then dp=name; 
	if dp ^='';
output x1;
end;
run;

proc transpose data=x1 out=out;var dp;by memname;run;
proc transpose data=xlab out=outlab;var dp;by memname;run;

*concate all variables needed to be deleted;
data out2;
length list mds $1500.;
set out outlab;
*all col variables in array;
array dplt[*] $50 COL:;
*list variable= col1 col2 col3...;
call catx(" ",list,of dplt[*]);
*mds=new.ae(drop=ae_col1 ae_col2...);
mds=catt("&a..",memname,"(drop=",list,")");
keep memname list mds;
run;

proc sql noprint;
select memname,mds 
into  :nm1-, :md1- 
from out2;
quit;


%do i =1 %to &sqlobs;
data &a..re&&nm&i;
set &&md&i.;
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
run;
%end;


*RE-order;
data &a..relbb;
retain Subject Site Sitenumber InstanceName FolderName DataPageName RecordPosition LBPERF
LBDAT BUN BUN_UN UREA UREA_UN CR CR_UN AGE SEX VSWG CCR ;
set &a..relbb;
run;


%mend upd;
%upd(new)
%upd(old)

*find all memnames whose names begin with RE;
proc sql noprint;
create table file as
select distinct memname as dname,substr(memname,3) as shtnm from sashelp.vcolumn
where libname="NEW" and memname like "RE%" ;*and memname ^= "RELAB";
quit;

*Adding NEW/OLD Flag;
*2023/10/23:Adding NEWADD/DELETE/UPDATE_VAR Flag,see 2.1 DropSysVarNew;
%Macro addflag(a);
*sort;
proc sort data=new.&a.;by _all_;run;
proc sort data=old.&a.;by _all_;run;
*merge;
%put &date.;
%put &Ldate.;
%if &date.=&Ldate. %then %do;
data &a.;
	set new.&a.;
	length flag $20;
	flag="First Round Data";
	date="&date.";
	label  flag="Change status" date="Date of Data";
run;
%end;

%else %do;
data &a.;
	merge new.&a.(in=a) old.&a.(in=b);
	by _all_; 
	length flag $20;
	if a and not b then do;flag="New/Changed";date="&date.";end;
	if a and b then do;FLAG="Old"; date="&LDate.";end;
	if b and not a then do;FLAG="Delete";date="&LDate.";end;
	*output;
	label  flag="Change status" date="Date of Data";
run;
%end;
%mend addflag;

data _null_;
set file;
rc=dosubl(cats('%addflag(',dname,')'));
run;

*Adding Subject Status;
data tmp1; set new.dssf;keep subject dssfyn;run;
data tmp2; set new.dsic;keep subject icfdat;run;
data tmp3; set new.dseot;keep subject eotdat;run;
data tmp4; set new.dseos;keep subject eosdat;run;

proc sort data=tmp1;by subject;run;
proc sort data=tmp2;by subject;run;
proc sort data=tmp3;by subject;run;
proc sort data=tmp4;by subject;run;

data subjsta;
merge tmp1 tmp2 tmp3 tmp4;
by subject;
if DSSFYN='No' then Status='Screen Failed';
if DSSFYN='Yes' then do;
	if eosdat ^='' then Status='EOS';
	else if eotdat ^='' then Status='EOT';
	else Status = 'Enrolled';
end; 
if DSSFYN='' then do;
	if icfdat ^='' then Status='Screening';
end;
keep subject status;
run;

proc sort data=subjsta;by subject;run;

%macro addss(a);
proc sort data=&a.;by subject;run;
data &a.;
retain site sitenumber subject status;
merge &a.(in=m) subjsta;
by subject;
if m;
run;
%mend addss;

data _null_;
set file;
rc=dosubl(cats('%addss(',dname,')'));
run;




