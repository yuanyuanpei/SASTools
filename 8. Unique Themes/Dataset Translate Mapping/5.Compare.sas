dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets lib=work memtype=data kill nolist;quit;

*/////////////////////////////////////;
**Get all ds name;
filename xxx pipe "dir ""&root.\&_mode.\Data\&date."" /b";
data file;
infile xxx truncover;
input @1 filename $1000.;
dsname=scan(filename,1,'.');
run;

*/////////////////////////////////////;
**Compare origin and trans ds;
%macro compare (ds);

proc sort data=raw.&ds.;by subject recordID;run;
proc sort data=trans.&ds.;by subject recordID;run;

****Compare_xx_Horizontally;
proc compare base=raw.&ds. compare=trans.&ds. out=comp.outH&ds. outbase outcomp list error maxprint=32000;run;

%if &ds.^= %str(lab) %then %do;
****Compare_xx_Vertically;
proc transpose data=comp.outH&ds. out=comp.outV&ds.;
by subject recordid;var _all_;
run;

data comp.outV&ds.;
set comp.outV&ds.;
if _NAME_ ="_TYPE_" then delete;
label subject="Subject Id" recordid="Record ID" _name_="Variable Name" _label_="Variable Label" COL1="Before Trans" COL2="After Trans";
run;
%end;

**所有domain的Label对比list***;
proc sql;
create table lbl as
select  LIBNAME, MEMNAME,varnum,NAME,LABEL from
sashelp.vcolumn 
where libname in ("RAW","TRANS") ;
quit;

PROC SORT DATA=lbl;BY memname varnum ;RUN;
PROC TRANSPOSE DATA=lbl OUT=complbl ;
BY memname varnum;
VAR LABEL;
RUN;

data comp.complbl;
set complbl;
drop _NAME_ _LABEL_;
label memname="Domain" varnum="Variabel Seq" COL1 = "Before" COL2 = "After";
run;

%mend compare;

*All forms except LAB(not exists in ALS);
data _null_;
set fILE;
rc=dosubl(cats('%COMPARE(',DSNAME,')'));
run;

*/////////////////////////////////////;
**Output compare results;


****1.Compare all ds and output Horizontally;
	ods excel file="&root.\&_mode.\Output\4.Validation\&date.\1.Compare_Horizontally_&date..xlsx";
	**Output dataset compare;
	%macro outH(ds);
	ods excel options (sheet_name="&ds."  frozen_headers="on" embedded_titles="yes" autofilter="all" );

		proc report data=comp.outH&ds. nowindows;title "Compare_&ds._Horizontal";
		compute _TYPE_;
		if _TYPE_ ="COMPARE" then call define (_row_,"style","style=[backgroundcolor=YELLOW]");
		endcomp;
		run;
	%mend outH;

	*All forms ;
	data _null_;
	set FILE;
	if dsname ^="lab";
	rc=dosubl(cats('%outH(',DSNAME,')'));
	run;


/*	**Output label compare;*/
/*	ods excel options (sheet_name="AllLabel"  frozen_headers="on" embedded_titles="yes" autofilter="all" );*/
/*	proc report data=comp.complbl nowindows; title "Compare_All_Label";RUN;*/

ods excel close;


/********************;*/
/*ods excel file="C:\Users\yuanyuanp\Desktop\TWB\TAZ\Compare_Lab_%sysfunc(today(),yymmdd10.).xlsx";*/
/**/
/*ods excel options (sheet_name="Lab"  frozen_headers="on" embedded_titles="yes" autofilter="all" );*/
/**/
/*proc export data=comp.outhlab outfile="C:\Users\yuanyuanp\Desktop\TWB\TAZ\Compare_Lab1.xlsx";run;*/
/*ods excel close;*/
/**/
/********************;*/



****2.Compare all ds and output Vertically;

ods excel file="&root.\&_mode.\Output\4.Validation\&date.\2.Compare_Vertically_&date..xlsx";
	%macro outV(ds);
	ods excel options (sheet_name="&ds."  frozen_headers="on" embedded_titles="yes" autofilter="all" );
	proc report data=comp.outV&ds. nowindows;title "Compare_&ds._Vertical";
	compute _NAME_;
	if _NAME_ ="_OBS_" then call define (_row_,"style","style=[backgroundcolor=YELLOW]");
	endcomp;
	run;
	%mend outV;

	*All forms except LAB(not exists in ALS);
	data _null_;
	set FILE;
	IF dsname ^= "lab";
	rc=dosubl(cats('%outV(',dsname,')'));
	run;

ods excel close;


****3.Compare lab.sas7bdat and output Horizontally;

	proc export data=comp.outhlab  outfile="&root.\&_mode.\Output\4.Validation\&date.\3.Compare_Lab_&date..xlsx";  
	RUN;



****4.Compare all labels from all ds and output ;
ods excel file="&root.\&_mode.\Output\4.Validation\&date.\4.Compare_All_Label_&date..xlsx";

	ods excel options (sheet_name="AllLabel"  frozen_headers="on" embedded_titles="yes" autofilter="all" );
	proc report data=complbl nowindows; title "Compare_All_Label";RUN;

ods excel close;


ods _all_ close;
****5.Compare all ds and output pdf;
ods pdf file="&root.\&_mode.\Output\4.Validation\&date.\5.Compare_Report_&date..pdf";
	*out=pdf&ds.; 
	%macro compPDF(ds);
	title "&ds.";
	proc compare base=raw.&ds. comp=trans.&ds. novalues list error  maxprint=32000; 
	run;
	%mend compPDF;

	data _null_;
		set FILE;
		IF dsname ^= "lab";
		rc=dosubl(cats('%compPDF(',dsname,')'));
	run;
ods pdf close;
