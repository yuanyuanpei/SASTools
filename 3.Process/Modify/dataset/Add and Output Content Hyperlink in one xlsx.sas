%let path=C:\Users\yuanyuanp\DESKTOP;

options noxwait xmin;
x "md ""&path.\Raw""";

libname raw "&path.\Raw";
data raw.cars;set sashelp.cars;run;
data raw.class;set sashelp.class;run;
data raw.fish;set sashelp.fish;run;

/*proc contents data=raw._ALL_ out=aa(keep=memname) DIRECTORY NOPRINT MEMTYPE=data CENTILES;*/
data aa;
set sashelp.vcolumn;
keep memname;
where %upcase(libname)="RAW";
run;

proc sort data=aa  nodupkey;by memname;run;

data contents;
set aa;
N=_N_;
sht=compress('=HYPERLINK("#'||memname||'!R1C1","'||memname||'")');
Label sht="Link" ;
keep N sht;
run; 

proc sql noprint;
select count(distinct memname) into: nn from dictionary.columns where libname=%upcase("raw");
select distinct memname into:mem1-:mem%left(&nn.) from dictionary.columns where libname=%upcase("raw");
quit;

ods excel file="&path.\Raw\Contents.xlsx";
*Output content page;
ods excel options (sheet_name="Contents");
proc report data=contents;run;

*Output all datasets behind content page;
%macro expall;
%do i =1 %to &sqlobs;

ods excel options (sheet_name="&&mem&i");
%if %nobs(raw.&&mem&i)=0 %then %do;
	data nob;
		length desc $50;
		desc="No Record Found";
		run;
	proc report data=nob nowindows;column desc;run;
%end;
%else %do;
	proc report data=raw.&&mem&i nowindows;run;
%end;

%end;
%mend;
%expall

ods excel close;
