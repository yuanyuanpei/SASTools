*export all lists to be translated;

ods _all_ close;
ods excel file="&root.\&_mode.\Output\1.List\All_Lists_&date..xlsx";

*1.Other, please specify;
ods excel options (sheet_name="OtherSpecify" );
	proc report data=ndpspyNA;run;

*2.FreeText;
ods excel options (sheet_name="FreeText(NoLAB)" );
proc report data=ndpfreNA;run;

*3.LB units in LB ds;
ods excel options (sheet_name="LBUnits(NoLAB)" );
	proc report data=ndpunNA;run;

*4.1. Clinical Significantlly specify in LAB ds;
ods excel options (sheet_name="CSspecify(LAB)" );
	proc report data=ndpcsNA;run;

*4.2. Lab Value in LAB ds;
ods excel options (sheet_name="LabValue(LAB)" );
	proc report data=ndplabvNA;run;

*4.3. Lab Units in LAB ds;
ods excel options (sheet_name="LabUnits(LAB)" );
	proc report data=ndplabuNA;run;

ods excel close;
