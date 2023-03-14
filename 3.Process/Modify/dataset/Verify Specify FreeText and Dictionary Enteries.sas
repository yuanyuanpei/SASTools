
libname als xlsx "C:\Users\yuanyuanp\Desktop\XYZ_ALS_1.0.xlsx";

 data field;
    set als.fields;
    if datadictionaryname ^="";
    if draftfieldactive="TRUE";
    keep formOID fieldOID datadictionaryname ;
    rename datadictionaryname=dicnm;
 run;

 data diction;
    set als.datadictionaryentries;
    /*if specify="TRUE" then chk=1;*/
    keep datadictionaryname userdatastring specify;
    rename datadictionaryname=dicnm;
 run;

 proc sql;
 create table tmp as
 select dicnm,userdatastring from diction
 where dicnm in (select dicnm from diction where specify="TRUE")
       and specify = "FALSE";
 quit;

 proc sort data=tmp;by dicnm ;run;
 
 proc transpose data= tmp out=codelst (drop=_NAME_ _LABEL_);
 var userdatastring;
 by dicnm;
 run;

 proc sort data=field;by dicnm;run;
 proc sort data=codelst;by dicnm;run;

data mg;
merge field(in=b) codelst(in=a);
by dicnm;
if a and b;
run;

proc sort data=mg;by formOID fieldOID;run;

data mgg;
set mg;
id=catt(formoid,'_',_n_);
run;


/*/////////////////////////NEW///////////////////////////////////////////////*/;

***把new数据集里,所有的mg数据集中含有的form都加一个变量JudgeOID，值等于mg的fieldOID;
%macro chgfm(id,form,field,Pretext);
data &id.;
set NEW.&form.(keep=subject instancename datapagename recordposition &field. &field._STD);
jgOID="&field.";
run;
%mend chgfm;
*执行;
data _null_;
set mgg;
rc=dosubl(cats('%chgfm(',id,',',formoid,',',fieldOID,')'));
run;

***keep fieldOID where fieldOID_STD=99(要求建库时specify的code均为99);
proc sql noprint;
select distinct catt(ID,"(where=(",fieldOID,"_STD='99')",")")
into: dslst separated by " " from mgg;

select distinct fieldOID into:dtlst separated by ","
from mgg;
quit; 

%macro fdall;
data allc;
set &dslst. indsname=source;
datasource=source;
allvar=coalescec(&dtlst.);
keep subject instancename datapagename recordposition jgOID allvar;
run;
%mend fdall;
%fdall

proc sql;
create table Oth as
select allc.*,mg.* from
allc inner join mg
on allc.jgOID=mg.fieldOID
;
quit;

proc sort data=oth nodupkey out=oth2(drop=formOID fieldOID);
by subject instancename datapagename recordposition jgOID;run;

data NEW.M_othspfy;
retain subject instancename datapagename recordposition jgOID allvar query;
set oth2;
query="Other, please specify is selected, please varify the Specify Value with the dictionary entries behind.";
label jgOID="JudgeField" allvar="SpecifyValue" dicnm="DataDictName";
run;

/*/////////////////////////OLD///////////////////////////////////////////////*/;
***把old数据集里,所有的mg数据集中含有的form都加一个变量JudgeOID，值等于mg的fieldOID;
%macro chgfm(id,form,field,Pretext);
data &id.;
set old.&form.(keep=subject instancename datapagename recordposition &field. &field._STD);
jgOID="&field.";
run;
%mend chgfm;
*Execute;
data _null_;
set mgg;
rc=dosubl(cats('%chgfm(',id,',',formoid,',',fieldOID,')'));
run;

***keep fieldOID,where fieldOID_STD=99;
proc sql noprint;
select distinct catt(ID,"(where=(",fieldOID,"_STD='99')",")")
into: dslst separated by " " from mgg;

select distinct fieldOID into:dtlst separated by ","
from mgg;
quit; 

%macro fdall;
data allc;
set &dslst. indsname=source;
datasource=source;
allvar=coalescec(&dtlst.);
keep subject instancename datapagename recordposition jgOID allvar;
run;
%mend fdall;
%fdall

proc sql;
create table Oth as
select allc.*,mg.* from
allc inner join mg
on allc.jgOID=mg.fieldOID
;
quit;

proc sort data=oth nodupkey out=oth2(drop=formOID fieldOID);
by subject instancename datapagename recordposition jgOID;run;

data old.M_othspfy;
retain subject instancename datapagename recordposition jgOID allvar query;
set oth2;
query="Other, please specify is selected, please varify the Specify Value with the dictionary entries behind.";
label jgOID="JudgeField" allvar="SpecifyValue" dicnm="DataDictName";
run;
