*********************************************************************************************
Company Name    :  HUTCHMED (China) Ltd.
Protocol No.    :  2020-689-00CH3
Program Name    :  Patient Profile Program: 3.1 Output Per Subject.sas
Program Address :  O:\Project\689\2020-689-00CH3\DM\3-4 Ongoing\31_Data_cleaning\Dev\Program
Author Name     :  Yuanyuan Pei
Creation Date   :  2021/9/6
Validator Name  :  Liu Yang
Description     :  This program is used to output patient profile of each.
*********************************************************************************************;

ods noresults;
ods path Work.Templat(UPDATE) Sashelp.Tmplmst(READ); 
%macro reportrtf(subj=);
*ȷ������RTF�ļ���·�������;
ods rtf file="&root.\&_mode.\Output\RTF\&_Date.\2020-689-00CH3_PatientProfile_&subj..rtf"  style=styles.custom; /**/

*���õ���RTF�ļ��Ĳ���;
ods escapechar = "~"; *ָ����������ڸ�ʽ���ŵģ������ַ�;
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods startpage=no;*��ͬ��proc report���֮��ȥ���ҳ���������Զ��嶨λ����ÿ��subj�̶���tmp3�����ı�񣩣�������һ��code�е�ANCHOR����λ;
ods rtf TITLE="PatientProfile" ANCHOR="PatientProfile"  NOTOC_DATA;*ANCHOR��˳���ǣ���һ����Ĭ�ϣ�ΪPatientProfile���ڶ���ΪP..P..1��Ȼ����PP2,��������;

*����RTFҳü��subjectno, ICF date, EOT date, tumor type;;
title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: 2020-689-00CH3  Subject Number: #byval(subject)  Tumor type: #byval(latype)"; *ָ�����·�define��ĳ����������Ҫ�� proc report��by��������������;

*����RTFҳ��:raw data �������ڣ���ǰҳ��/��ҳ������ҳ��output per subjʱ����Ҫ��output all subjʱ��Ҫ��;
footnote2 h=9pt j=l"Raw data extracted on &_Date." ;*j=r "Page #byval1 of &lastpage.";*&_Date.Ϊraw data�������ڣ��ڳ����ʼ�˹�����;

*�������ݼ�tmp1:Lymphatic Physical Examination(LPE);
proc report data=tmp1 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject latype;
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Lymphatic Physical Examination}" 
		subject latype instancename lpedat_raw lpeayn lpeas lpeassp); 

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define instancename/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpedat_raw/"Exam Date"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeayn/"Abnormal lymph nodes assessed?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeas/"Anatomical site"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeassp/"Other, specify"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tpm2: Bone Marrow Biopsy(BMB);
proc report data=tmp2 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject latype;  
where subject="&subj.";
column ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Biopsy}"  
       subject latype instancename bmbdat_raw bmbyn1 bmbres);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define instancename/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define  bmbdat_raw/"Sample Collection date"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbyn1/"Bone Marrow Involvement?"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbres/"Diagnosis Result"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tmp3:Bone Marrow Aspirate(BMP);
proc report data=tmp3 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Aspirate}" 
		subject latype instancename BMPDAT_raw BMPIYN BMPRES BMPSP);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define instancename/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpdat_raw/"Sample Collection date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpiyn/"Bone Marrow Involvement?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpres/"Diagnosis Result"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpsp/"Immunophenotype result"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tmp4:Endoscopy(ENDO2);
proc report data=tmp4 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Endoscopy}" 
		subject latype instancename ENDO1YN ENDO1DAT_RAW ENDO1LY);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define instancename/"Phase"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define ENDO1YN/"Was endoscopy performed?"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define ENDO1DAT_RAW/"Exam Date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define ENDO1LY/"Lymphoma involvement"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;


*�������ݼ�tmp5: Concomitant/Subsequent Surgery or Procedure(CP);
proc report data=tmp5 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Surgery or Procedure}" 
		subject latype CPTERM PT CPSTDAT_raw CPIND CPTYPE CPRES CPPOYN);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define CPTERM/"Procedure/surgery name"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PT/"PT Term"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPSTDAT_raw/"Date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPIND/"Indication"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPTYPE/"Sample type"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPRES/"Pathology Result"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPPOYN/"Disease transformation occured"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tpm6: Concomitant/Subsequent Radiotherapy(PR);
proc report data=tmp6 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Radiotherapy}" 
		subject latype PRTERM PRSTDAT_raw PRONGO PRENDAT_raw);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define PRTERM/"Anatomical Site"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRSTDAT_raw/"Start date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRONGO/"Ongoing"  style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRENDAT_raw/"End date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
run;

ods rtf close;
title;
footnote;

ods listing;

%mend reportrtf;

%macro reportpdf(subj=);
*ȷ������RTF�ļ���·�������;
ods pdf file="&root.\&_mode.\Output\PDF\&_Date.\2020-689-00CH3_PatientProfile_&subj..pdf"  style=styles.custom; /**/

