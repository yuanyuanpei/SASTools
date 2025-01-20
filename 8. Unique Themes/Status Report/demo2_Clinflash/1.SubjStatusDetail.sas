*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2024-760-00CH1
Program Name    :  Study Status Report Program: Run.sas
Program Address : 
Author Name     :  Yuanyuan Pei
Creation Date   :  2024/11/18
Validator Name  :  Xiangyun Xie
Description     :  This program is used to set up %nobs and %imports macros for final report.
*********************************************************************************************;

/*ICF.RFICDAT ��֪��ͬ����ǩ������	*/
data tmp1;
set raw.icf;
keep usubjid rficdat;
run;

/*MHDIAG.DIAGTERM �����������	*/
data tmp2;
set raw.mhdiag;
keep usubjid DIAGTERM;
run;
/*RAND.RANDYN�Ƿ�������	RAND.RANDTYP DLBCL���� RAND.RANDNO�����	RAND.RANDDAT�������	RAND.DOSEGP������*/
data tmp3;
set raw.rand;
keep usubjid RANDYN RANDTYP RANDNO RANDDAT DOSEGP;
run;
/*EX.EXSTDAT.first760_�״θ�ҩ����	EX.EXENDAT.last760_����ҩ����	*/

**EX;
data ex;
set raw.ex;
exstdatn = input(exstdat,yymmdd10.);
exendatn = input(exendat,yymmdd10.);
run;

proc sort data=ex; by usubjid exstdatn ;run;

data tmp4f tmp4l;
set  ex;
by usubjid exstdatn;
if first.usubjid then output tmp4f;
if last.usubjid then output tmp4l;
keep usubjid exstdat exendat;
run;

proc sort data=tmp4f(rename=(exstdat=fstex exendat=fenex));
by usubjid;run;
proc sort data=tmp4l(rename=(exstdat=lstex exendat=lenex));
by usubjid;run;

data tmp4;
merge tmp4f tmp4l;
by usubjid;
drop fenex lstex;
label fstex = "760_首次给药日期" lenex ="760_最大给药结束日期";
run;


/*EX2.EX2STDAT.first R-GemOx�����������ҩ_����	EX2.EX2ENDAT.last R-GemOx�����������ҩ_����		*/
**EX2;
data ex2;
set raw.ex2;
ex2stdatn = input(exstdat,yymmdd10.);
ex2endatn = input(exendat,yymmdd10.);
run;
proc sort data=ex2; by usubjid ex2stdatn ;run;

data tmp5f tmp5l;
set  ex2;
by usubjid ex2stdatn;
if first.usubjid then output tmp5f;
if last.usubjid then output tmp5l;
keep usubjid ex2stdat ex2endat;
run;

proc sort data=tmp5f(rename=(ex2stdat=fstex2 ex2endat=fenex2));
by usubjid;run;
proc sort data=tmp5l(rename=(ex2stdat=lstex2 ex2endat=lenex2));
by usubjid;run;

data tmp5;
merge tmp5f tmp5l;
by usubjid;
drop fenex2 lstex2;
label fstex2 = "R-GemOx利妥昔单抗给药_最早" lenex2 ="R-GemOx利妥昔单抗给药_最晚";

run;


/*SV.SVSTDAT.last Latest_Visit Latest_Visit_Date	*/
proc sort data=raw.sv;by usubjid svstdat;run;

data tmp6;
set raw.sv;
by usubjid svstdat;
if last.usubjid;
keep usubjid VISIT SVSTDAT ;
run;

/*DSEOT.DSENDAT	'EOT_Date' DSEOT.DSEOTREA 'Primary Reason for Discontinuation'	"IF EOT='' THEN TOD-FSTEX ELSE EOT-FSTEX" 'Duration_of_Dosing760'	*/
data tmp7;
set raw.dseot;
keep usubjid DSENDAT DSEOTREA;
run;

/*DSSUR.DSDAT.last 'Latest_OS_Date'	DSSUR.DSDAT.last.DSSTAT 'Survival Status'	*/
proc sort data=raw.dssur;by usubjid DSDAT;run;

data tmp8;
set raw.dssur;
by usubjid DSDAT;
if last.uaubjid;
keep usubjid DSDAT DSSTAT;
run;

/*EOS.DSEOSDAT 'EOS_Date'	EOS.DSEOSREA  'Primary Reason for End of Study'*/
 			
data tmp9;
set raw.eos;
keep usubjid DSEOSDAT DSEOSREA;
run;

%macro sort(a);
proc sort data=&a.;by usubjid;run;
%mend sort;

%sort(tmp1) %sort(tmp2) %sort(tmp3)
%sort(tmp4) %sort(tmp5) %sort(tmp6)
%sort(tmp7) %sort(tmp8) %sort(tmp9)
data subjdetail raw.subj_detail;
merge tmp1 - tmp9;
by usubjid;
run;






































