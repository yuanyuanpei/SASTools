*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2023-506-00CH1
Program Name    :  Medical Listing Project: 2.DropSysVar.sas
Program Address :  F:\Project\506\2023-506-00CH1\DM\3-4 Ongoing\37_MR_Data_Listing\Dev\Program
Author Name     :  Yuanyuan Pei/Ender Wu
Creation Date   :  2024/6/13
Tester Name     :  Echo Gu
Description     :  This is the 3rd program for Medical Listing Project.
Modification    :  
*********************************************************************************************;

*3.output;
%macro nobs(ds);
  %local nobs dsid rc err;
  %let err=ERR%str(OR);
  %let dsid=%sysfunc(open(&ds));
  %if &dsid EQ 0 %then %do;
    %put &err: (nobs) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;

  %else %do;
    %if %sysfunc(attrn(&dsid,WHSTMT)) or
      %sysfunc(attrc(&dsid,MTYPE)) EQ VIEW %then %let nobs=%sysfunc(attrn(&dsid,NLOBSF));
    %else %let nobs=%sysfunc(attrn(&dsid,NOBS));
    %let rc=%sysfunc(close(&dsid));
    %if &nobs LT 0 %then %let nobs=0;
&nobs
  %end;
%mend nobs;

/*Pick subjectlist and sitelist from SI*/;
data filter;
retain site subject;
set new.resi;
keep site subject;
label site= "Site" subject="Subject" ;
run;
proc sort data=filter;by site subject;run;

ods _all_ close;
ods excel file="&root.\&_mode.\Output\2021-760-00CH1_Medical Listing_&date..xlsx";

/*1.Output subjectlist and sitelist in sheet1 for filtering*/;
ods excel options (sheet_name="FilterTab" frozen_headers="on" );
proc report data=filter;*style(column)=[just=center];
run;
/*proc export data=filter outfile="&root.\&_mode.\Output\2021-760-00CH1_Medical Listing_&date..xlsx"*/
/*dbms=xlsx label replace;*/
/*sheet="FilterTab";*/
/*run;*/

/*2.Output domain contents for reference*/;
ods excel options (sheet_name="Contents" frozen_headers="on" );
proc report data=contents;*style(column)=[just=center];
run;
/*proc export data=contents outfile="&root.\&_mode.\Output\2021-760-00CH1_Medical Listing_&date..xlsx"*/
/*dbms=xlsx label replace;*/
/*sheet="Contents";*/
/*run;*/

/*proc sql noprint;*/
/*select count(distinct memname) into: nn from sashelp.vcolumn */
/*where libname=%upcase("work") and memname like "RE%";*/
/**/
/*select distinct memname into:mem1-:mem%left(&nn.) from sashelp.vcolumn */
/*where libname=%upcase("work") and memname like "RE%";*/
/*quit;*/
/**/
/*%put &count &rem &shtnm;*/

/*3.Output all domains separately*/;
%macro expall(ds,shtnm);
ods excel options (sheet_name="&shtnm" frozen_headers="on");
%if %nobs(&ds.)=0 %then %do;
	data nob;
		length desc $50;
		desc="No Record Found";
		button="";
		button2= "";
		label desc="Result" button=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))
		button2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));
	run;

	proc report data=nob nowindows;
	column desc button;
    define desc  / display ""  style(column)=[just=center backgroundcolor=Yellow font_weight=bold width=5.0cm height=1.0cm];
	run;
/*	proc export data=nob outfile="&root.\&_mode.\Output\2021-760-00CH1_Medical Listing_&date..xlsx"*/
/*	dbms=xlsx label replace;*/
/*	sheet="&shtnm.";*/
/*	run;*/

%end;
%else %do;
	proc sort data=&ds.;by subject;run;
*///Add [Back to Contents] button at the end of each dataset.///;
	data &ds.;
	set &ds.;
/*	if _n_=1 then button='=HYPERLINK("#Contents!R1C1","Back to Contents")';*/
/*	ELSE BUTTON='';*/
	button= "";button2= "";
	label button=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))
	button2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));
	run;
*////;
	proc report data=&ds. style(column)=[just=center] nowindows;
*根据医学Chen Jian的要求，去掉黄色/灰色高亮,by pyy/2022-12-6;
		*compute Flag;
			*if Flag='New/Changed' then call define(_row_, "style", "style=[backgroundcolor=Yellow]");
			*if Flag='Delete' then call define(_row_, "style", "style=[backgroundcolor=Gray]");
		*endcomp;
	run;
/*	proc export data=&ds. outfile="&root.\&_mode.\Output\2021-760-00CH1_Medical Listing_&date..xlsx"*/
/*	dbms=xlsx label replace;*/
/*	sheet="&shtnm.";*/
/*	run;*/
%end;

%mend;

data _null_;
set file;
if shtnm ^= "LAB";
rc=dosubl(cats('%expall(',dname,',',shtnm,')'));
run;

ods excel close;

*LAB表单独导出;
data relab2;
set relab;
recordDate=datepart(recordDate);
format recordDate date11.;
button= "";button2= "";
label button=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))
	button2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));
label recordDate = "Sample Collection Date";
run;

proc export data=RELAB2 outfile="&root.\&_mode.\Output\2021-760-00CH1_Medical Listing_&date..xlsx"
	dbms=xlsx label replace;
	sheet="LAB";
run;

%macro drp(a);
%if &date.=&Ldate. %then %do;
proc sql;drop table new.&a.;quit;
%end;
%else %do;
proc sql;drop table new.&a.,old.&a.;quit;
%end;
%mend drp;

data _null_;
set file;
rc=dosubl(cats('%drp(',dname,')'));
run;
