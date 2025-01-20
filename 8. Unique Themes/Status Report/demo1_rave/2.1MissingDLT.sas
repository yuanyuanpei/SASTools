data mref;
set mpr4;
drop vis avisdat avis;
run;

data mdlt;
set dlt;
keep subject dltdat_raw;
run;

proc sort data=mref nodupkey; by _all_;run;
proc sort data=mdlt;by subject;run;

data mgdlt;
merge mdlt mref;
by subject;
format curr yymmdd8.;
curr=today();
c1d1=input(c1d1dat,date11.);
if dosephase="Dose Escalation" then do;
	if curr-c1d1-27 ge 0 and DLTDAT_RAW = "" then misdlt="Yes";else misdlt="No";
end;
run;

data misdlt;
retain site sitenumber subject status icfdat_raw c1d1dat dosephase dltdat_raw eotdat_raw eosdat_raw curr misdlt;
set mgdlt;
drop c1d1;
label misdlt = "Missing_DLT" curr="Current_Date";
run;
data raw.misdlt misdlt;
set misdlt;
*format TOD date11.;
rawTOD=&date.;
label rawTOD="Run Date";
run;
