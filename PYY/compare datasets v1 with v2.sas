*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Program Name    :  compare datasets v1 with v2.sas
Program Address :  O:\DM\Programming and Tools
Author Name     :  Yuanyuan Pei
Creation Date   :  2021/8/6
Validator Name  :  Yiyun Jin
Description     :  This program is to compare two datasets by each form.
				   Please paste the roots of both datasets in noting places.
*********************************************************************************************;

dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

libname v1 "F:\Project\295\2020-295-00CH1\DM\2020-295-00CH1\3-4 Ongoing\31_Data_cleaning\Dev\Data\20220324";
libname v2 "F:\Project\295\2020-295-00CH1\DM\2020-295-00CH1\3-4 Ongoing\31_Data_cleaning\Dev\Data\20220323";
ods _all_ close;
ods pdf;
%macro compare;
filename xxx pipe "dir ""F:\Project\295\2020-295-00CH1\DM\2020-295-00CH1\3-4 Ongoing\31_Data_cleaning\Dev\Data\20220323"" /b";
data file;
infile xxx truncover;
input @1 filename $1000.;
dsname=scan(filename,1,'.');
run;

proc sql noprint;
select filename, dsname, count(filename) into 
:fnames  separated by " ", :dsnames separated by " ", :count
from file;quit;

%do i=1 %to &count;
%let ds=%scan(&dsnames,&i,%str( ));%put &ds.;
title "&ds.";
proc compare base=v1.&ds. compare=v2.&ds. list error maxprint=32000;run;

%end;
%mend;
%compare;

ods pdf close;
