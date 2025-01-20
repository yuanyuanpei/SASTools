*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 4.MissingEX.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

data misexa;
set subdetail;
format curr yymmddn8.;
curr=today();
len=input(lenex,date11.);
vs=input(visdat_raw,date11.);
eot =input(eotdat_raw,date11.);
*首次用药没录的情况:;
if fstex = "" and index(VIS,"Cycle")=1 then do;misex="Y";day=curr-vs;end;
*首次用药已录的情况:;
if lenex ^= "" and len < vs-1 then do; misex="Y"; day=vs-len; end;
if lenex ^= "" and len < eot-1 then do;misex="Y"; day=eot-len; end;*last dose stop date =eotdat or =eotdat-1?;
if misex ^="";
keep site sitenumber subject fstex lenex vis visdat_raw eotdat_raw misex curr day;
run;

data misex;
set misexa;
if eotdat_raw ^="" then delete;
label curr="Current_Date" day="Delay_Aging" misex= "Missing_Exposure";
run;

data raw.misex misex;
set misex;
*format TOD date11.;
TOD=&date.;
label TOD="Run Date";
run;
