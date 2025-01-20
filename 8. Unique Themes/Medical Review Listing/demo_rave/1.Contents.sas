*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Medical Listing Program: 1.Contents.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\37_MR_Data_Listing\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/3/18
Validator Name  :  Xiangyun Xie/Liying Lu
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       : 
*********************************************************************************************;


proc contents data=new._all_ out=aa(keep=memname) DIRECTORY NOPRINT MEMTYPE=data CENTILES;
run;
proc sort data=aa out=bb  nodupkey;
by memname;
run;

data tmpcnt;
set bb;
N=_N_;
sht=compress('=HYPERLINK("#'||memname||'!R1C1","'||memname||'")');
Label sht="LinkForm" N="No.";
run; 


proc import datafile="&root.\&_mode.\Data\ALS_FORM4.xlsx" 
out=alsform
dbms=xlsx replace;getnames=yes;
run;

proc sql;
create table contents as
select t.N,t.sht, a.draftformname label="LinkFormName"
from tmpcnt as t left join alsform as a
on t.memname=a.oid
where a.draftformactive="TRUE" or t.MEMNAME="LAB";
quit;
