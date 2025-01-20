*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2021-760-00CH1
Program Name    :  Study Status Report Program: 8.Output.sas
Program Address :  F:\Project\760\2021-760-00CH1\DM\3-4 Ongoing\38_DSR\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2022/2/14
Validator Name  :  Tingting Hong
Description     :  This program is the only-need-run program which is to contain the macro variables that 
                   may need to be modified,initialize the root and include all the programs orderly.
Attention       :  .csv files(PageStatus and QueryDetail) should be transfered to be .xlsx format.
*********************************************************************************************;

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

ODS excel file="&root.\&_mode.\Output\2021-760-00CH1 Status Report %sysfunc(today(),yymmddn8.).xlsx";

%macro report(shtnm=,title=,ds=);
ods excel options(sheet_name="&shtnm." frozen_headers="on" embedded_titles="yes" absolute_column_width = "150px");
%if %nobs(&ds.)=0 %then %do;
	data &ds.;
	length desc $50;
	desc="No Record Found";
	run;
	proc report data=&ds. nowindows; title "&title.";
	column desc;
	run;
%end;
%else %do;
	proc report data=&ds. style(column)={just=center width=200%} nowindows;title "&title.";
	run;
%end;
%mend report;

%report(shtnm=Subj Status Total,title=Subject Status Total,ds=subtotal)
%report(shtnm=Subj Status Detail,title=Subject Status Detail,ds=subdetail)
%report(shtnm=Missing Pages Summary,title=Missing Pages Summary Report,ds=mispgsum)

%report(shtnm=Missing Pages Report,title=Missing Pages Report,ds=mgmisspage)
%report(shtnm=Missing Tumor Assess Report,title=Missing Tumor Assess Report,ds=mgmista)
%report(shtnm=Missing Exposure Report,title=Missing Exposure Report,ds=mgmisex)

%report(shtnm=Missing DLT Report,title=Missing DLT Report,ds=mgmisdlt)

%report(shtnm=AE Listing,title=AE Listing,ds=outaelist)
*20240516:PageNotSDV页如要与上一轮的记录compare，ds应为mgpagenosdv，如不需要compare，ds应为pagenosdv;
%report(shtnm=Pages Not SDVed,title=Pages Not SDVed Report,ds=mgpagenosdv)

%report(shtnm=Query Summary,title=Query Summary,ds=qrysum)
%report(shtnm=Open Query Listing,title=Open Query Detail Listing,ds=openqrylist)
%report(shtnm=Answered Query Listing,title=Answered Query Detail Listing,ds=ansqrylist)

****DM Status Report*****;
ods excel options (sheet_name="DM Status Tracking" embedded_titles="yes" hidden_rows='3');

proc report data=statustracking  style(column)={just=center} nowindows;
title "Protocol No. : 2021-760-00CH1";
column A B C D;
compute D;
if index(D,"Comments")>0 then
	call define (_row_,"style","style=[just=center font_weight=bold backgroundcolor=cxEDF2F9 color=cx112277]");
endcomp;
run;
*User List;
ods excel options (sheet_name="User List" embedded_titles="yes" hidden_rows='NONE');

%report(shtnm=User List,title=2021-760-00CH1 User List,ds=userlist)

ods excel close;
