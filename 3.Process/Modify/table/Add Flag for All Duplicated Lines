****将一个数据集内重复的n行都加上flag(用lag函数仅能在两行重复的第二行加);

data test;
input v1 $2. v3 $5. v4 $5.;
datalines;
01 aaaaa xxx
01 bbb   yyy
02 cccc  zzz
01 bbb   yyy
05 x34   ww
;
run;


proc sort data=test;by v1 v3 v4;run;

data test2;
set test;
by v1 v3 v4;
retain flag;
if first.v4 and not last.v4 then flag="Duplicate";
if first.v4 and last.v4 then flag="";
run;

