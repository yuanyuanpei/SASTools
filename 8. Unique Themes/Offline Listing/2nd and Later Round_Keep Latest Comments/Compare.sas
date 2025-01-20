
libname old "&root.\&_mode.\Data\&LDate."; * Folder address of datasets to be compared;
/*libname new "&root.\&_mode.\Data\&date."; * Folder address of datasets this time;*/
proc import datafile="&root.\&_mode.\Document\TitleList.xlsx" 
out=ftlist
dbms=xlsx replace;
getnames=yes;
sheet="B12";
run;
***每个数据集执行%REPORT;
data f;
set ftlist;
IF CHECK_NAME ^= "";
keep check_name;
run;

****先判断NEW数据集是否为空，若为空，加desc;
%macro NEWOBS(a);
*如果本次listing结果为空数据集;
%if %nobs(new.&a.)=0 %then %do;
	data new.&a.;
	    length desc $200;
	    desc="No record Found";
/*		button="";*/
/*		button2= "";*/
		label desc="Result" ;
/*		button=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))*/
/*		button2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));*/
    run;
%end;
%if %nobs(new.&a.) ^= 0 %then %do;
	data new.&a.;
		set new.&a.;
/*		button= "";button2= "";*/
/*		label button=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))*/
/*		button2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));*/
	run;
%end;
%mend NEWOBS;
proc print data=f;run;
%NEWOBS(M_OTHSPFY)
data _null_;
set f;
rc=dosubl(cats('%NEWOBS(',Check_Name,')')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;

**再分别讨论new/old数据集是否为空的情况;
proc contents data = new._all_ out=aa(keep=memname name);quit;
proc contents data = old._all_ out=bb(keep=memname name);quit;

proc sql noprint;
create table new_null as
select distinct memname from aa 
where name = "desc";

create table old_null as
select distinct memname from bb
where name = "desc";

create table toKeepNew as
select distinct memname from new_null
union
select distinct memname from old_null;

create table toMerge as
select distinct memname from aa 
where upcase(memname) like "M_%"
	except
select distinct memname from toKeepNew
;
quit;

%Macro toMerge(a);
	*sort;
	proc sort data=new.&a.;by _all_;run;
	proc sort data=old.&a.;by _all_;run;
data &a.;
merge new.&a.(in=a) old.&a.(in=b);
by _all_; 
length flag $20;
if a and not b then do;flag="New/Changed";date="&date.";end;
if a and b then do;FLAG="Old"; date="&LDate.";end;
if b and not a then do;FLAG="Delete";date="&LDate.";end;
*output;
label  flag="Change status" date="Date of Data";
label recordID= "recordID";
drop DMcom DMstatus;
run;
%mend toMerge;

%toMerge(M_OTHSPFY)
data _null_;
set toMerge;
rc=dosubl(cats('%toMerge(',memname,')')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;

%macro toKeepNew(a);
data &a.;
length flag $20;
set new.&a.;
flag = "NEW";
date="&date.";
recordid=.;
label  flag="Change status" date="Date of Data";
label recordID= "recordID";
drop DMcom DMstatus;
run;
%mend toKeepNew;

%toKeepNew(M_OTHSPFY)
data _null_;
set toKeepNew;
rc=dosubl(cats('%toKeepNew(',memname,')')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;

*****得到的work.M_XXX即可用于与上一轮的DMcom文件进行mapping;
