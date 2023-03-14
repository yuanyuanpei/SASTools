
/*/////////////////////////从ALS中获取变量的字典信息///////////////////////////////////////////////*/;
libname als xlsx "&root.\&_mode.\Document\XYZ_ALS_2.0.xlsx";

*Get field sheet and dictionary sheet from ALS;
 data field;
 set als.fields;
 if datadictionaryname ^="";
 if draftfieldactive="TRUE";
 keep formOID fieldOID PreText datadictionaryname ;
 rename datadictionaryname=dicnm;
 run;

 data diction;
 set als.datadictionaryentries;
 /*if specify="TRUE" then chk=1;*/
 keep datadictionaryname codeddata userdatastring specify;
 rename datadictionaryname=dicnm;
 run;
*Get all specify=true-concluded dictionaries, and keep their specify=false options;
 proc sql;
 create table tmp as
 select dicnm,codeddata,userdatastring from diction
 where dicnm in (select dicnm from diction where specify="TRUE")
 and specify = "FALSE";
 quit;
 proc sort data=tmp;by dicnm ;run;

 proc transpose data= tmp out=codelst (drop=_NAME_ _LABEL_);
 var userdatastring;
 by dicnm;
 run;

data fieldADD;
 set als.fields;
/*if formOID = "CM" and fieldOID="CPINDSP" then output;*/
/*if FormOID = "PR" and fieldOID="PRPROS" then output;*/
/*if formOID = "CSTSYM" and fieldOID= "CSSYM5A" then output;*/
/*if formOID = "PELYM" and fieldOID="PELLOC14" then output;*/

 keep formOID fieldOID PreText datadictionaryname ;
 rename datadictionaryname=dicnm;
 run;

data field;
set field fieldADD;
run;

*Merge fieldOID and dictionary codelst;
 proc sort data=field;by dicnm;run;
 proc sort data=codelst;by dicnm;run;

data mg;
merge field(in=b) codelst(in=a);
by dicnm;
if a=1 or fieldOID in ("CPINDSP","PRPROS","CSSYM5A","PELLOC14") ;
if formOID ^= "";
run;

proc sort data=mg;by formOID fieldOID;run;

*make unique form id by adding _n_ after formoid;
data mgg;
set mg;
id=catt(formoid,'_',_n_);
run;
*get codeddata of dict that specify=TRUE;
proc sql noprint;
create table specify as
select dicnm,codeddata from diction
where specify="TRUE";

create table mggall as
select mgg.*,specify.codeddata
from mgg left join specify
on mgg.dicnm=specify.dicnm
where mgg.formOID ^= "";
quit;


/*///////////////////拼接所有数据集中字典选项选了Other,specify的变量///////////////////////////////////////////////*/;

%macro chgfm(id,form,field);
	data &id.;
	length jgOID $20.;
	set NEW.&form.(keep=subject instancename datapagename recordid recordposition &field. &field._STD );
	jgOID="&field.";
	*JGlabel="&PreText.";
	run;
%mend chgfm;
*执行;
data _null_;
set mggall;
if fieldOID not in ("CPINDSP","PRPROS","CSSYM5A","PELLOC14") ;
rc=dosubl(cats('%chgfm(',id,',',formoid,',',fieldOID,')'));
run;

%macro chgfm2(id,form,field);
	data &id.;
	length jgOID $20.;
	set NEW.&form.(keep=subject instancename datapagename recordid recordposition &field.);
	jgOID="&field.";
	&field._STD="";
	run;
%mend chgfm2;
*执行;
data _null_;
set mggall;
if fieldOID in ("CPINDSP","PRPROS","CSSYM5A","PELLOC14") ;
rc=dosubl(cats('%chgfm2(',id,',',formoid,',',fieldOID,')'));
run;

***keep fieldOID,where fieldOID_STD='99';
proc sql noprint;
select distinct catt(ID,"(where=(",fieldOID,"_STD='",codeddata,"')",")")
into: dslst separated by " " from mggall;

select distinct fieldOID into:dtlst separated by ","
from mggall;
quit; 
%put &dslst.;%put &dtlst.;

*concatenate all &id. in one dataset;
%macro fdall;
data allc;
set &dslst. indsname=source;
datasource=source;
allvar=coalescec(&dtlst.);
keep subject instancename datapagename recordid recordposition jgOID allvar;
run;
%mend fdall;
%fdall


/*/////////////////////////将上述两步得到的数据集merge到一起/////////////////////////////////////////////*/;
*merge allc with alsdict;
proc sql;
create table Oth as
select allc.*,mg.* from
allc left join mg
on allc.jgOID=mg.fieldOID
;
quit;

proc sort data=oth nodupkey out=oth2(drop=formOID fieldOID);
by subject instancename datapagename recordid recordposition jgOID;run;

data new.M_othspfy;
retain subject instancename datapagename recordid recordposition jgOID PRETEXT allvar query;
set oth2;

query="SAS 2: “Other, Please Specify” is possibly duplicated with above choices, please update or clarify.";DMcom="";DMstatus="";
label jgOID="Field_OID" pretext="Field_Label" allvar="Specify_Value" dicnm="DataDictionaryName";
label DMcom="DM_Comments" DMstatus= "Issue_Status";
label recordid= "recordId";

run;





