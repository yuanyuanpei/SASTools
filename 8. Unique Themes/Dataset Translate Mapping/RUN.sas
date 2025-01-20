
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets lib=work memtype=data kill nolist;quit;

%let _mode=Prd; *Prd for production environment;
%let date=20221207; *Date of this time(data folder name);

%macro currentroot;
	%global currentroot;
	%let currentroot=%sysfunc(getoption(sysin));
	%if "&currentroot" eq "" %then %do;
	%let currentroot=%sysget(SAS_EXECFILEPATH);
%end;
%mend;

%currentroot;
%put &currentroot.;
%let root=%substr(%str(&currentroot),1,%index(%str(&currentroot),%str(\&_mode.\))-1);
%put &root.;


*new create folder in Data folder named by &_Date.;
options noxwait xmin;
x "md  ""&root.\&_mode.\Output\1.List""";
x "md  ""&root.\&_mode.\Output\2.Translated_List""";
x "md  ""&root.\&_mode.\Output\3.TRANS\&date.""";
x "md  ""&root.\&_mode.\Output\4.Validation\&date.""";
x "md  ""&root.\&_mode.\Output\i_OTHSPY\&date.""";
x "md  ""&root.\&_mode.\Output\i_SPYFT\&date.""";
x "md  ""&root.\&_mode.\Output\i_LB\&date.""";
x "md  ""&root.\&_mode.\Output\i_COMP\&date.""";

*Inport ALS and raw datasets;*try 2021-TAZ-00CH1, CN->EN;
*需要将raw datasets的所有变量扩容先，否则会在后续替换时出现截断问题;

libname raw cvp   "&root.\&_mode.\Data\&date." cvpmultiplier=3.5;
libname TRANS "&root.\&_mode.\Output\3.TRANS\&date.";

libname OTHSPY "&root.\&_mode.\Output\i_OTHSPY\&date.";
libname SPYFT  "&root.\&_mode.\Output\i_SPYFT\&date.";
libname LB     "&root.\&_mode.\Output\i_LB\&date.";
libname COMP   "&root.\&_mode.\Output\i_COMP\&date.";

libname ALSBI xlsx "&root.\&_mode.\Document\&date.\2021-TAZ-00CH1_ALS_v1.1_CNEN_20221206.xlsx";
libname SITEBI xlsx "&root.\&_mode.\Document\&date.\2021-TAZ-00CH1_Site_CNEN_20221206.xlsx";
libname LBBI xlsx "&root.\&_mode.\Document\&date.\2021-TAZ-00CH1_Labs_CNEN_20221206.xlsx";

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

*///////Step1.Get all lists///////////////////////////////////;
%include "&root.\&_mode.\Program\0.PREP.sas";
%include "&root.\&_mode.\Program\1.1LSTSPY.sas";
%include "&root.\&_mode.\Program\1.2LSTFRE.sas";
%include "&root.\&_mode.\Program\1.3LSTLBUN.sas";
%include "&root.\&_mode.\Program\1.4LSTLAB.sas";
%include "&root.\&_mode.\Program\1.5OUTLST.sas";

*///////Step2.Translate all lists///////////////////////////////////;
/*https://fanyi.atman360.com/file*/
/*账号：xiangyunx@hutch-med.com*/
/*初始密码: @~yMTRb~93#41Nsa*/

*///////Step3.Import all translated lists and map///////////////////;
%include "&root.\&_mode.\Program\2.1TRSSPY.sas";
%include "&root.\&_mode.\Program\2.2TRSFRE.sas";
%include "&root.\&_mode.\Program\2.3TRSLBUN.sas";
%include "&root.\&_mode.\Program\2.4TRSLAB.sas";

*///////Step4.Map all remains///////////////////////////////////////;
%include "&root.\&_mode.\Program\3.ALLCOM.sas";

*///////Step5.Validation///////////////////////////////////////;
%include "&root.\&_mode.\Program\4.SpecialCharacter.sas";

*建议重启一个SAS unicode专门用来run下面的程序;
%include "&root.\&_mode.\Program\5.Compare.sas";



*//////Step6. Copy and Paste all outputs from desktop to F: Drive///;
**1. datasets;
libname mylib 'C:\Users\yuanyuanp\Desktop\TAZ1\Prd\Data\20221207';
libname Flib 'F:\Project\Taz\2021-Taz-00CH1\DM\2021-Taz-00CH1 DM\7 Data\Translate_Test\Prd\Data\20221207';
/*proc copy in=Flib out=mylib;* import;*/
/*run;*/
proc copy in=mylib out=Flib;* import;
run;

**2. files;
%let mypath=C:\Users\yuanyuanp\Desktop\TAZ1\Prd;
%let Fpath=F:\Project\Taz\2021-Taz-00CH1\DM\2021-Taz-00CH1 DM\7 Data\Translate_Test\Prd;

options noxwait xmin;
x "xcopy /y &mypath.\1.List\All_Lists_20221207.xlsx  &Fpath.\1.List\";
