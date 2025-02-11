%macro specialCharacter(libname=,memname=,output=,coding=ascii);

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
subject  $150.  instancename  $765.  datapagename  $765.  recordposition 8. ;
 
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
	call missing(libname, memname, coln, name, record, value, info, index);
	if klength(mychar{iii}) ^= 0 then do;
		libname=upcase(scan(dssource,1,'.'));
		memname=upcase(scan(dssource,2,'.'));
		name=upcase(vname(mychar{iii}));
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
	keep libname memname  coln name label record value info index subject instancename datapagename recordposition;
	run;

	*Judge whether nobs of each domain;
	%if %nobs(spChar&domain_i.)=0 %then %do;
	%put xxxxxxxxx;
	data spChar&domain_i.;
	length libname $8. memname $32. coln 8. name $32. label $256. record 8. value info $5000. index 8.
		subject  $150.  instancename  $765.  datapagename  $765.  recordposition 8. ;
 
		libname=upcase("&libname.");
		memname=upcase("&domain.");
		name = "_ALL_";
		label= "N/A";
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

proc sort data=final out=SPCHAR(drop=coln INDEX RECORD) nodupkey;
by libname memname coln name record index;
run;


ods excel file="&output." 
		options(frozen_headers='on' autofilter='all' sheet_name="SpecialChar");

data SPCHAR;
retain libname subject instancename datapagename memname recordposition name label value info  ;
set SPCHAR;
label instancename="Folder_Name" datapagename="Form_Name" recordposition="RecordPosition";
label libname="Datasets" memname="FormOID" value="Field_Value"  name="FieldOID" label="Field_Name" info= "Special_Character"; 
run;


proc report data = SPCHAR;
run;

ods excel close;


%mend specialCharacter;


*If you want to check all domains,make memname equals to "_all_";
%specialCharacter(libname=trans,
					memname=_all_,
					output=%str(&root.\&_mode.\Output\4.Validation\&date.\specialCharacter.xlsx),
					coding=ascii)

