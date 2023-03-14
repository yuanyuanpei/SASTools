*import .csv with ticked tab to .sas7bdat;
%let csvfile=C:\Users\yuanyuanp\Desktop\test.csv;
proc import datafile="&.csvfile" out=csvTab
replace;
getnames=yes;
delimiter='09x';
run;
*import .csv without ticked tab to .sas7bdat;
proc import datafile="&.csvfile" out=csvNoTab
replace;
getnames=yes;
run;
