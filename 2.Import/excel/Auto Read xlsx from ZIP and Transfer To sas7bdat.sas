*1.Download all needed .zip datasets:
e.g.Clinflash EDC system,  studyID: XYZ
report:XYZ_QueryDetailReport_2023_02_27_09_58
	  :XYZ_FormExcel_3.0_202302270959;

*2.fetch all needed message into one sas dataset;

*define downloaded date, get year, month, day;
%let _Date=20230227;

%let y=%substr(%str(&_Date.),1,4); %put &y.;
%let m=%substr(%str(&_Date.),5,2);%put &m.;
%let d=%substr(%str(&_Date.),7,2);%put &d.;

*get information of needed .zip files from downloaded files;
filename dnld pipe "dir C:\Users\%sysuserid.\Downloads /b";

data pick;
infile dnld truncover;
input @1 filename $1000.;
g1=scan(filename,1,'_');
g2=scan(filename,2,'_');
g3=scan(filename,3,'_');
g4=scan(filename,4,'_');
g5=scan(filename,5,'_');
if g1="XYZ";
if g2 in ("eCRFEntrySDVeSignReport","FormExcel","MissingPageReport",
          "PageStatusReport","QueryDetailReport","SubjectStatusDetailReport",
          "SubjectStatusTotalReport","AuditTrailReport");
if (g3="&y." and g4="&m." and g5="&d.") 
	or (g3="&Vcrf." and index(g4,"&_Date.")=1) 
	or index(g3,"&_Date.")=1;
run;

*3. paste needed .zip files into destination;
options noxwait xmin;
%macro paste(file);
x "xcopy /y C:\Users\%sysuserid.\Downloads\&file. C:\Users\%sysuserid.\Desktop\ttt\";
%mend paste;

data _null_;
set pick;
rc=dosubl(cats('%paste(',filename,')'));
run;


*4.autoread the .xlsx file from .zip file(available for non-password .zip file);

filename inzip zip "C:\Users\&sysuserid.\Desktop\XYZ_eCRFEntrySDVeSignReport_2022_07_25_09_53.zip";
*Read the members(files) from the zip file;

data contents(keep=memname isFolder);
length memname $200 isFolder 8;
fid=dopen("inzip");
if fid=0 then stop;
memcount=dnum(fid);
do i =1 to memcount;
memname=dread(fid,i);
*check for trailing / in folder name;
isFolder=(first(reverse(trim(memname)))='/');
output;
end;
rc=dclose(fid);
run;

*Create a report of the zip contents;
title "Files in the zip file";
proc print data=contents noobs N;
run;

*identify a temp folder in the Work dictionary;
filename x1 "%sysfunc(getoption(work))/Book1.xlsx";

data _null_;
*Using member syntax here;
infile inzip(TESTUZ/Book1.xlsx)
lrecl=256 recfm=F length=length eof=eof unbuf;
file x1 lrecl=256 recfm=N;
input;
put _infile_ $varying256. length;
return;
eof:
stop;
run;

*5.import the x1.xlsx to .sas7bdat;
proc import datafile=x1 dbms=xlsx out=out replace;
sheet=sheet1;
run;

