*取（如一次dryrun）所有数据集中的最大日期：;
libname new "C:\Users\yuanyuanp\Desktop\NEW";
 data adm;
  set sashelp.Vcolumn; 
  where libname="NEW"  and index (label,"日期")>0;
  *1.引号内区分大小写,
  2.单引号内不能引用宏变量，
  3.sashelp中dictionary的文件默认全部大写需要将变量名和变量值先upcase;
run;

proc sql noprint;
 select distinct catt("NEW.", memname, "(keep=",  name, " USUBJID", ")") 
 into: dslst separated by " " 
  from adm
 ;*建立宏变量dslst用于存放mystudy lib中所有的数据集的name和keep的变量。
  e.g.dslst中第一个值是：mystudy.ae(keep=aeendat __SUBJECTKEY);
 select distinct name into: dtlst separated by "," 
  from adm
 ;*建立宏变量dtlst用于存放每个数据集中的日期框变量;
quit;

data alldtc;*创建一个所有日期数据的数据集alldtc;
 set &dslst. indsname=source;
 datasource = source;
 alldtc = coalescec(&dtlst.);
 if prxmatch("/^(\d\d\d\d-\d\d-\d\d)|(\d\d\d\d-\d\d)|(\d\d\d\d)$/", strip(alldtc));
 *只保留年月日/年月/年格式的日期;
run;

proc sort data=alldtc;
by USUBJID;
run;

proc sql noprint;
 create table maxdat  as
  select USUBJID, max(alldtc) as maxdtc
   from alldtc
		group by USUBJID;
quit;
