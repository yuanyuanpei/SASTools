*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2020-689-00CH3
Program Name    :  Patient Profile Program: 1.Data.sas
Program Address :  O:\Project\689\2020-689-00CH3\DM\3-4 Ongoing\31_Data_cleaning\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2021/9/6
Validator Name  :  Liu Yang
Description     :  This program is used to set up needed datasets for output.
*********************************************************************************************;

libname rawdata "&root.\&_mode.\Data\&_Date.";

proc datasets library=rawdata;
modify la/correctencoding=utf8;
quit;

proc datasets library=rawdata;
modify bmp/correctencoding=utf8;
quit;

/*proc datasets library=rawdata;*/
/*modify final/correctencoding=utf8;*/
/*quit;*/

data la;
set rawdata.la(keep=subject latype);
run;

/*data nc;*/
/*set rawdata.nc(keep=subject InstanceName NCYN);*/
/*if InstanceName="C2D1" and NCYN="Yes" then output nc;*/
/*/*else output nc2;*/*/
/*drop InstanceName NCYN;*/
/*run;*/;
/*TLFYN=Yes in TL_FU或petyn=Yes in PET1*/;
data ls1;
set rawdata.tl_fu;
IF TLFYN="Yes";
keep subject TLFYN;
run;

data ls2;
set rawdata.pet1;
IF PETYN="Yes";
keep subject PETYN;
run;
PROC SQL;
CREATE TABLE NC AS
SELECT DISTINCT SUBJECT FROM LS1
UNION 
SELECT DISTINCT SUBJECT FROM LS2
;
QUIT;

data lpe;
set rawdata.lpe;
keep subject instancename lpedat_raw lpedat lpeayn lpeas lpeassp;
run;

data bmb;
set rawdata.bmb;
keep subject instancename bmbdat_raw bmbdat bmbyn1 bmbres;
run;

data bmp;
set rawdata.bmp(keep=subject instancename BMPDAT_raw BMPDAT BMPIYN BMPRES BMPSP);
run;

data endo1;
set rawdata.endo1(keep=subject InstanceName ENDO1YN ENDO1DAT_RAW ENDO1DAT ENDO1LY);
run;

data endo2;
set rawdata.endo2(keep=subject ENDO2YN ENDO2DAT_RAW ENDO2DAT ENDO2LY);
InstanceName="Treatment";
rename ENDO2YN=ENDO1YN;
rename ENDO2DAT_RAW=ENDO1DAT_RAW;
rename ENDO2LY=ENDO1LY;
rename ENDO2DAT=ENDO1DAT;
run;

proc sort data=endo1;by subject;run;
proc sort data=endo2;by subject;run;

data endo;
set endo1 endo2;
by subject;
run;

proc sort data=endo;by subject InstanceName;run;

data cp;*CODING pending;
format cpind cptype $600.;
set rawdata.cp;
PT=" ";
if cptypesp ^='' then cptype=trim(cptype||'/'||cptypesp);
if cpsp^='' then CPIND=trim(cpind||'/'||cpsp);
keep subject CPYN RecordPosition CPTERM pt CPSTDAT_raw CPSTDAT CPONGO CPIND CPTYPE CPRES CPPOYN;
run;


data pr;
set rawdata.pr;
keep subject PRTERM PRSTDAT_raw PRSTDAT PRONGO PRENDAT_raw;
run;

proc sort data=la;by subject;run;
proc sort data=nc;by subject;run;
proc sort data=lpe;by subject;run;
proc sort data=bmb;by subject;run;
proc sort data=bmp;by subject;run;
proc sort data=endo;by subject;run;
proc sort data=cp; by subject;run;
proc sort data=pr; by subject;run;

data tmp1r;merge nc(in=a) la lpe;by subject;if a;type="LPE";run; proc sort data=tmp1r out=tmp1(drop=lpedat);by subject lpedat;run;
data tmp2r;merge nc(in=a) la bmb;by subject;if a;type="BMB";run; proc sort data=tmp2r out=tmp2(drop=bmbdat);by subject bmbdat;run;
data tmp3r;merge nc(in=a) la bmp;by subject;if a;type="BMP";run; proc sort data=tmp3r out=tmp3(drop=bmpdat);by subject bmpdat;run;
data tmp4r;merge nc(in=a) la endo;by subject;if a;type="END";run; proc sort data=tmp4r out=tmp4(drop=endo1dat);by subject ENDO1DAT;run;
data tmp5r;merge nc(in=a) la cp;by subject;if a;type="CP";run; proc sort data=tmp5r out=tmp5(drop=cpstdat);by subject CPSTDAT;run;
data tmp6r;merge nc(in=a) la pr;by subject;if a;type="PR";run; proc sort data=tmp6r out=tmp6(drop=prstdat);by subject PRSTDAT;run;
data all3;
set tmp1 tmp2 tmp3 tmp4 tmp5 tmp6;
run;
/*data allr;merge nc(in=a) la lpe bmb bmp endo cp pr;by subject;if a;run; */
/*proc sort data=allr out=all(drop=lpedat bmbdat bmpdat endo1dat cpstdat prstdat);by subject lpedat bmbdat bmpdat endo1dat cpstdat prstdat;run;*/
data rawdata.final;set all3; *pagebrk=_n_;run;

/*proc sql;*/
/*	select strip(put(max(pagebrk),best.))  into: lastpage from rawdata.final;*/
/*quit;*/
/*%put &lastpage.;*/
*output;
data _null_;
call symput ('time',put (time(),time.));
call symput ('date',put (date(),date9.));
run;
%put &time. &date.;
