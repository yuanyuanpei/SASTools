
proc import datafile="&root.\&_mode.\Output\2.Translated_List\translated_All_Lists_&date..xlsx"
out=trsUNNA1
dbms=xlsx replace;getnames=yes;
sheet="LBUnits(NoLAB)";run;

data trsunna1;
set trsunna1;
rename  allvalue=trans;
run;

proc sort data=trsunna1;by subject recordID formOID trans;run;
*combine unique CN and EN;
proc sql noprint;
create table trsunna3 as
select a.* ,b.trans from
ndpunna a left join trsunna1 b
on a.subject=b.subject and a.recordID=b.recordID and a.formOID=b.formOID and a.allvar=b.allvar ;
quit;

*from unique to all obs;
proc sql noprint;
create table trsunna2 as
select a.*,b.trans 
from trsunna a left join trsunna3 b
on a.allvalue=b.allvalue;
quit;

data trsunna2;
set trsunna2;
rec=put(recordID,best. -l);
rename  rec=recordID;
drop recordid;
run;

proc sort data=trsunna2 nodupkey;by _all_;run;

*开始替换;
%macro trsun(a);
%if %nobs(raw.&a.) eq 0 %then %do;
data lb.lb&a.;
set spyft.sft&a.;
run;
%end;

%if %nobs(raw.&a.) ne 0 %then %do;
	%let &a.lstna3=;

	proc sql noprint;
	select 'if subject = "'||trim(subject)||'" and recordID = "'||trim(recordid)||'" then '||trim(allvar)||' = "'||strip(trans)||'";'
	into: &a.lstna3 separated by ' '
	from trsunna2 where formOID = %upcase("&a.");
	quit;

	%if %length(&&&a.lstna3) gt 0 %then %do;
	data lb.lb&a.;
	set spyft.Sft&a.;
	&&&a.lstna3.;
	run;
	%end;
	%if %length(&&&a.lstna3) eq 0 %then %do;
	data lb.lb&a.;
	set spyft.sft&a.;
	run;
	%end;
%end;

%mend trsun;

proc sort data=unilst out=ulst(keep=memname) nodupkey;by memname;run;
*所有unilst里面的domain均执行;
data _null_;
set ulst;
rc=dosubl(cats('%trsun(',memname,')'));
run;

*不在unilst的domain不做变换，等于spyft lib中的domain;

proc sql noprint;
select distinct 'data lb.lb'||memname||'; set spyft.sft'||memname||';run;'
into : exenun separated by ' '
from sashelp.vcolumn 
where libname="RAW" and memname not in (select distinct memname from ulst);
quit;

&exenun.;
