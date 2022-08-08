*导入数据集demo;
proc import datafile="C:\Users\yuanyuanp\Desktop\demo.xlsx" out=demo
dbms=xlsx replace;getnames=yes;
run;
*把所有的变量均改为char格式，并导出数据集out;
%macro auto_chg2char(dsn);
/* initialize these two variables */
  %let list=;
  %let label=;
  %let type=;
/* open the data set */
  %let dsid=%sysfunc(open(&dsn));
/* obtain number of variables in the data set and put into &CNT */
  %let cnt=%sysfunc(attrn(&dsid,nvars));
/* put all variable names into &LIST and a C or N for each variable into &TYPE to represent if the */
/* the associated variable is character or numeric */
   %do i = 1 %to &cnt;
    %let list=&list#%sysfunc(varname(&dsid,&i));
    %let label=&label#%sysfunc(varlabel(&dsid,&i));
    %let type=&type#%sysfunc(vartype(&dsid,&i));
   %end;
/* close the data set */
  %let rc=%sysfunc(close(&dsid));

/* construct the DROP= option to remove the new variables that are created during the step */
  data out(drop=  
	%do i = 1 %to &cnt;
	     %let temp=%scan(&list,&i,#); 
		_&temp
	%end;);

	    label 
	  %do k = 1 %to &cnt;
		   %let namek=%scan(&list,&k,#);
		   %let labelk=%scan(&label,&k,#);
		   &namek. = "&labelk."
 	 %end;;
/* rename the current variables to those prefixed with an underscore */
   set &dsn(rename=(
    %do i = 1 %to &cnt;
     %let temp=%scan(&list,&i,#);
       &temp=_&temp
    %end;));

    %do j = 1 %to &cnt;
     %let temp=%scan(&list,&j,#);
   /** Change C to N for numeric to character conversion  **/
	     %if %scan(&type,&j,#) = N %then %do;
	   /** Also change INPUT to PUT for numeric to character  **/
	      &temp=put(_&temp,best. -l);
	     %end;
	     %else %do;
	      &temp=_&temp;
	     %end;
	%end;

  run;

%mend auto_chg2char;
%auto_chg2char(demo)

*填充;
data fill;
length tmp1 - tmp20 $1000. ;*根据demo中var的个数设置n个tmp变量（此处为20个）;
set out;

retain tmp1 - tmp20;
	array char  study_name -- order; *demo中var1至var20的varname;
	array tmp tmp1 - tmp20;

	do i=1 to 20;
		if char[i] ^='' then tmp[i]=char[i];
		else char[i]=tmp[i];*因为有retain;
	end;

drop i tmp:;
run;
