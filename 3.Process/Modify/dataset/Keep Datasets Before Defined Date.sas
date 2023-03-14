*keep datasets before cut date: 
e.g. download rave regular datasets on 2022/8/11, but we need datasets rignt before 2022/7/25;

*define edc library as path of datasets downloaded on 20220811;
libname edc "C:\Users\yuanyuanp\Desktop\EDC\20220811";

*define cut library as path of datasets cut off on 20220725;
libname new "C:\Users\yuanyuanp\Desktop\EDC\cut20220725";

proc contents data=edc._all_ out=ds(keep=memname) DIRECTORY NOPRINT MEMTYPE=data CENTILES;run;
proc sort data=ds out=out nodupkey ;by memname ;run;

%macro dltcut(a);
data cut.&a.;
set edc.&a.;
cut=input("2022-07-25",yymmdd10.);
date=datepart(savets);
time=timepart(savets);
delta=date-cut;
if delta >0 then delete;
run;

%mend dltcut;

data _null_;
set out;
rc=dosubl(cats('%dltcut(',memname,')'));
run;
