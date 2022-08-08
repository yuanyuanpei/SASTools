*1.将dounload里xxx开头的文件贴到F盘的目的地址;

filename dnld pipe "dir C:\Users\%sysuserid.\Downloads /b";

%let y=%substr(%str(&_Date.),1,4); %put &y.;
%let m=%substr(%str(&_Date.),5,2);%put &m.;
%let d=%substr(%str(&_Date.),7,2);%put &d.;

data pick;
infile dnld truncover;
input @1 filename $1000.;
g1=scan(filename,1,'_');
g2=scan(filename,2,'_');
g3=scan(filename,3,'_');
g4=scan(filename,4,'_');
g5=scan(filename,5,'_');
if g1="2020-295-00CH1";
if g2 in ("eCRFEntrySDVeSignReport","FormExcel","MissingPageReport",
          "PageStatusReport","QueryDetailReport","SubjectStatusDetailReport",
        "SubjectStatusTotalReport","AuditTrailReport");
if (g3="&y." and g4="&m." and g5="&d.") or (g3="&Vcrf." and index(g4,"&_Date.")=1) or index(g3,"&_Date.")=1;
run;

*改一下paste的路径：&root.\&_mode.\Data\&_Date.\;
options noxwait xmin;
%macro paste(file);
x "xcopy /y C:\Users\%sysuserid.\Downloads\&file. C:\Users\%sysuserid.\Desktop\ttt\";
%mend paste;

data _null_;
set pick;
rc=dosubl(cats('%paste(',filename,')'));
run;


*2.SAS直接读取压缩文件中的文件（含密码的不行）;

*/////////////////////////////////////////////////////;
*还可用于判断一个路径下的文件及文件夹结构;

*TESTUZ可以作为一个宏变量，值为从系统down下来的所有压缩文件的文件名：即pick数据集中的filename;

filename inzip zip "C:\Users\&sysuserid.\Desktop\ttt\2020-295-00CH1_eCRFEntrySDVeSignReport_2022_07_25_09_53.zip";
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
input;*将内容写入x1;
put _infile_ $varying256. length;
return;
eof:
stop;
run;
*以上，已读取zip文件夹中的文件，下面的import为导入SAS并转为sas数据集的语句;
proc import datafile=x1 dbms=xlsx out=out replace;
sheet=sheet1;
run;

