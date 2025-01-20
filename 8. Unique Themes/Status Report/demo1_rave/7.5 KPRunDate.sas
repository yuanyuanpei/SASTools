*添加run date的compare功能，在不考虑Current_Date和Delay_Aging变化的情况下，行记录中若其他信息不变化，保持Run date不变.;
*针对以下3个form：misspage mista misex ;*aelist和pagenosdv pending;
%macro kprundate(ds=,byvar=);
%if %sysfunc(exist(old.&ds.,DATA)) %then %do;
	proc sort data=old.&ds.   ( rename=(rawtod=oldtod) drop=curr day );
	by &byvar.;
	run;
	proc sort data=raw.&ds.    (rename=(tod=rawtod));
	by &byvar.;
	run;

	data raw.mg&ds. mg&ds.;
	merge old.&ds.(in=a) raw.&ds.(in=b);
	by &byvar.;
	length rundate  $20.;
	if a and b then rundate=put(oldtod,best12.);
	if ^a and b then rundate=put(rawtod,best12.);
	if a and ^b then delete;
	drop oldtod rawtod;
	label rundate="Run_Date";
	run;

%end;
%else %do;
	data raw.mg&ds. mg&ds.;
	set raw.&ds.;
	length rundate  $20.;
	rundate = put(tod,best12.);
	label rundate = "Run_Date";
	drop tod;
	run;
%end;

proc sort data = mg&ds. nodupkey;by _all_;run;
proc sort data = mg&ds.;by &byvar.;run;
%mend kprundate;

%kprundate(ds=misspage,byvar=subject site sitenumber  status icfdat_raw c1d1dat dosephase 
		folder   min max avisdat ND eotdat_raw formname misv)

%kprundate(ds=misex,byvar=subject site sitenumber  fstex lenex VIS VISDAT_RAW EOTDAT_RAW misex)

%kprundate(ds=mista,byvar=subject site sitenumber ICFDAT_RAW DIACAT C1D1DAT
EOTDAT_RAW EOSDAT_RAW Status pweek pform FolderName FormName TUPERF misv misf)

%macro misdlt(ds=,byvar=);
%if %sysfunc(exist(old.&ds.,DATA)) %then %do;
	proc sort data=old.&ds.   (rename=(rawtod=oldtod)  drop=curr );
	by &byvar.;
	run;
	proc sort data=raw.&ds. ;
	by &byvar.;
	run;

	data raw.mg&ds. mg&ds.;
	merge old.&ds.(in=a) raw.&ds.(in=b);
	by &byvar.;
	length rundate  $20.;
	if a and b then rundate=put(oldtod,best12.);
	if ^a and b then rundate=put(rawtod,best12.);
	if a and ^b then delete;
	drop oldtod rawtod;
	label rundate="Run_Date";
	run;

%end;
%else %do;
	data raw.mg&ds. mg&ds.;
	set raw.&ds.;
	length rundate  $20.;
	rundate = put(tod,best12.);
	label rundate = "Run_Date";
	drop tod;
	run;
%end;

proc sort data = mg&ds. nodupkey;by _all_;run;
proc sort data = mg&ds.;by &byvar.;run;
%mend;
%misdlt(ds=misdlt,byvar=subject site sitenumber status icfdat_raw c1d1dat dosephase dltdat_raw eotdat_raw
eosdat_raw misdlt eicfdat_raw nd) 


/*proc contents data=raw.mista varnum;run;*/
*20240516:*在PageNotSDV页添加run date的compare功能，在不考虑Current_Date和Delay_Aging变化的情况下，行记录中若其他信息不变化，保持Run date不变.;

%macro pgnsdv(ds=,byvar=);
%if %sysfunc(exist(old.&ds.,DATA)) %then %do;
	proc sort data=old.&ds.    ( drop= Curr day);
	by &byvar.;
	run;
	proc sort data=raw.&ds.   (rename=(tod=rawtod) drop=curr);
	by &byvar.;
	run;

	data raw.mg&ds. mg&ds.;
	merge old.&ds.(in=a) raw.&ds.(in=b);
	by &byvar.;
	length rundate  $20.;
	if a and b then do;rundate=put(oldtod,best12.);*flag='both';end;
	if ^a and b then do;rundate=put(rawtod,best12.);*flag='new';end;
	if a and ^b then delete;
	drop oldtod rawtod;
	label rundate="Run_Date";
	format curr date11.;
	curr = today();
	label curr = "Current_Date";
	run;

%end;
%else %do;
	data raw.mg&ds. mg&ds.;
	set raw.&ds.;
	length rundate  $20.;
	rundate = put(tod,best12.);
	label rundate = "Run_Date";
	drop tod;
	format curr date11.;
	curr = today();
	label curr = "Current_Date";
	run;
%end;


proc sort data = mg&ds. nodupkey;by _all_;run;
proc sort data = mg&ds.;by &byvar.;run;
%mend;
%pgnsdv(ds=pagenosdv,byvar=subject site sitenumber instance datapage log lastdp visdat_raw ) 
/**/
/*data x1;*/
/*set raw.mgpagenosdv;*1198;*/
/*run;*/
/**/
/*proc sort data=x1 nodupkey out=x2;by _all_;run;*1138;*/




/**/
/*data xx2;*/
/*set pagenosdv;*/
/*if sitenumber ='02';*/
/*run;*/
/**/
/**/
/*data xx3;*/
/*set mgpagenosdv;*/
/*if sitenumber ='02';*/
/*run;*/
/**/
/*proc sql;*/
/*create table xx4 as*/
/*select * from xx3*/
/*intersect*/
/*select * from xx2;*/
/*quit;*/
/**/
/*	proc sort data=old.pagenosdv ;*  ( drop=curr day);*/
/*	by subject site sitenumber instance datapage log lastdp visdat_raw;*/
/*	run;*/
/*	proc sort data=raw.pagenosdv ;* (rename=(tod=rawtod) drop=curr);*/
/*	by subject site sitenumber instance datapage log lastdp visdat_raw;*/
/*	run;*/
/**/
/*	data xx5;*/
/*	merge old.pagenosdv(in=a) raw.pagenosdv(in=b);*/
/*	by subject site sitenumber instance datapage log lastdp visdat_raw;*/
/*	length rundate  $20.; */
/*/*	if b then ab='b';else ab=' ';*/*/
/**/
/**/
/*	if a and b then do;
/*rundate=put(oldtod,best12.);*/
/*flag='both';*/
/*end;*/*/
/*/*	if ^a and b then do;*/
/*rundate=put(rawtod,best12.);*/
/*flag='new';*/
/*end;*/*/
/*	if a and ^b then delete;*/
/*	drop oldtod rawtod;*/
/*	label rundate="Run_Date";*/
/*	format curr date11.;*/
/*	curr = today();*/
/*	if sitenumber ='02';*/
/**/
/*	*/
/*	run;*/
/*proc sort data=xx5 nodupkey;
/*by _all_;run;*/*/
/**/
/**/
/**/
/*data xx6;*/
/*set pagenosdv(where=(sitenumber ='02'));
/*run;*/*/
