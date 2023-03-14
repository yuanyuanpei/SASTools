*Judge whether dataset &ds. has obs or not;
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
*Use:;
*If %nobs(&ds.)=0 then xxxxx;
