*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: Run.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Prd\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Xiangyun Xie/Liying Lu
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;
*SAS Unicode, regular, use prod view;
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets nolist memtype=all library=work kill;
quit;

***Macro variables that may need modification:;
%let _mode=Prd;* Dev for development programs and Prod for production programs.;
%let date=20250113; * The date that you need to run the status report.;
%let _LDate=20241231;*The date of Last time you run the status report;

*current root����EG�в��ã�����current path��;
/*%macro currentroot;*/
/*	%global currentroot;*/
/*	%let currentroot=%sysfunc(getoption(sysin));*/
/*	%if "&currentroot" eq "" %then %do;*/
/*		%let currentroot=%sysget(SAS_EXECFILEPATH);*/
/*	%end;*/
/*%mend;*/
/**/
/*%currentroot;*/
/*%put &currentroot.;*/

/*%let root = %substr(%str(%sysfunc(dequote(&_CLIENTPROJECTPATH.))), 1, %index(%str(%sysfunc(dequote(&_CLIENTPROJECTPATH.))), %str(\&_mode.\))-1);*/

%let currentPath = %scan(&_sasprogramfile.,1,"'");
%put &currentPath.;

%let root=%substr(%str(&currentPath),1,%index(%str(&currentPath),%str(\&_mode.\))-1);
%put &root.;

*new create folder in Data folder named by &_Date.;
/*options noxwait xmin;*/
/*x "md  ""&root.\&_mode.\Data\&date.""";*/
/**status tracking.xlsx was copied to the new folder;*/
/*x "xcopy /y ""&root.\&_mode.\Data\&_LDate.\Status_tracking.xlsx"" ""&root.\&_mode.\Data\&date.\""";*/




****Method 1****;
%include "&root.\&_mode.\Program\EG0.Data.sas";
%include "&root.\&_mode.\Program\1.SubjectDetail.sas";
%include "&root.\&_mode.\Program\2.MissingPage.sas";
%include "&root.\&_mode.\Program\2.1MissingDLT.sas";
/*Run missingTA.sas alone*/; 
%include "&root.\&_mode.\Program\3.MissingTA2.sas";

/*Continue the %include*/;
%include "&root.\&_mode.\Program\4.MissingEX.sas";
%include "&root.\&_mode.\Program\5.MissingPageSum.sas";
%include "&root.\&_mode.\Program\6.PageNotSDV.sas";
%include "&root.\&_mode.\Program\6.5QueryList.sas";

%include "&root.\&_mode.\Program\7.SubjectTotal.sas";
%include "&root.\&_mode.\Program\7.5 KPRunDate.sas";
%include "&root.\&_mode.\Program\8.Output.sas";

/*****Method 2,****;*/
/*filename yyy pipe "dir ""&root.\&_mode.\Program"" /b";*/
/*data pname;*/
/*infile yyy truncover;*/
/*input @1 pnm $200.;*/
/*if index(pnm,"Run")=0;*/
/*run;*/
/**/
/*%macro xinclu(a);*/
/*%include "&root.\&_mode.\Program\&a.";*/
/*%mend xinclu;*/
/**/
/*data _null_;*/
/*set pname;*/
/*rc=dosubl(cats('%xinclu(',pnm,')'));*/
/*run;*/

/*****Method 3****;*/
*Fail;
/*filename yyy pipe "dir ""&root.\&_mode.\Program"" /b";*/
/*data pname;*/
/*infile yyy truncover;*/
/*input @1 pnm $20.;*/
/*if index(pnm,"Run")=0;*/
/*run;*/
/**/
/*proc sql  noprint;*/
/*select pnm,count(pnm) into*/
/*:pnms separated by " ", */
/*:count */
/*from pname;quit;*/
/*%put &pnms.;%put &count;*/
/**/
/*%macro xinclu(a);*/
/*%include "&root.\&_mode.\Program\&a.";*/
/*%mend xinclu;*/
/*fail;*/
/*%macro loops;*/
/*%do i=1 %to &count;*/
/*%let prog=%scan(&pnms,&i,%str( ));*/
/*%put &i.;*/
/*%put &prog.;*/
/*%xinclu(&prog.);*/
/*%end;*/
/*%mend loops;*/
/*%loops;*/




