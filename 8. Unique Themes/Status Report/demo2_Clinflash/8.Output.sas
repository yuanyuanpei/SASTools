

***20241129 output*******************************;

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

ODS excel file="&root.\&_mode.\Output\2024-760-00CH1 Status Report %sysfunc(today(),yymmddn8.).xlsx";

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

%report(shtnm=Subj Status Total,title=Subject Status Total,ds=raw.subj_total_rate)
%report(shtnm=Subj Status Detail,title=Subject Status Detail,ds=raw.subj_detail)

%report(shtnm=Missing Summary,title=Missing Summary,ds=raw.mis_summary)
*20240516:PageNotSDV页如要与上一轮的记录compare，ds应为mgpagenosdv，如不需要compare，ds应为pagenosdv;
%report(shtnm=Not SDVed(logline) Summary,title=Pages Not SDVed(logline) Summary,ds=raw.sdv_summary)
%report(shtnm=Query Summary,title=Query Summary,ds=raw.query_summary)


%report(shtnm=Missing Pages Report,title=Missing Pages Report,ds=raw.page_mis)
%report(shtnm=Missing Visit Report,title=Missing Visit Report,ds=raw.misv_cycle)
%report(shtnm=Missing Safety Follow Up,title=Missing Safety Follow Up,ds=raw.misv_safe)

%report(shtnm=Missing TA Page,title=Missing TA Page,ds=raw.page_mis_ta)
%report(shtnm=Missing TA Visit,title=Missing TA Visit,ds=raw.misv_ta)

%report(shtnm=Missing Exposure Report,title=Missing Exposure Report,ds=raw.page_mis_ex)
%report(shtnm=Missing 760 Exposure,title=Missing 760 Exposure,ds=raw.mis_ex_760)
%report(shtnm=Missing R-GemOx Exposure,title=Missing R-GemOx Exposure,ds=raw.mis_ex_Rgemox)


%report(shtnm=Pages Not SDVed(logline),title=Pages Not SDVed(logline) Report,ds=raw.page_notsdv)

/*%report(shtnm=Query Summary,title=Query Summary,ds=qrysum)*/

%report(shtnm=Open Query Listing,title=Open Query Detail Listing,ds=raw.open_query)
%report(shtnm=Answered Query Listing,title=Answered Query Detail Listing,ds=raw.ans_query)
%report(shtnm=AE Listing,title=AE Listing,ds=raw.saelist)
*User List;
ods excel options (sheet_name="User List" embedded_titles="yes" hidden_rows='NONE');

%report(shtnm=User List,title=2024-760-00CH1 User List,ds=userrolestatusreport)

ODS excel close;
