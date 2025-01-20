*****设定一个条件，导出其所在行及其前、后行：把行号作为一个变量optline;

data tmp1;
input a $10.;
datalines;
re
RE
as
Rec
df
gh
;

if a="Rec" then optline=_n_;*取满足条件所在的行号;
run;

data tmp2;
set tmp1;
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
