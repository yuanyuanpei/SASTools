
proc sql noprint;
create table allspy as
select form.formOID,form.formnameCN,form.formnameEN,field.fieldoid,
	field.fieldnameCN,field.fieldnameEN,field.datadictionaryname,
	dictspy.codeddata,dictspy.optionCN,dictspy.optionEN,dictspy.specify
from (form left join field on form.formOID=field.FormOID) right join dictspy
on field.DataDictionaryName=dictspy.DataDictionaryName
where field.fieldOID ^= "";
quit;

data allspy2;
set allspy;
if specify="TRUE";
id=catt(formoid,'_',_n_);
n=_n_;
var=catt('var_',_n_);
run;


%macro exeach(id,formOID,CodedData,fieldOID,n);
data &ID.;
set raw.&formOID.;
if &fieldOID._STD = "&CodedData.";
var_&n.="&fieldOID.";
keep subject recordID &fieldOID.  &fieldOID._STD var_&n.;
run;
%mend exeach;

data _null_;
set allspy2;
*if formoid="CMPCA";
rc=dosubl(cats('%exeach(',id,',',formoid,',',CodedData,',',fieldOID,',',n,')'));
run;
/*options nomlogic;*/

%macro domainlst(a);
proc sql noprint;
select distinct id into: &a.alllst separated by " " from allspy2
where formOID = %UPCASE("&a.");

select  fieldOID into: &a.dtlst separated by "," from allspy2 
where formOID = %UPCASE("&a.");

select  trim(fieldOID) ||'_STD' into: &a.cdlst separated by "," from allspy2 
where formOID = %UPCASE("&a.");

select var into: &a.varlst separated by "," from allspy2
where formOID = %UPCASE("&a.");
quit;
%put &&&a.alllst.;%put &&&a.dtlst.;%put &&&a.cdlst.;%put &&&a.varlst.;

data &a.all;
*为防止数据截断;
length allvalue $1000.;

set &&&a.alllst. indsname = source;
datasource=scan(source,1,'_');
formOID=trim(scan(datasource,2,'.'));
allvar=coalescec(&&&a.varlst.);
allvalue=coalescec(&&&a.dtlst.);
allcode=coalescec(&&&a.cdlst.);
keep subject recordID formOID allvar allvalue allcode;
run;

*******防数据截断也可用SQL语句*************;
	/*proc sql;*/
	/*create table &a.all as*/
	/*select subject,recordID,formOID,*/
	/*coalescec(&&&a.varlst.) as allvar,*/
	/*coalescec(&&&a.dtlst.) as allvalue,*/
	/*coalescec(&&&a.cdlst.) as allcode*/
	/*from &&&a.alllst.;*/
	/*quit;*/
************************;
proc sort data=&a.all nodupkey;by _all_;run;

%mend domainlst;

proc sort data=allspy2 out=spylst(keep=formOID) nodupkey;by formOID;run;

data _null_;
set SPYlst;
rc=dosubl(cats('%domainlst(',formOID,')'));
run;

proc sql noprint;
select strip(formOID) || 'all' into: trslst separated by ' '
from spylst;
run;

data trsspy;
set &trslst.;
run;

proc sort data=trsspy nodupkey;by _all_;run;
proc sort data=trsspy;by subject formOID;run;

data trsspyNA ;
set trsspy;
if klength(allvalue) ^= 0 then do;
	do i = 1 to klength(allvalue);
	tmp=ksubstr(allvalue,i,1); 
	if rank(tmp) not in (0:127) then output trsspyNA;
end;
end;
drop i tmp;
run;

proc sort data=trsspyNA nodupkey;by _all_;run;

proc sort data=trsspyna out=ndpspyna nodupkey;by allvalue;run;

proc datasets library=work nolist;
modify ndpspyna ;
attrib _all_ label ='';
quit;


/*proc sql;*/
/*create table trsspyA as*/
/*select * from trsspy*/
/* except corr*/
/*select * from trsspyNA;*/
/*quit;*/
/**/
/**change recordID from num to char, for proc sql select concatenation(||) requires char operands;*/
/*data trsspyA2;*/
/*set trsspyA;*/
/*trans=allvalue;*/
/*rec=put(recordID,best. -l);*/
/*rename rec=recordID;*/
/*drop recordid;*/
/*run;*/





