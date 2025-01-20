/*&root.\&_mode.\Output\Compare\&_LDate.-&_Date.;*/
%macro reportpdf(path=,subj=,otpt=);
ods pdf;
ods pdf file="&path.\2020-689-00CH3_PatientProfile&otpt._&subj..pdf"  style=styles.custom; /**/

ods escapechar = "~"; 
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods startpage=no;*��ͬ��proc report���֮��ȥ���ҳ��;
ods PDF TITLE= "PatientProfile" ANCHOR = "PatientProfile" NOTOC;

title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: 2020-689-00CH3 Subject Number: #byval(subject) Tumor Type: #byval(latype)"; *ָ�����·�define��ĳ����������Ҫ�� proc report��by��������������;


footnote2 h=9pt j=l"Raw data extracted on &_Date." ;*j=r "Page #byval1 of &lastpage.";*&_Date.Ϊraw data�������ڣ��ڳ����ʼ�˹�����;

*�������ݼ�tmp1:Lymphatic Physical Examination(LPE);
proc sort data=tmp1;by _all_;run;
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
proc sort data=tmp2;by _all_;run;
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
proc sort data=tmp3;by _all_;run;
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
proc sort data=tmp4;by _all_;run;
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
proc sort data=tmp5;by _all_;run;
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
proc sort data=tmp6;by _all_;run;
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


%mend reportpdf;

%macro reportrtf(path=,subj=,otpt=);
*ȷ������RTF�ļ���·�������;
ods rtf file="&path.\2020-689-00CH3_PatientProfile&otpt._&subj..rtf"  style=styles.custom; /**/

*���õ���RTF�ļ��Ĳ���;
ods escapechar = "~"; 
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods startpage=no;*��ͬ��proc report���֮��ȥ���ҳ��;
ods rtf TITLE="PatientProfile" ANCHOR="PatientProfile"  NOTOC_DATA;

*����RTFҳü��subjectno, ICF date, EOT date, tumor type;;
title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: 2020-689-00CH3 Subject Number: #byval(subject) Tumor Type: #byval(latype)"; *ָ�����·�define��ĳ����������Ҫ�� proc report��by��������������;

*����RTFҳ��:raw data �������ڣ���ǰҳ��/��ҳ������ҳ��output per subjʱ����Ҫ��output all subjʱ��Ҫ��;
footnote2 h=9pt j=l"Raw data extracted on &_Date." ;*j=r "Page #byval1 of &lastpage.";*&_Date.Ϊraw data�������ڣ��ڳ����ʼ�˹�����;

*�������ݼ�tmp1:Lymphatic Physical Examination(LPE);
proc sort data=tmp1;by _all_;run;
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
define lpeas/"Anatomical site"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeassp/"Other, specify"   style(column)=[cellwidth=35% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*�������ݼ�tpm2: Bone Marrow Biopsy(BMB);
proc sort data=tmp2;by _all_;run;
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
proc sort data=tmp3;by _all_;run;
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
proc sort data=tmp4;by _all_;run;
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
proc sort data=tmp5;by _all_;run;
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
proc sort data=tmp6;by _all_;run;
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


%mend reportrtf;

libname orig "&root.\&_mode.\Data\&_LDate.";
libname revi "&root.\&_mode.\Data\&_Date.";
proc sort data=orig.final out=orig.subjlist(keep=subject) nodupkey;by subject;run;
proc sort data=revi.final out=revi.subjlist(keep=subject) nodupkey;by subject;run;

*1.Output 本次所有受试者的RTF;
data all_subj;*otpt=;*path=&root.\&_mode.\Output\RTF\&Date.;
set revi.subjlist;
run;
*2.与上轮比较新加的受试者;
data new_subj;*otpt=_new;*path=&root.\&_mode.\Output\Compare\&LDate.-&Date.;
merge orig.subjlist(in=a) revi.subjlist(in=b);
by subject;
if a=0 and b=1;
run;
*3.两轮均有的受试者，有change的，需运行docm(RTF\&Date.CHG);
*4.两轮均有的受试者，没change的，直接导出;
proc sort data=orig.final;by _all_;run;*;
proc sort data=revi.final;by _all_;run;*;
data subj_tmp;
merge orig.final(in=a) revi.final(in=b);
by _all_;
if a and not b then flag= "delete";
if a and b then flag = "old";
if not a and b then flag = "change";
run;
proc sql;*subj_chg的受试者先导出至path:&root.\&_mode.\Output\RTF\20230802\CHG,otpt=.;
create table subj_chg as
select distinct subject from subj_tmp
where flag in ("delete","change") and subject not in (select subject from new_subj);

create table subj_nochg as
select distinct subject from all_subj
except
select distinct subject from subj_chg
except
select distinct subject from new_subj;
quit;


