*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2024-760-00CH1
Program Name    :  Study Status Report Program: Run.sas
Program Address : 
Author Name     :  Yuanyuan Pei
Creation Date   :  2024/11/18
Validator Name  :  Xiangyun Xie
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  #SasExcelReport# and #SubjectStatusReport# of 2019-453-00CH2 study downloaded from Clinflash 
                   are different with 2020-295-00CH1 study.
*********************************************************************************************;

*///Step1: Download Needed Datasets From Clinflash EDC.///////////////;

*///Step2: Run the following codes with SAS Chinese Version./////////;

dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets nolist memtype=data library=work kill;
quit;

**Macro variables that may need modification:;
%let _mode=Dev; * Dev for development environment or Prod for production environment;
%let _file=Data; * The file to save the needed reports downloaded from EDC. Please do not change it.;
%let _Date=20250120; * The date that you need to run the status report;
%let _LDate=20250120; *The date of Last time you run the status report;

*"RunOut"V1.0, 20241118 DM comments;

%let currentPath = %scan(&_sasprogramfile.,1,"'");
%put &currentPath.;

%let root=%substr(%str(&currentPath),1,%index(%str(&currentPath),%str(\&_mode.\))-1);
%put &root.;


*///Step3: Unzip Downloaded Files Manually (password).////////////////;

*///Step4: Run the following codes and check Output///////////////////;

%include  "&root.\&_mode.\Program\EG0.Data.sas";
%include  "&root.\&_mode.\Program\1.SubjStatusDetail.sas";
%include  "&root.\&_mode.\Program\2.MissingPage.sas";
%include  "&root.\&_mode.\Program\3.MissingTA.sas";
%include  "&root.\&_mode.\Program\4.MissingEX.sas";
%include  "&root.\&_mode.\Program\5.PageNotSDV.sas";
%include  "&root.\&_mode.\Program\6.QueryList.sas";
%include  "&root.\&_mode.\Program\7.SubjStatusTotal.sas";
%include  "&root.\&_mode.\Program\8.Output.sas";
