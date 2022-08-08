****将一个数据集内重复的n行都加上flag(用lag函数仅能在两行重复的第二行加);

PROC IMPORT DATAFILE="C:\Users\yuanyuanp\Desktop\tt.xlsx" out=test
dbms=xlsx replace; getnames=yes;
run;

proc sort data=test;by v1 v3 v4;run;

data test2;

set test;
by v1 v3 v4;
retain flag;
if first.v4 and not last.v4 then flag="DU";
if first.v4 and last.v4 then flag="";
run;

*****设定一个条件，导出其所在行及其前、后行：把行号作为一个变量optline;

data pp;
set co;
if subject ^="";
if action="Reclassify" then optline=_n_;*取满足条件所在的行号;
run;

data pp2;
set pp;
if optline ^=. then do;
optline=optline-1;output;*取前一行所在行号;
optline=optline+1;output;*取当前行行号;
optline=optline+1;output;*取后一行所在行号;
end;
else do;
delete;
end;
keep optline;
run;

*再将optline变量所在数据集与原数据集merge, by optline;
