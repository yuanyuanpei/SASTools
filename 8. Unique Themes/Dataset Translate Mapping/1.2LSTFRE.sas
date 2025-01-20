

data freelst;
set field;
if DatadictionaryName ="";
if index(Dataformat,'$')>0;
id2=catt(formoid,'__',_n_);
n2=_n_;
var2=catt('var2_',_n_);
run;

%macro exeach2(id2,formOID,fieldOID,n2);
data &id2.;
set raw.&formOID.;
var2_&n2.="&fieldOID.";
keep subject recordID &fieldOID var2_&n2.;
run;
%mend exeach2;

data _null_;
set freelst;
rc=dosubl(cats('%exeach2(',id2,',',formoid,',',fieldOID,',',n2,')'));
run;

%macro domainlst2(a);
proc sql noprint;
select distinct id2 into: &a.alllst2 separated by " " from freelst
where formOID = %UPCASE("&a.");
select distinct fieldOID into: &a.dtlst2 separated by "," from freelst
where formOID = %UPCASE("&a.");
select distinct var2 into: &a.varlst2 separated by "," from freelst
where formOID = %UPCASE("&a.");
quit;

data &a.all2;
*为防止数据截断;
length allvalue $1000.;

set &&&a.alllst2.  indsname = source;
datasource=scan(source,1,'_');
formOID=trim(scan(datasource,2,'.'));
allvar=coalescec(&&&a.varlst2.);
allvalue=coalescec(&&&a.dtlst2.);
keep subject recordID formOID allvar allvalue;
run;

proc sort data=&a.all2 nodupkey;by _all_;run;
%mend domainlst2;

proc sort data=freelst out=flst(keep=formOID) nodupkey;by formOID;run;

data _null_;
set flst;
rc=dosubl(cats('%domainlst2(',formOID,')'));
run;

proc sql noprint;
select strip(formOID) || 'all2' into: trslst2 separated by ' '
from Flst;
quit;
%PUT &TRSLST2.;
data trsfree;
set &trslst2.;
if allvalue ^="";
run;

proc sort data=trsfree nodupkey;by _all_;run;
proc sort data=trsfree; by subject formOID;run;

data trsfreNA;
*retain allvalue;
set trsfree;
if klength(allvalue) ^= 0 then do;
	do i = 1 to klength(allvalue);
		tmp=ksubstr(allvalue,i,1);
		if rank(tmp) not in (0:127) then output;
	end;
end;
drop i tmp;
run;

proc sort data=trsfreNA nodupkey;by _all_ ;run;

proc sort data=trsfrena out=ndpfrena nodupkey;by allvalue;run;

proc datasets library=work nolist;
modify ndpfrena ;
attrib _all_ label ='';

quit;


/**/
/*proc sql;*/
/*create table trsfreA as*/
/*select * from trsfree*/
/* except corr*/
/*select * from trsfreNA;*/
/*quit;*/
/**/
/*data trsfreA2;*/
/*set trsfreA;*/
/*trans=allvalue;*/
/*rec=put(recordID,best. -l);*/
/*rename rec=recordID;*/
/*drop recordid;*/
/*run;*/
