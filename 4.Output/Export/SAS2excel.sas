proc datasets lib = work nolist kill; run;

%let path = C:\Users\yuanyuanp\Desktop\SDTM;
libname edc "&path.";

data edclst;
  set sashelp.vtable;
	where libname = "EDC";
  call symput("nedc", _n_);
run;

%put &nedc.;

%macro supp;
		%do edc = 1 %to &nedc.;
		  data xptnm;
		    set edclst;
				if _n_ = &edc.;
				call symput("data", compress(memname));
			run;

			proc export data= edc.%sysfunc(strip(&data.))
			             outfile="&path.\XYZ SDTM"
			             dbms=xlsx replace label;
			   sheet="%sysfunc(strip(&data.))";
			run;
		%end;

%mend supp;

%supp;
