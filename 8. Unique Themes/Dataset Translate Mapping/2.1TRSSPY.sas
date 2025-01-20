

proc import datafile="&root.\&_mode.\Output\2.Translated_List\translated_All_Lists_&date..xlsx"
out=trsspyNA1
dbms=xlsx replace;
getnames=yes;
sheet="OtherSpecify";
run;

data trsspyna1;
set trsspyna1;
*rec=put(recordID,best. -l);
rename  allvalue=trans;*rec=recordID;
*drop recordid;
run;

proc sort data=trsspyna1;by subject recordID formOID allvar ;run;
*combine unique CN and EN;
proc sql noprint;
create table trsspyna3 as
select a.* ,b.trans from
ndpspyna a left join trsspyna1 b
on a.subject=b.subject and a.recordID=b.recordID and a.formOID=b.formOID and a.allvar=b.allvar;
quit;

*from unique to all obs;
proc sql noprint;
create table trsspyna2 as
select a.*,b.trans 
from trsspyna a left join trsspyna3 b
on a.allvalue=b.allvalue;
quit;

data trsspyna2;
set trsspyna2;
rec=put(recordID,best. -l);
rename  rec=recordID;
drop recordid;
run;


%macro trsspy(a);
*if no obs in dataset &a.;
%if %nobs(raw.&a.) eq 0  %then %do;
	data OTHSPY.SPY&a.;
	set raw.&a.;
	run;
%end;

%if %nobs(raw.&a.) ne 0 %then %do;

	%let &a.lstna=;

	proc sql noprint ;
	select 'if subject = "'||trim(subject)||'" and recordID = "'||trim(recordid)||'" and ' || TRIM(allvar) ||'_STD = "'|| strip(allcode) || '" then  ' ||TRIM(allvar) || '= "' ||TRIM(trans) || '"; '
	into : &a.lstna separated by ' '
	from trsspyna2 where formOID = %upcase("&a.");
	quit;

	%if %length(&&&a.lstna) gt 0  %then %do;
		data OTHSPY.SPY&a.;
		set raw.&a.;
		&&&a.lstna.;
		run;
	%end;

	%if %length(&&&a.lstna) eq 0 %then %do;
		data othspy.spy&a.;
		set raw.&a.;
		run;
	%end;

%end;
%mend trsspy;


data _null_;
set spylst;
rc=dosubl(cats('%trsspy(',formOID,')'));
run;

proc sql noprint;
select distinct 'data othspy.spy'||memname||'; set raw.'||memname||';run;'
into : exenspy separated by ' '
from sashelp.vcolumn 
where libname="RAW" and memname not in (select formOID from spylst);
quit;

&exenspy.;
