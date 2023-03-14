*SAS Check compare;
%let _mode=Dev; *Prd for production environment;
*%let today='25/APR/2022'; * Date of today;
%let LDate=20230209;*Date of datasets run last time.;
%let date=20230216;*Date of datasets run this time.;

libname old "&root.\&_mode.\Data\&LDate."; * Folder address of datasets to be compared;
libname new "&root.\&_mode.\Data\&date."; * Folder address of datasets this time;
proc import datafile="&root.\&_mode.\Document\TitleList.xlsx" out=ftlist
dbms=xlsx replace;
getnames=yes;
sheet="B2";
run;
***每个数据集执行%REPORT;
data f;
set ftlist;
IF CHECK_NAME ^= "";
keep check_name;
run;

****先判断NEW数据集是否为空，若为空，加desc;
%macro NEWOBS(a);
*如果本次listing结果为空数据集;
%if %nobs(new.&a.)=0 %then %do;
	data new.&a.;
	    length desc $200;
	    desc="No record Found";
		button="";
		button2= "";
		label desc="Result" 
		button=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))
		button2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));
    run;
%end;
%if %nobs(new.&a.) ^= 0 %then %do;
	data new.&a.;
		set new.&a.;
		button= "";button2= "";
		label button=%str(=HYPERLINK(%"#Contents!R1C1%",%"Back to Contents%"))
		button2=%str(=HYPERLINK(%"#FilterTab!R1C1%",%"Back to FilterTab%"));
	run;
%end;
%mend NEWOBS;

data _null_;
set f;
rc=dosubl(cats('%NEWOBS(',Check_Name,')')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;
**再分别讨论new/old数据集是否为空的情况;

%Macro addflag(a);
*如果本次listing的结果不为空，则需判断old.&a.是否为空。若为空，保留本次new.&a.，若不为空，则new old merge;

	*sort;
	proc sort data=new.&a.;by _all_;run;
	proc sort data=old.&a.;by _all_;run;

	*merge;


/*	*首次运行本listing;*/
/*	%if &date.= &Ldate. %then %do;*/
/*	data &a.;*/
/*		set new.&a.;*/
/*		length flag $20;*/
/*		flag="First Round Data";*/
/*		date="&date.";*/
/*		label  flag="Change status" date="Date of Data";*/
/*	run;*/
/*	%end;*/

	*非首次运行;
/*	%if &date.^= &Ldate. %then %do;*/

		**判断new.&a.是否为空;
		data _null_;
		set new.&a.;
		call symputx('nullnew','N');
		if desc = "No record Found" then do;
			call symputx('nullnew','Y');
		end;
		run;

		**判断old.&a.是否为空;
		data _null_;
		set old.&a.;
		call symputx('nullold','N');
		if desc = "No record Found" then do;
			call symputx('nullold','Y');
		end;
		
		run;

		*如果new.&a.和old.&a.均不为空，则new和old merge;
		%if  &nullold.= %str(N) and &nullnew. = %str(N) %then %do;
		data &a.;
			merge new.&a.(in=a) old.&a.(in=b);
			by _all_; 
			length flag $20;
			if a and not b then do;flag="New/Changed";date="&date.";end;
			if a and b then do;FLAG="Old"; date="&LDate.";end;
			if b and not a then do;FLAG="Delete";date="&LDate.";end;
			*output;
			label  flag="Change status" date="Date of Data";
			label recordID= "recordID";
			drop DMcom DMstatus;
		run;
		%end;

		*如果old.&a.或new.&a.为空，则保留new.&a.;
		%if  &nullold.= %str(Y) or &nullnew. = %str(Y) %then %do;
		data &a.;
			set new.&a.;
			flag = "NEW";
			date="&date.";
			label  flag="Change status" date="Date of Data";
			label recordID= "recordID";
			*drop DMcom DMstatus;
		run;
		%end;

/*	%end;*/

%mend addflag;
 
data _null_;
set f;
rc=dosubl(cats('%addflag(',Check_Name,')')); *可以在括号内再加一个变量title=,然后用offline listing的spec中query text内容作为这个title变量的内容;
run;


*****得到的work.M_XXX即可用于与上一轮的DMcom文件进行mapping;
