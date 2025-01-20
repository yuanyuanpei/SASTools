*change label of fields using coding dictionary;
data medd whod;
set codict;
if index(codingDictionary,"MedDRA") =1 then output medd;
if index(codingDictionary,"WHODrug") =1 then output whod;
run;
*MedDRA;
%macro medd(formOID,fieldOID,fieldNameEN);
proc datasets library = LB;
modify LB&formOID.;
label &fieldOID._CoderDictName =  "&FieldNameEN._CoderDictName"
      &fieldOID._CoderDictVersion=  "&FieldNameEN._CoderDictVersion"
	 &fieldOID._HLGT= "&FieldNameEN.HLGT"
	&fieldOID._HLGTC= "&FieldNameEN.HLGTC"
	&fieldOID._HLT= "&FieldNameEN.HLT"
	&fieldOID._HLTC= "&FieldNameEN.HLTC"
	&fieldOID._LLT= "&FieldNameEN.LLT"
	&fieldOID._LLTC= "&FieldNameEN.LLTC"
	&fieldOID._PT= "&FieldNameEN.PT"
	&fieldOID._PTC= "&FieldNameEN.PTC"
	&fieldOID._SOC= "&FieldNameEN.SOC"
	&fieldOID._SOCC= "&FieldNameEN.SOCC";
quit;
%mend medd;

data _null_;
set medd;
rc=dosubl(cats('%medd(',formOID,',',fieldOID,',',fieldnameEN,')'));
run;

*WHODrug;
%macro whod(formOID,fieldOID,fieldNameEN);
proc datasets library = LB nolist;
modify LB&formOID.;
label &fieldOID._CoderDictName =  "&FieldNameEN._CoderDictName"
      &fieldOID._CoderDictVersion=  "&FieldNameEN._CoderDictVersion"
	 &fieldOID._ATC1= "&FieldNameEN.ATC1"
	 &fieldOID._ATC1C= "&FieldNameEN.ATC1C"
	 &fieldOID._ATC2= "&FieldNameEN.ATC2"
	 &fieldOID._ATC2C= "&FieldNameEN.ATC2C"
	 &fieldOID._ATC3= "&FieldNameEN.ATC3"
	 &fieldOID._ATC3C= "&FieldNameEN.ATC3C"
     &fieldOID._ATC4= "&FieldNameEN.ATC4"
	 &fieldOID._ATC4C= "&FieldNameEN.ATC4C"
	 &fieldOID._INGREDIENT= "&FieldNameEN.INGREDIENT"
	&fieldOID._INGREDIENTC= "&FieldNameEN.INGREDIENTC"
	 &fieldOID._PRODUCT= "&FieldNameEN.PRODUCT"
	&fieldOID._PRODUCTC= "&FieldNameEN.PRODUCTC"
	 &fieldOID._PRODUCTSYNONYM= "&FieldNameEN.PRODUCTSYNONYM"
	&fieldOID._PRODUCTSYNONYMC= "&FieldNameEN.PRODUCTSYNONYMC";
quit;
%mend whod;
data _null_;
set whod;
rc=dosubl(cats('%whod(',formOID,',',fieldOID,',',fieldnameEN,')'));
run;

*options nomlogic nomprint nosymbolgen;
*Change other values and labels;
%macro nospy(a);
%let &a.Fldlst=;
%let &a.labellst2=;
*By domain;
proc sql noprint;
	create table allnospy as select * from allals where specify ="FALSE";

	select 'if ' || trim(fieldOID) ||'_STD = "'|| strip(codeddata) || '" then  ' ||trim(fieldOID) ||'= "' ||trim(optionEN) ||'";'
	into : &a.Fldlst separated by ' '
	from allnospy where formOID = %upcase("&a.");

	select distinct strip(fieldOID) || ' = ' || strip(fieldNameEN) 
	into: &a.labellst separated by ' '
	from field where formOID = %upcase("&a.");

	*coded data label;
	select distinct strip(fieldOID) || '_STD = ' || strip(fieldNameEN) ||' Coded Value'
	into: &a.labellst2 separated by ' '
	from field where formOID =%upcase("&a.") and DataDictionaryName ^= "";
	
quit;

*does not by domain;