*���õ���RTF�ļ��Ĳ���;
ods escapechar = "~"; 
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods startpage=no;*��ͬ��proc report���֮��ȥ���ҳ��;
ods PDF TITLE= "PatientProfile" ANCHOR = "PatientProfile" NOTOC;

*����RTFҳü��subjectno, ICF date, EOT date, tumor type;;
title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: 2020-689-00CH3 Subject Number: #byval(subject) Tumor Type: #byval(latype)"; *ָ�����·�define��ĳ����������Ҫ�� proc report��by��������������;

*����RTFҳ��:raw data �������ڣ���ǰҳ��/��ҳ������ҳ��output per subjʱ����Ҫ��output all subjʱ��Ҫ��;
footnote2 h=9pt j=l"Raw data extracted on &_Date." ;*j=r "Page #byval1 of &lastpage.";*&_Date.Ϊraw data�������ڣ��ڳ����ʼ�˹�����;

*�������ݼ�tmp1:Lymphatic Physical Examination(LPE);
proc report data=tmp1 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject latype;
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Lymphatic Physical Examination}" 
		subject latype instancename lpedat_raw lpeayn lpeas lpeassp); 

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;
define instancename/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpedat_raw/"Exam Date"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeayn/"Abnormal lymph nodes assessed?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeas/"Anatomical site"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeassp/"Other, specify"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tpm2: Bone Marrow Biopsy(BMB);
proc report data=tmp2 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject latype;  
where subject="&subj.";
column ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Biopsy}"  
       subject latype instancename bmbdat_raw bmbyn1 bmbres);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define instancename/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define  bmbdat_raw/"Sample Collection date"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbyn1/"Bone Marrow Involvement?"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbres/"Diagnosis Result"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tmp3:Bone Marrow Aspirate(BMP);
proc report data=tmp3 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Aspirate}" 
		subject latype instancename BMPDAT_raw BMPIYN BMPRES BMPSP);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define instancename/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpdat_raw/"Sample Collection date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpiyn/"Bone Marrow Involvement?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpres/"Diagnosis Result"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpsp/"Immunophenotype result"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tmp4:Endoscopy(ENDO2);
proc report data=tmp4 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Endoscopy}" 
		subject latype instancename ENDO1YN ENDO1DAT_RAW ENDO1LY);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define instancename/"Phase"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define ENDO1YN/"Was endoscopy performed?"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define ENDO1DAT_RAW/"Exam Date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define ENDO1LY/"Lymphoma involvement"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;


*�������ݼ�tmp5: Concomitant/Subsequent Surgery or Procedure(CP);
proc report data=tmp5 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Surgery or Procedure}" 
		subject latype CPTERM PT CPSTDAT_raw CPIND CPTYPE CPRES CPPOYN);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define CPTERM/"Procedure/surgery name"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PT/"PT Term"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPSTDAT_raw/"Date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPIND/"Indication"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPTYPE/"Sample type"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPRES/"Pathology Result"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPPOYN/"Disease transformation occured"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tpm6: Concomitant/Subsequent Radiotherapy(PR);
proc report data=tmp6 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Radiotherapy}" 
		subject latype PRTERM PRSTDAT_raw PRONGO PRENDAT_raw);

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;

define PRTERM/"Anatomical Site"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRSTDAT_raw/"Start date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRONGO/"Ongoing"  style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRENDAT_raw/"End date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

run;

ods PDF close;
title;
footnote;

ods listing;

%mend reportpdf;


libname olddata "&root.\&_mode.\Data\&_LDate.";

data ofinal;
set olddata.final;
drop pagebrk ;
run;

data nfinal;
set rawdata.final;
drop pagebrk ;
run;
proc sort data=ofinal;by _all_;run;
proc sort data=nfinal;by _all_;run;
data com;
merge ofinal(in=a) nfinal(in=b);
by _all_;
if a and not b then flag="delete";
if a and b then flag="old";
if not a and b then flag="change";
/*keep subject flag;*/
run;
proc sql;
create table all as
select distinct subject from com;

create table chg as
select distinct subject from com
where flag in ("delete","change")
and subject not in (select subject from tmpnew);

create table nochg as
select subject from all
except
select subject from chg;
quit;


*������������ID��Ϊ���������������ߵ���output;
%macro loop_chg;
proc sql noprint;
select distinct subject into: subjlist separated by " "
from chg
;
quit;
%put &subjlist.;
%let subjcount=%sysfunc(countw(&subjlist,%str( ))); 
%do i=1 %to &subjcount;

%let subjcurrent=%scan(&subjlist,&i,%str( ));
%put &subjcount.;
%put &subjcurrent.;
%reportrtf(subj=&&subjcurrent);
%reportpdf(subj=&&subjcurrent);

%end;
%mend loop_chg;

%loop_chg;


