*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2020-689-00CH3
Program Name    :  Patient Profile Program: Run Per Subject.sas
Program Address :  O:\Project\689\2020-689-00CH3\DM\3-4 Ongoing\31_Data_cleaning\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2021/9/6
Validator Name  :  Liu Yang
Description     :  This program is the only-need-run program for outputing patient profile of each.
				   The macro variables &_mode. and &_Date. may need to be modified.
*********************************************************************************************;

dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets nolist memtype=data library=work kill;
quit;


**Macro variables that may need modification:;
%let _mode=Prd; * Dev for development environment or Prod for production environment;
%let _Date=20240328; * The date that you extract the rawdata;
%let _LDate=20240108; *The date you extract the rawdata last time.;


%macro currentroot;
	%global currentroot;
	%let currentroot=%sysfunc(getoption(sysin));
	%if "&currentroot" eq "" %then %do;
		%let currentroot=%sysget(SAS_EXECFILEPATH);
	%end;
%mend;

%currentroot;
%put &currentroot.;
%let root=%substr(%str(&currentroot),1,%index(%str(&currentroot),%str(\&_mode.\))-1);
%put &root.;

**Create folders in needed path.**;
options noxwait xmin;
*x "md  ""&root.\&_mode.\Data\&_Date."""; * Put your rawdata(.sas7bdat) in this folder.;
x "md  ""&root.\&_mode.\Output\PDF\&_Date."""; * To store the patientprofiles of .pdf format.;
x "md  ""&root.\&_mode.\Output\RTF\&_Date."""; * To store the patientprofiles of .rtf format.;
x "md  ""&root.\&_mode.\Output\RTF\&_Date.CHG"""; * To store the changed patientprofiles of .rtf format.;

x "md  ""&root.\&_mode.\Output\Compare\&_LDate.-&_Date."""; * To store the compare results of both .rtf and .pdf formats.;

%include  "&root.\&_mode.\Program\1. Data.sas";
%include  "&root.\&_mode.\Program\2. Style Template.sas";
/*%include  "&root.\&_mode.\Program\3. Compare If New Added Subjects.sas";*/
%include  "&root.\&_mode.\Program\6.sas";
%include  "&root.\&_mode.\Program\7.sas";


/*%include  "&root.\&_mode.\Program\4. Output Per Subject with Change.sas";*/

***Open 4. Doc1.docm with macros***;
options noxwait noxsync;
x '"C:\Program Files\Microsoft Office\Office16\WINWORD.EXE"';

data _null_;
x=sleep(5);
run;

filename cdms dde 'WinWord|System';

data _null_;
file cdms;
put '[FileOpen.Name = "F:\689\2020-689-00CH3\DM\IRC Patient profile\Prd\Program\4. Doc1.docm"]';
/*Run： Normal\Module1\"MCompare"*/
run;


/*%include  "&root.\&_mode.\Program\5. Output Per Subject with No Change.sas";*/
