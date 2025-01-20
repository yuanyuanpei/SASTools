/*proc contents data=raw.lab varnum;run;*/
**********LBx的表里面取检查项的单位变量;

*取所有含analyte_UN的domain及变量;
proc sql noprint;
create table unilst as
select distinct memname,name  from sashelp.vcolumn
where libname="RAW" and reverse(trim(name)) like "NU_%" and find(name,'_') >0;
quit;

*把这些 domain set到一起;
data unilst2;
set unilst;
id3=catt(memname,'___',_n_);*每个domain里可能会有多个变量要output出来;
n3=_n_;
var3=catt('var3_',_n_);*同一行obs可能会有多个变量需要output出来;
run;

%macro exeach3(id3,memname,name,n3);
data &id3.;
set raw.&memname.;
var3_&n3. = "&name.";
keep subject recordID &name. var3_&n3.;
run;
%mend exeach3;

data _null_;
set unilst2;
rc=dosubl(cats('%exeach3(',id3,',',memname,',',name,',',n3,')'));
run;

%macro domainlst3(a);
proc sql noprint;
select distinct id3 into : &a.alllst3 separated by " " from unilst2
where memname = %upcase("&a.");
select distinct name into : &a.dtlst3 separated by "," from unilst2
where memname = %upcase("&a.");
select distinct var3 into: &a.varlst3 separated by "," from unilst2
where memname = %UPCASE("&a.");
quit;

data &a.all3;
*为防止数据截断;
length allvalue $1000.;
set &&&a.alllst3. indsname=source;
datasource=scan(source,1,'_');
formOID=trim(scan(datasource,2,'.'));
allvar=coalescec(&&&a.varlst3.);
allvalue=coalescec(&&&a.dtlst3.);
keep subject recordID formOID allvar allvalue;
run;
proc sort data=&a.all3 nodupkey;by _all_;run;
%mend domainlst3;

proc sort data=unilst2 out=ulst(keep=memname) nodupkey;by memname;run;
*导出每个domain的所有_UN变量所在的Obs,并合并为xxall3;
data _null_;
set ulst;
rc=dosubl(cats('%domainlst3(',memname,')'));
run;

*将上述xxall3全部合并为一个list;
proc sql noprint;
select distinct strip(memname) || 'all3' into: trslst3 separated by ' '
from unilst2;
quit;
%put &trslst3.;
data trsun;
set &trslst3.;
*if allvalue ^ = "";
run;

*取出其中非ASCII的部分;
data trsunna;
set trsun;
if klength(allvalue) ^=0 then do;
	do i = 1 to klength(allvalue);
	tmp=ksubstr(allvalue,i,1);
	if rank(tmp) not in (0:127) then output;
	end;
end;
drop i tmp;
run;

proc sort data=trsunna nodupkey;by _all_;run;
proc sort data=trsunna out=ndpunna nodupkey;by allvalue;run;

proc datasets library=work nolist;
modify ndpunna;
attrib _all_ label = '';
quit;


