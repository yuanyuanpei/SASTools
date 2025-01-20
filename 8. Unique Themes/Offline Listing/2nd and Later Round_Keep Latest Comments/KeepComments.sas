
*Input all lastlist with DMcomments;
*%put "&root.\&_mode.\Output\2021-760-00CH1 Offline Listing &LDate. plus.xlsx" ;
*先用VBAClear button去掉筛选，再用ClearTitle button批量删掉title行;
proc contents data = WORK._all_ out=CC(keep=memname name);quit;

/*data cc2;set CC; where find(memname,'M_')>0;where name = "desc";run;*/

%macro inptLast(a);
proc import datafile="&root.\&_mode.\Data\DM Comments\2021-760-00CH1 Offline Listing_Batch12_&DMDate._plus.xlsx" 
out=L&a.
dbms=xlsx replace;getnames=yes;sheet="&a.";
run;

*若L&a.中没有recordid变量（说明L&a.为空，含desc变量），则手动添加一个recordid=.;
data L&a.;
set L&a.;
recordid2=input(recordid,best12.);
drop recordid;
rename recordid2=recordid;
run;

%mend inptLast;

data _null_;
set f;
rc=dosubl(cats('%inptLast(',Check_Name,')')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;
%inptLast(M_OTHSPFY)
proc sql noprint;
create table M_null as
select distinct memname from CC
where name = "desc" and upcase(memname) like "M_%" and find(memname,'_')>0;

create table toJoin as
select distinct memname from CC
where upcase(memname) like "M_%" and find(memname,'_')>0 and substr(upcase(memname),1,2) = "M_"
and memname not in (select memname from M_null) and memname in (select check_name as memname from ftlist)
and MEMNAME ^= "M105_RSLU07B";

quit;
*each by each;
/*判断LM和M中是否含有desc;*/
%macro toJoin(a);

*M不含desc则left join上次的，保留上次的DMcom(即本次的数据集不为空);
proc sql;
create table t&a. as
select distinct &a..*,L&a..dm_comments,L&a..issue_status 
from &a. left join L&a.
on &a..recordID=L&a..recordID;*LM中已经加了recordid变量，且值为.，所以也可以join;
quit;
%mend toJoin;
%toJoin(M_OTHSPFY)
data _null_;
set tojoin;
rc=dosubl(cats('%toJoin(',memname,')')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;

/*否则TM=M;*/*若本次数据集为空，那么导出本次的，弃掉上次的;
%macro M_null(a);
data t&a.;
set &a.;
DMCom= "";
DMstatus= "";
label DMcom="DM_Comments" DMstatus= "Issue_Status";
run;

%mend M_null;

data _null_;
set m_null;
rc=dosubl(cats('%M_null(',memname,')')); 
run;
%M_null(M_OTHSPFY)
%macro kpold(a);
data ot&a.;
set t&a.;
*drop button button2;
*如果flag=changed，说明同一条recordID new和old的数据集中有变化，此时不需要保留old的DMcomments;
if flag ^= "Old" then do;
DM_Comments= "" ;
Issue_Status= "";
end;
bttn="";
bttn2= "";
				
label bttn=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))
	bttn2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));

run;
proc sort data=ot&a. nodupkey;by _all_;run;
%mend kpold;
 data _null_;
set f;
rc=dosubl(cats('%kpold(',Check_Name,')')); 
run;
%kpold(M_OTHSPFY)
