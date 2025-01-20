
***Open/Answered query detail***;
data query;
retain sitename StudyEnvironmentSiteNumber subjectname folder form field log_ QryOpenDateLocalized qryopenby querytext
markinggroupname  QryResponseDateLocalized qryrespndby answertext QryClosedDateLocalized  qryclosedby name;
set querydetail;
keep sitename StudyEnvironmentSiteNumber subjectname folder form field log_ QryOpenDateLocalized qryopenby querytext
markinggroupname  QryResponseDateLocalized qryrespndby answertext QryClosedDateLocalized  qryclosedby name;
run;

data oqry aqry;
set query;
curr=today();
format curr yymmdd8.;

if QryResponseDateLocalized=. and QryClosedDateLocalized =. then do;
	day=curr-QryOpenDateLocalized;
	no='Y';
	output oqry;
end;

if QryResponseDateLocalized ^=. and QryClosedDateLocalized =. then do;
	day=curr-QryResponseDateLocalized;
	na='Y';
	output aqry;
end;

run;


*vis date:与PageNotSDV类似，添加actual start date;
**Open query;
***先加group0(visit date)和group1(非logline);
proc sort data=oqry;by subjectname folder;run;
proc sort data=dcodate1 (rename=(subject=subjectname instance=folder));by subjectname folder;run;
data oqry1;
merge oqry(in=a) dcodate1;
by subjectname folder;
if a;
run;
***再加group2(logline);
proc sort data=oqry1;by subjectname folder form log_;run;
proc sort data=dcodate2 (rename=(subject=subjectname instance=folder datapage=form log=log_));by subjectname folder form log_;run;

data oqry2;
merge oqry1(in=a) dcodate2;
by subjectname folder form log_;
if a;
visdat_raw = coalescec (date_raw,date_raw2);
drop date_raw date_raw2;
run;

proc sort data=oqry2 nodupkey; by _all_;run;

********************;
**Answer query;
***先加group0(visit date)和group1(非logline);
proc sort data=aqry;by subjectname folder;run;
proc sort data=dcodate1;* (rename=(subject=subjectname instance=folder));by subjectname folder;run;
data aqry1;
merge aqry(in=a) dcodate1;
by subjectname folder;
if a;
run;
***再加group2(logline);
proc sort data=aqry1;by subjectname folder form log_;run;
proc sort data=dcodate2 ;*(rename=(subject=subjectname instance=folder datapage=form log=log_));by subjectname folder form log_;run;

data aqry2;
merge aqry1(in=a) dcodate2;
by subjectname folder form log_;
if a;
visdat_raw = coalescec (date_raw,date_raw2);
drop date_raw date_raw2;
run;
proc sort data=aqry2 nodupkey; by _all_;run;
*********************;
data openqrylist;set oqry2;drop no na;run;
data ansqrylist;set aqry2;drop na no;run;
proc sort data=openqrylist;by subjectname folder form field;run;
proc sort data=ansqrylist;by subjectname folder form field;run;
data openqrylist;
set openqrylist;
format TOD date11.;
TOD=today();
label TOD="Run Date" visdat_raw="Actual_Start_Date";
label day="Open_Query_Pending_Aging" curr="Current_Date";
run;
data ansqrylist;
set ansqrylist;
format TOD yymmdd8.;
TOD=today();
label TOD="Run Date" visdat_raw="Actual_Start_Date";
label day="Answered_Query_Pending_Aging" curr="Current_Date";

run;


***Query Summary*****;
data noqry0 noqry1 noqry2;
set oqry;
if day <5 then do;no0='Y';output noqry0;end;
else if day >=5 and day <= 10 then do;no1='Y';output noqry1;end;
else do; no2='Y';output noqry2;end;
run;

data naqry0 naqry1 naqry2;
set aqry;
if day <5 then do;na0='Y';output naqry0;end;
else if day >=5 and day <= 10 then do;na1='Y';output naqry1;end;
else do; na2='Y';output naqry2;end;
run;

proc sql;
create table nsubj as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count( distinct subjectname) as nsubj
from query
group by StudyEnvironmentSiteNumber;

create table no as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(no) as no
from oqry
group by StudyEnvironmentSiteNumber;

create table no0 as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(no0) as no0
from noqry0
group by StudyEnvironmentSiteNumber;

create table no1 as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(no1) as no1
from noqry1
group by StudyEnvironmentSiteNumber;

create table no2 as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(no2) as no2
from noqry2
group by StudyEnvironmentSiteNumber;

create table na as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(na) as na
from aqry
group by StudyEnvironmentSiteNumber;

create table na0 as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(na0) as na0
from naqry0
group by StudyEnvironmentSiteNumber;

create table na1 as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(na1) as na1
from naqry1
group by StudyEnvironmentSiteNumber;

create table na2 as
select distinct sitename,StudyEnvironmentSiteNumber as sitenum format $5.,count(na2) as na2
from naqry2
group by StudyEnvironmentSiteNumber;
quit;

proc sort data=nsubj;by sitenum ;run;
proc sort data=no;by sitenum ;run;
proc sort data=no0;by sitenum  ;run;
proc sort data=no1;by sitenum  ;run;
proc sort data=no2;by sitenum  ;run;
proc sort data=na0;by sitenum  ;run;
proc sort data=na;by sitenum  ;run;
proc sort data=na1;by sitenum  ;run;
proc sort data=na2;by sitenum  ;run;

data nall;
length sitenum $5.;
merge nsubj no no0 no1 no2 na na0 na1 na2;by sitenum;run;

data nall2;
set nall;run;

proc sql;
insert into nall(sitename,sitenum,nsubj, no, no0, no1, no2, na, na0, na1, na2)
select '' as sitename,'Total' as sitenum format $5.,sum(nsubj) as nsubj,sum(no) as no,sum(no0) as no0,
sum(no1) as no1,sum(no2) as no2,sum(na) as na,sum(na0) as na0,sum(na1) as na1,sum(na2) as na2
from nall2;
quit;

data qrysum;
retain sitename sitenum nsubj  no no0 no1  no2  na na0 na1  na2;
set nall;
array tm[*] nsubj--na2;
do i = 1 to dim(tm);
if tm[i]=. then tm[i]=0;
end;
label SiteNum="Site_Number" nsubj="#_of_Subjects" no="#_of_Open_Query"
 no0="#_of_Open_Query_Pending_Aging(<5)"
 no1="#_of_Open_Query_Pending_Aging(5-10)"
 no2="#_of_Open_Query_Pending_Aging(>10)"
 na="#_of_Answered_Query"
 na0="#_of_Answered_Query_Pending_Aging(<5)"
 na1="#_of_Answered_Query_Pending_Aging(5-10)"
 na2="#_of_Answered_Query_Pending_Aging(>10)";
keep sitename sitenum nsubj  no no0 no1  no2  na na0 na1  na2;
run;

data qrysum;
set qrysum;
format TOD date11.;
TOD=today();
label TOD="Run Date";
run;

**User list;
data userlist;
set userlist;
format TOD date11.;
TOD=today();
label TOD="Run Date";
run;
