*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Medical Listing Program: Run.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\37_MR_Data_Listing\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/3/18
Validator Name  :  Xiangyun Xie/Liying Lu
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Modification    :  2023/8/29 from Qiu Shenye:根据收集项目组的反馈，MDR需要更新Lab数据�?
                   需求：添加实验室检查的“sample collection date“，”normal range“，”异常值的判定及填写的CS comments“�?
                   不用关联AE/MH/other，仅需要在saslisting里lab的基础上加record date，lblow labhigh labunits labflag和cssignifi cscomments;
*********************************************************************************************;
*SAS UNICODE, RAW, Use Prd Views;
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets lib=work memtype=all kill nolist;quit;run;

%let _mode=Dev; *Prd for production environment;
%let date=20241227; *Date of this time(data folder name);
%let Ldate=20241129; *Date of last time(data folder name);

/*%macro currentroot;*/
/*	%global currentroot;*/
/*	%let currentroot=%sysfunc(getoption(sysin));*/
/*	%if "&currentroot" eq "" %then %do;*/
/*	%let currentroot=%sysget(SAS_EXECFILEPATH);*/
/*%end;*/
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

*new create folder in Data folder named by &_Date.;
/*options noxwait xmin;*/
/*x "md  ""&root.\&_mode.\Data\&date.""";*/

*1.create the contents sheet;
libname old "&root.\&_mode.\Data\&Ldate."; * Folder address of datasets to be compared;
libname new "&root.\&_mode.\Data\&date."; * Folder address of datasets this time;

%include "&root.\&_mode.\Program\1.Contents.sas";
%include "&root.\&_mode.\Program\2.DropSysVar.sas";
%include "&root.\&_mode.\Program\3.Output.sas";
