
%macro specialCharacter(libname=,memname=,coding=ascii);

*when domainlst = _all_ then get current libname all dataset;
%if (&memname = _all_) %then %do;
	proc sql noprint;
	select distinct memname into: domainlst separated by " "
	from dictionary.columns
	where libname = upcase("&libname.");
	quit;
%end;
%else %do;
	%let domainlst = &memname;
%end;

***Set final null;
data final;
length libname $8. memname $32. coln 8. name $32. label $256. record 8. value info $5000. index 8.
subject  $150.  instancename  $765.  datapagename  $765.   recordid 8.  recordposition 8.;
call missing(of _all_);
stop;
/*label libname="DatasetName" memname="FormOID" name="FieldOD" record="Line" value="DataValue" */
/*info="Information" index="LocationinValue";*/
run;

***loop all list;
%let domaincount = %sysfunc(countw(&domainlst));
%do domain_i = 1 %to &domaincount;
%let domain = %scan(&domainlst,&domain_i,%str( ));

	*pick all vars of each somain;
	proc sql noprint;
	select distinct name into: varlst separated by " "
	from dictionary.columns
	where libname = upcase("&libname.") and memname = upcase("&domain.") and prxmatch("/char|c/i",type);
	quit;

	*Create spCharN for each domain;
	data spChar&domain_i.;
	length libname $8. memname $32. coln 8. name $32. label $256. record 8. value info $5000. index 8.;
	set &libname..&domain indsname=dssource end=eof;
	array mychar &varlst.;
	do iii=1 to dim(mychar);
	call missing(libname, memname, coln, name,label, record, value, info, index);
	if klength(mychar{iii}) ^= 0 then do;
		libname=upcase(scan(dssource,1,'.'));
		memname=upcase(scan(dssource,2,'.'));
		name=vname(mychar{iii});
		label=vlabel(mychar{iii});
		coln=put(iii, best. -l);
		value=mychar{iii};
		record=_n_;

		do i = 1 to klength(mychar{iii});
		tmp = ksubstr(mychar{iii},i,1);
		if rank(tmp) not in (0:127) then do;
			info = tmp;
			index = put(i,best. -l);
			output;
		end;
		end;
	end;
	end;
	keep libname memname  coln name label record value info index subject instancename datapagename  recordid recordposition;
	run;

	*Judge whether nobs of each domain;
	%if %nobs(spChar&domain_i.)=0 %then %do;
	%put xxxxxxxxx;
	data spChar&domain_i.;
	length libname $8. memname $32. coln 8. name $32. label $256. record 8. value info $5000. index 8.
		subject  $150.  instancename  $765.  datapagename  $765.    recordid 8. recordposition 8.;

		libname=upcase("&libname.");
		memname=upcase("&domain.");
		name = "_ALL_";
		label = "N/A";
		value = "N/A";
		info = 'No variables with special character';
		
		output;
	run;
	%end;

	*Insert each domain into final dataset(concatenate all spCharN);
	proc sql;
	insert into final
	select * from spChar&domain_i.;
	drop table spChar&domain_i.;
	quit;

%end;
***loop end;

proc sort data=final out=M_SPCHAR(drop=coln) nodupkey;
by libname memname coln name record index;
run;

data M_SPCHAR;
set M_SPCHAR;
if info ^= 'No variables with special character' then
query="SAS 1: Invalidated character is entered, please update or clarify.";
else query= "";
drop index record;
DMcom="";DMstatus="";
run;


data &libname..M_SPCHAR;
retain  subject instancename datapagename memname recordid recordposition   name label value info query DMcom DMstatus;
set M_SPCHAR;
IF VALUE = "N/A" then delete;
label instancename="Folder_Name" datapagename="Form_Name" recordposition="RecordPosition";
label libname="Datasets" memname="FormOID" value="Field_Value"  name="FieldOID" label="Field_Name" info= "Special_Character"; 
label DMcom="DM_Comments" DMstatus= "Issue_Status";
label recordid= "recordId";

drop libname;
run;

%mend specialCharacter;

%specialCharacter(libname=new,memname=_all_,coding=ascii)
*%specialCharacter(libname=old,memname=_all_,coding=ascii)