proc sql noprint;
	select 'if DataPageName = "' || trim(FormNameCN) ||'" then DataPageName = "'||trim(FormNameEN) ||'";'
	into : Fmlst separated by ' '
	from form;

	select 'if FolderName = "' || trim(FolderNameCN) ||'" then FolderName = "'||trim(FolderNameEN) ||'";'
	into : Fdlst separated by ' '
	from folder ;

	select 'if InstanceName = "' || trim(FolderNameCN) ||'" then InstanceName = "'||trim(FolderNameEN) ||'";'
	into : inslst separated by ' '
	from folder where FoldernameCN ^= "计划外访视";

	select 'if SiteNumber= "2021-TAZ-00CH1_'||trim(SiteNo)||'" then Site= "'||trim(SiteNameEN)||'";'
	into : sitelst separated by ' '
	from sitelst where sitenameCN ^= "";
quit;

*no obs in raw dataset;
%if %nobs(raw.&a.) eq 0  %then %do;
	*_STD variables exist;
	%if %length(&&&a.labellst2.) > 0 %then %do;
	data TRANS.&a.;
		set LB.LB&a.;
		label &&&a.labellst. &&&a.labellst2.;
	run;
	%end;
	*_STD variables not exist;
	%if %length(&&&a.labellst2.) = 0 %then %do;
	data TRANS.&a.;
		set LB.LB&a.;
		label &&&a.labellst. ;
	run;
	%end;
%end;
*obs >0 in raw dataset;
%if %nobs(raw.&a.) ne 0  %then %do;
	*_STD Varibale is not empty;
	%if %length(&&&a.fldlst) gt 0 %then %do;
	data TRANS.&a.;
	set LB.LB&a.;

		&&&a.Fldlst.;
		&Fmlst.;
		&Fdlst.;
		&INSlst.;
		&Sitelst.;
		
		if index(InstanceName,"计划外访视")>0 then 
			instancename=prxchange('s/计划外访视/Unscheduled Visit/i',-1,instancename);
		if index(InstanceName,"肿瘤评估访视")>0 then 
			instancename=prxchange('s/肿瘤评估访视/Tumor Assessment Visit/i',-1,instancename);
		if index(InstanceName,"筛选期")>0 then 
			instancename=prxchange('s/筛选期/Tumor Assessment Visit/i',-1,instancename);

		if index(InstanceName,"计划外第")>0 then do;
			instancename=prxchange('s/计划外第/Unscheduled Visit/i',-1,instancename);
			instancename=prxchange('s/次//i',-1,instancename);
		end;

		if index(InstanceName,"治疗结束（EOT）")>0 then 
			instancename=prxchange('s/治疗结束（EOT）/End of treatment (EOT)/i',-1,instancename);

		label &&&a.labellst.  &&&a.labellst2.;
	run;
	%end;
	*_STD Varibale is empty;
	%if %length(&&&a.fldlst) eq 0 %then %do;
		data TRANS.&a.;
		set LB.LB&a.;

		&Fmlst.;
		&Fdlst.;
		&INSlst.;
		&Sitelst.;

		if index(InstanceName,"计划外访视")>0 then 
			instancename=prxchange('s/计划外访视/Unscheduled Visit/i',-1,instancename);
		if index(InstanceName,"肿瘤评估访视")>0 then 
			instancename=prxchange('s/肿瘤评估访视/Tumor Assessment Visit/i',-1,instancename);
		if index(InstanceName,"筛选期")>0 then 
			instancename=prxchange('s/筛选期/Tumor Assessment Visit/i',-1,instancename);

		if index(InstanceName,"计划外第")>0 then do;
			instancename=prxchange('s/计划外第/Unscheduled Visit/i',-1,instancename);
			instancename=prxchange('s/次//i',-1,instancename);
		end;

		if index(InstanceName,"治疗结束（EOT）")>0 then 
			instancename=prxchange('s/治疗结束（EOT）/End of treatment (EOT)/i',-1,instancename);


		label &&&a.labellst.  &&&a.labellst2.;
	run;
	%end;
%end;
%mend nospy;

*All forms except LAB(not exists in ALS);
data _null_;
set form;
rc=dosubl(cats('%nospy(',formOID,')'));
run;


