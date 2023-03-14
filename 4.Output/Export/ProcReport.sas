ods excel options (sheet_name="Status Tracking" embedded_titles="yes");

proc report data=Status_tracking nowindows;
title "XYZ Status Tracking";
column var1 var2 var3 var4; 
compute var4; 
if index(var4,'Comments')>0 then 
	call define (_row_,"style","style=[just=center font_weight=bold backgroundcolor=cxEDF2F9 color=cx112277 ]");
endcomp;
run;

ods excel close;
