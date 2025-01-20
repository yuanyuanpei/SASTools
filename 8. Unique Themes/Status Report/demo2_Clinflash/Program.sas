data  page1;
set pagestatusreport;
 keep var4 var6 var7 var8 var9;
 if var8 = '-----------' then delete;
 rename var4 = subjid var6 = foldername var7 = modulename 
 var8 = pagename var9=n_entryfield;
 run;