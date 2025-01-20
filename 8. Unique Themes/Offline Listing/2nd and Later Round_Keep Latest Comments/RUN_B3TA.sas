dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets lib=work memtype=data kill nolist;quit;run;

********2.Define Macro Variables**************************************;

%let _mode=Prd; *Prd for production environment;
*%let today='25/APR/2022'; * Date of today;
*%let LDate=20221205;*Date of datasets run last time.;
%let date=20241227;*Date of datasets run this time.;
%let LDate=20241129;*Date of datasets run last time.;
%let DMDate=20241129;*Date of DM Comments Files.;

********3.Obtain root*************************************************;
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
/*%let root=%substr(%str(&currentroot),1,%index(%str(&currentroot),%str(\&_mode.\))-1);*/
/*%put &root.;*/

%let currentPath = %scan(&_sasprogramfile.,1,"'");
%put &currentPath.;

%let root=%substr(%str(&currentPath),1,%index(%str(&currentPath),%str(\&_mode.\))-1);
%put &root.;

*new created folder in Data folder named by &date.;
/*options noxwait xmin;*/
/*x "md  ""&root.\&_mode.\Data\&date.""";*/

********4.Obtain raw datasets (Rave,SAS OnDemand, Raw, All)************;
/*libname old "&root.\&_mode.\Data\&Ldate."; * Folder address of datasets to be compared;*/
libname new "&root.\&_mode.\Data\&date."; * Folder address of datasets this time;
libname old "&root.\&_mode.\Data\&LDate."; * Folder address of datasets to be compared;

*Obs or Not Macro;
%macro nobs(ds);

  %local nobs dsid rc err;
  %let err=ERR%str(OR);

  %let dsid=%sysfunc(open(&ds));

  %*---- if open fails then file handle value is zero -----;
  %if &dsid EQ 0 %then %do;
    %put &err: (nobs) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;

  %*---- Open worked so check for an active where clause or a  ----;
  %*---- view and use NLOBSF in that case, otherwise use NOBS. ----;
  %else %do;
    %if %sysfunc(attrn(&dsid,WHSTMT)) or
      %sysfunc(attrc(&dsid,MTYPE)) EQ VIEW %then %let nobs=%sysfunc(attrn(&dsid,NLOBSF));
    %else %let nobs=%sysfunc(attrn(&dsid,NOBS));
    %*-- close the dataset --;
    %let rc=%sysfunc(close(&dsid));
    %*-- reset negative values to zero --;
    %if &nobs LT 0 %then %let nobs=0;
    %*-- return the result --;
&nobs
  %end;
%mend nobs;
/**/
/**keep only dev HUTCHMED02;*/
/*%macro prelist(a);*/
/*data new.&a.;*/
/*set new.&a.;*/
/*where site="HUTCHMED02";*/
/*run;*/
/*%mend prelist;*/
/*proc sql;*/
/*create table prelist as*/
/*select distinct memname from sashelp.vcolumn*/
/*where libname="NEW";*/
/*quit;*/
/**/
/*data _null_;*/
/*set prelist;*/
/*rc=dosubl(cats('%prelist(',memname,')'));*/
/*run;*/

%include  "&root.\&_mode.\Program\B3TA\89.sas";
%include  "&root.\&_mode.\Program\B3TA\90.sas";
%include  "&root.\&_mode.\Program\B3TA\91.sas";
%include  "&root.\&_mode.\Program\B3TA\92.sas";
%include  "&root.\&_mode.\Program\B3TA\93.sas";
%include  "&root.\&_mode.\Program\B3TA\95.sas";
%include  "&root.\&_mode.\Program\B3TA\96.sas";
%include  "&root.\&_mode.\Program\B3TA\97.sas";
%include  "&root.\&_mode.\Program\B3TA\98.sas";
%include  "&root.\&_mode.\Program\B3TA\99.sas";
%include  "&root.\&_mode.\Program\B3TA\100.sas";
%include  "&root.\&_mode.\Program\B3TA\101.sas";
%include  "&root.\&_mode.\Program\B3TA\102.sas";
%include  "&root.\&_mode.\Program\B3TA\103.sas";
%include  "&root.\&_mode.\Program\B3TA\104a.sas";
%include  "&root.\&_mode.\Program\B3TA\104b.sas";
%include  "&root.\&_mode.\Program\B3TA\105ab.sas";

/*%include  "&root.\&_mode.\Program\B3\OUTPUT_B3.sas";*/
