
libname raw "C:\Users\yuanyuanp\Desktop\760 medicallisting\raw";*地址和库名可自行替换;

proc contents data=raw._ALL_ out=aa(keep=memname) DIRECTORY NOPRINT MEMTYPE=data CENTILES;

proc sort data=aa out=bb  nodupkey;by memname;run;

data contents;
set bb;
N=_N_;
sht=compress('=HYPERLINK("#'||memname||'!R1C1","'||memname||'")');
Label sht="Link" ;
keep N sht;
run; 

proc sql noprint;
select count(distinct memname) into: nn from dictionary.columns where libname=%upcase("raw");
select distinct memname into:mem1-:mem%left(&nn.) from dictionary.columns where libname=%upcase("raw");
quit;

ods excel file="C:\Users\yuanyuanp\Desktop\Test1.xlsx";*地址和文件名可自行替换;

*导出目录页;
ods excel options (sheet_name="Contents");
proc report data=contents;
run;

*导出其他所有数据集;
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
