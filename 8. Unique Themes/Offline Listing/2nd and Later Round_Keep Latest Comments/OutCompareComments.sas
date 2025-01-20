
**Filter页;
/*Pick subjectlist and sitelist from SI*/;
data  filter;
retain site subject;
set new.si;
keep site subject;
label  site= "Site" subject="Subject";
run;
proc sort data=filter;by site subject;run;
**

**目录页;
data  contents;
retain   chk review_instruction_for_DM;
set ftlist;
*N=_N_;
chk=compress('=HYPERLINK("#'||Check_Name||'!R1C1","'||Check_Name||'")');
label chk="Check_Name" N="No.";
KEEP  chk review_instruction_for_DM;
run;
**;

/*ods _all_ close;*/
/*ods excel file="&root.\&_mode.\Output\2021-760-00CH1 Offline Listing_Batch12_%sysfunc(today(),yymmddn8.).xlsx";*/
/**/
/*ods excel options (sheet_name="FilterTab" frozen_headers="on" );*/
/*proc report data=filter;*style(column)=[just=center];*/
/*run;*/
/**/
/*ods excel options(sheet_name="Contents"  frozen_headers="on"  autofilter="all");*/
/*proc report data= contents ;*style(column)={just=center} nowindows; run;*/
/**/
proc export data=filter outfile="&root.\&_mode.\Output\2021-760-00CH1 Offline Listing_Batch12_%sysfunc(today(),yymmddn8.).xlsx"
dbms=xlsx label replace;
sheet="Filter";
run;

proc export data=contents outfile="&root.\&_mode.\Output\2021-760-00CH1 Offline Listing_Batch12_%sysfunc(today(),yymmddn8.).xlsx"
dbms=xlsx label replace;
sheet="Contents";
run;
%macro REPORT(ds,title);
/*ods excel options(sheet_name="&ds."  frozen_headers="on"   embedded_titles="yes" autofilter="all"  absolute_column_width = "150px");*/

/*	proc report data=ot&ds. style(column)={just=center width=200%}  nowindows; */
/*		title "&title.";      */
/*		column _all_;      */
/*		define DM_Comments / display "DM_Comments"  style(header)={ backgroundcolor=Yellow} ;*/
/*		define Issue_Status / display "Issue_Status" style(header)={ backgroundcolor=Yellow} ;*/

proc export data=ot&ds. outfile="&root.\&_mode.\Output\2021-760-00CH1 Offline Listing_Batch12_%sysfunc(today(),yymmddn8.).xlsx"
dbms=xlsx label replace;
sheet="&ds.";
run;


%mend REPORT;
***每个数据集执行%REPORT;
data f;
set ftlist;
IF CHECK_NAME ^= "";
*if check_name="M_SPCHAR";
title=%nrstr(Review_Instruction_for_DM);
run;
data _null_;
set f;
rc=dosubl(cats('%REPORT(',Check_Name,',%NRSTR(',title,'))')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;

/*ods excel close;*/
