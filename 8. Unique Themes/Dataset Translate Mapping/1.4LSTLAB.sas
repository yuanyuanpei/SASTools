*LAB;
*1.sitename,foldername,insname,datapagename,formname;
*2.analytename （ALS/fields/AnalyteName）,labname;
*2.clinsig comment(freetext);

/********需要翻译的******************/;
*1.ClinSigComment替换;
*2.AnalyteValue替换;
*3.LabUnits替换;

data trsCS;
set raw.lab;
where ClinSigComment ^= "";
keep subject recordID form fieldOrdinal ClinSigComment;
rename ClinSigComment =allvalue form=formOID fieldOrdinal=fieldSEQ;
run;

*ASCII and Non-ASCII;
data trscsNA;
set trscs;
if klength(allvalue) ^= 0 then do;
	do i = 1 to klength(allvalue);
	tmp=ksubstr(allvalue,i,1);
	if rank(tmp) not in (0:127) then output trscsNA;
	end;
end;
drop i tmp;

run;

proc sort data=trscsna nodupkey;by _all_;run;
proc sort data=trscsna out=ndpcsna nodupkey;by allvalue;run;

proc datasets library=work nolist;
modify ndpcsna;
attrib _all_ label= "";
quit;


*/////////////////////////////////////;

/*!*2.LabUnits,AnalyteValue;*/
*分别列出两个变量;
data lablstv(keep=subject recordID form fieldOrdinal analytevalue)
	 lablstu(keep=subject recordID form fieldOrdinal labunits);
set raw.lab;
if analytevalue ^= "" then output lablstv;
if labunits ^= "" then output lablstu;

run;

*找到analyteValue中非ASCII的Obs;
data trslabvNA;
set lablstv;
if klength(analytevalue) ^= 0 then do;
	do i = 1 to klength(analytevalue);
	tmp=ksubstr(analytevalue,i,1);
	if rank(tmp) not in (0:127) then output trslabvNA;
	end;
end;
drop i tmp;
rename fieldOrdinal=fieldSEQ;
run;
*去重;
proc sort data=trslabvna nodupkey;by _all_;run;
proc sort data=trslabvna out=ndplabvna nodupkey;by analytevalue;run;
*去label;
proc datasets library=work nolist;
modify ndplabvna;
attrib _all_ label= "";
quit;


*/////////////////////////////////////;

*找到Labunits中非ASCII的Obs;
data trslabuNA;
set lablstu;
if klength(labunits) ^= 0 then do;
	do i = 1 to klength(labunits);
	tmp=ksubstr(labunits,i,1);
	if rank(tmp) not in (0:127) then output trslabuNA;
	end;
end;
drop i tmp;
rename fieldOrdinal=fieldSEQ;
run;
*去重;
proc sort data=trslabuna nodupkey;by _all_;run;
proc sort data=trslabuna out=ndplabuna nodupkey;by labunits;run;
*去label;
proc datasets library=work nolist;
modify ndplabuna;
attrib _all_ label= "";
quit;







