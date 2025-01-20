
proc import datafile="&root.\&_mode.\Output\2.Translated_List\translated_All_Lists_&date..xlsx"
out=trsfreNA1
dbms=xlsx replace;getnames=yes;
sheet="FreeText(NoLAB)";run;

data trsfrena1;
set trsfrena1;
rename allvalue=trans;
run;

proc sort data=trsfrena1;by subject recordID formOID allvar ;run;

proc sql noprint;
create table trsfrena3 as
select a.* ,b.trans from
ndpfrena a left join trsfrena1 b
on a.subject=b.subject and a.recordID=b.recordID and a.formOID=b.formOID and a.allvar=b.allvar;
quit;


proc sql noprint;
create table trsfrena2 as
select a.*,b.trans 
from trsfrena a left join trsfrena3 b
on a.allvalue=b.allvalue;
quit;

data trsfrena2;
set trsfrena2;
rec=put(recordID,best. -l);
rename  rec=recordID;
drop recordid;
run;

proc sort data=trsfrena2 nodupkey;by _all_;run;

%macro trsfree(a);
%if %nobs(raw.&a.) eq 0  %then %do;
	data SPYFT.SFT&a.;
	set OTHSPY.SPY&a.;
	run;
%end;
%if %nobs(raw.&a.) ne 0 %then %do;

	%let &a.lstna2=;

	proc sql noprint;

	select 'if subject = "'||trim(subject)||'" and recordID = "'||trim(recordid)||'" then '||trim(allvar)||' = "'||strip(trans)||'";'
	into: &a.lstna2 separated by ' '
	from trsfrena2 where formOID = %upcase("&a.");
	quit;


	%if  %length(&&&a.lstna2) gt 0 %then %do;
		data SPYFT.sft&a.;
		set othspy.spy&a.;
		&&&a.lstna2.;
		run;
	%end;


	%if %length(&&&a.lstna2) eq 0  %then %do;
		data SPYFT.SFT&a.;
		set OTHSPY.SPY&a.;
		run;
	%end;
%end;

%mend trsfree;

data _null_;
set flst;
rc=dosubl(cats('%trsfree(',formOID,')'));
run;

proc sql noprint;
select distinct 'data spyft.sft'||memname||'; set othspy.spy'||memname||';run;'
into : exenfre separated by ' '
from sashelp.vcolumn 
where libname="RAW" and memname not in (select distinct formOID from flst);
quit;

&exenfre.;




