*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 5.MissingPageSum.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

*********MissingPage Summary******;

data misspage1;
set misspage;
if misv = "Y" or misv = "N" and formname ^="";
if formname = "" then formname="misv";
keep site sitenumber subject formname day;
rename formname=forcount;
run;

data mista1;
set mista;
if misf ="Yes";
keep site sitenumber subject misf day;
rename misf=forcount;
run;

data misex2;
set misex;
if misex ^= "";
keep site sitenumber subject misex day;
rename misex=forcount;
run;

data misdlt2;
set misdlt;
if misdlt ="Yes";
day=.;
keep site sitenumber subject misdlt day;
rename misdlt=forcount;
run;

data msall ms0 ms1 ms2;
set misspage1 mista1 misex2 misdlt2;
output msall;
if day lt 5 then output ms0;
if day ge 5 and day le 10 then output ms1;
if day gt 10 then output ms2;
run;
proc sort data=msall;by _all_;run;

%macro crt(ds);
proc sql;
*1.msall;
create table smsall as
select distinct site,sitenumber,count(distinct subject) as nsub,count(forcount) as nall
from msall
group by sitenumber;

insert into smsall (site,sitenumber,nsub,nall)
select '' as site,'Total' as sitenumber,count(distinct subject) as nsub,count(forcount) as nall
from msall;

*2-4.ms0-2;
create table s&ds. as
select distinct site,sitenumber,count(forcount) as n&ds.
from &ds.
group by sitenumber;

insert into s&ds. (site,sitenumber,n&ds.)
select '' as site,'Total' as sitenumber,count(forcount) as n&ds.
from &ds.;

quit;
%mend crt;
%crt(ms0)
%crt(ms1)
%crt(ms2)

proc sort data=smsall;by sitenumber;run;
proc sort data=sms0;by sitenumber;run;
proc sort data=sms1;by sitenumber;run;
proc sort data=sms2;by sitenumber;run;

data mispgsum;
drop i;
merge smsall sms0 sms1 sms2;
by sitenumber;
array num[*] nsub--nms2;
	do i = 1 to dim(num);
	if num[i]=. then num[i]=0;
	end;
label nsub='#_of_Subjects' nall='#_of_Missing_Pages' nms0='#_of_Delay_Aging(<5)' nms1='#_of_Delay_Aging(5-10)' nms2='#_of_Delay_Aging(>10)';
run;

data mispgsum;
set mispgsum;
format TOD date11.;
TOD=today();
label TOD="Run Date";
run;

/**/
/*%macro ms(set=,out=);*/
/*data ms0 ms1 ms2;*/
/*set &set.;*/
/*if day lt 5 then output ms0;*/
/*if day ge 5 and day le 10 then output ms1;*/
/*if day gt 10 then output ms2;*/
/*keep site sitenumber subject forcount;*/
/*run;*/
/**/
/*proc sql;*/
/**missing page����;*/
/*create table ms3 as*/
/*select distinct site,sitenumber,count(distinct subject) as nsub,count(forcount) as nall*/
/*from &set.*/
/*group by sitenumber;*/
/**����total��;*/
/*insert into ms3 (site,sitenumber,nsub,nall)*/
/*select '' as site,'Total' as sitenumber,count(distinct subject) as nsub,count(forcount) as nall*/
/*from &set.;*/
/**/
/**/
/**delay aging Ϊ<5������from ms0;*/
/*create table ms04 as*/
/*select distinct site,sitenumber,count(forcount) as n01*/
/*from ms0*/
/*group by sitenumber;*/
/**����total��;*/
/*insert into ms04(site,sitenumber,n01)*/
/*select '' as site,'Total' as sitenumber,count(forcount) as n01*/
/*from ms0;*/
/**/
/**delay aging Ϊ5-10������from ms1;*/
/*create table ms4 as*/
/*select distinct site,sitenumber,count(forcount) as n1*/
/*from ms1*/
/*group by sitenumber;*/
/**����total��;*/
/*insert into ms4(site,sitenumber,n1)*/
/*select '' as site,'Total' as sitenumber,count(forcount) as n1*/
/*from ms1;*/
/**/
/**delay aging Ϊ>10������from ms2;*/
/*create table ms5 as*/
/*select distinct site,sitenumber,count(forcount) as n2*/
/*from ms2*/
/*group by sitenumber;*/
/**����total��;*/
/*insert into ms5(site,sitenumber,n2)*/
/*select '' as site,'Total' as sitenumber,count(forcount) as n2*/
/*from ms2;*/
/**/
/*quit;*/
/**/
/*proc sort data=ms3;by sitenumber;run;*/
/*proc sort data=ms04;by sitenumber;run;*/
/*proc sort data=ms4;by sitenumber;run;*/
/*proc sort data=ms5;by sitenumber;run;*/
/**/
/*data &out.;*/
/*merge ms3 ms04 ms4 ms5;*/
/*by sitenumber;*/
/*run;*/
/**/
/*%mend ms;*/
/**1.missing pages;*/
/*%ms(set=misspage1,out=misA)*/
/**2.Missing Tumor Assessment Pages;*/
/*%ms(set=mista1,out=misB)*/
/*%ms(set=misex2,out=misC)*/
/**/
/*proc sort data=misa;by sitenumber;run;*/
/*proc sort data=misb;by sitenumber;run;*/
/*proc sort data=misc;by sitenumber;run;*/
/**/
/*data mispgsum;*/
/*drop i;*/
/*merge misa misb(rename=(nall=tnall n01=tn01 n1=tn1 n2=tn2)) */
/*			misc(rename=(nall=enall n01=en01 n1=en1 n2=en2));*/
/*by sitenumber;*/
/*array num[*] nsub--en2;*/
/*	do i = 1 to dim(num);*/
/*	if num[i]=. then num[i]=0;*/
/*	end;*/
/*label nsub='#_of_Subjects' nall='#_of_Missing_Pages' n01='#_of_Entry_Delay_Aging(<5)' n1='#_of_Entry_Delay_Aging(5-10)' n2='#_of_Entry_Delay_Aging(>10)'*/
/*tnall='#_of_Missing_Tumor_Assessment_Pages' tn01='#_of_Tumor_Entry_Delay_Aging(<5)' tn1='#_of_Tumor_Entry_Delay_Aging(5-10)' tn2='#_of_Tumor_Entry_Delay_Aging(>10)'*/
/*enall='#_of_Missing_Exposure_Pages' en01='#_of_Exposure_Entry_Delay_Aging(<5)' en1='#_of_Exposure_Entry_Delay_Aging(5-10)' en2='#_of_Exposure_Entry_Delay_Aging(>10)';*/
/*run;*/
