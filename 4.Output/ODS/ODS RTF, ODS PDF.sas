*/////////////////////////////////////////////////////////////////////////////////;

*导RTF/PDF之前，对数据集要做的准备;
data all;
merge icf eot la lpe bmb bmp cp pr;
by subject;
run;

data raw.final;
set all; 
pagebrk=_n_;
run;
*数出共output多少页，用于设置页脚;
proc sql;
	select strip(put(max(pagebrk),best.))  into: lastpage from rawdata.final;
quit;
%put &lastpage.;

*设置output报告上的页脚：日期和时间为系统日期和时间;
data _null_;
call symput ('time',put (time(),time.));
call symput ('date',put (date(),date9.));
run;
%put &time. &date.;

*/////////////////////////////////////////////////////////////////////////////////;
*1.每个受试者导出一个RTF：
结构：ods的开始及结束设置在%report的宏里面（即每个受试者都要运行一次ODS风格即各个参数），然后将所有受试者ID用一个%loop宏derive出来，并嵌套%report的宏在该宏里面。
;
ods noresults;
ods path Work.Templat(UPDATE) Sashelp.Tmplmst(READ); 
%macro reportrtf(subj=);
*确定导出RTF文件的路径及风格;
ods rtf file="&root.\&_mode.\Output\RTF\&_Date.\XYZ_PatientProfile_&subj..rtf"  style=styles.custom; /**/

*设置导出RTF文件的参数;
ods escapechar = "~"; 
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods startpage=no;*不同的proc report结果之间去掉分页符;
ods rtf TITLE="PatientProfile" ANCHOR="PatientProfile"  NOTOC_DATA;

*设置RTF页眉：subjectno, ICF date, EOT date, tumor type;;
title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: XYZ Subject Number: #byval(subject)"; *指调用下方define的某个变量，需要在 proc report的by后面加上这个变量;
title3 h=9pt j=l  "Date of ICF Signed: #byval(icdat_raw)  EOT Date: #byval(eotdat_raw)  Tumor Type: #byval(latype)";

*设置RTF页脚:raw data 下载日期，当前页数/总页数（总页数output per subj时不需要，output all subj时需要）;
footnote2 h=9pt j=l"Raw data extracted on &_Date." ;*j=r "Page #byval1 of &lastpage.";*&_Date.为raw data下载日期，在程序最开始人工输入;

*导出数据集tmp1:;
proc report data=tmp1 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject icdat_raw eotdat_raw latype;
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Lymphatic Physical Examination(LPE)}" 
		subject latype eotdat_raw icdat_raw lpevisit lpedat_raw lpeayn lpeas lpeassp); 

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define lpevisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpedat_raw/"Exam Date"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeayn/"Abnormal lymph nodes assessed?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeas/"Anatomical site"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeassp/"Other, specify"   style(column)=[cellwidth=35% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tpm2:;
proc report data=tmp2 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Biopsy(BMB)}"  
       subject latype eotdat_raw icdat_raw bmbvisit bmbdat_raw bmbyn1 bmbres);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define bmbvisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define  bmbdat_raw/"Sample Collection date"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbyn1/"Bone Marrow Involvement?"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbres/"Diagnosis Result"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tmp3:;
proc report data=tmp3 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Aspirate(BMP)}" 
		subject latype eotdat_raw icdat_raw  bmpvisit BMPDAT_raw BMPIYN BMPRES BMPSP);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define bmpvisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpdat_raw/"Sample Collection date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpiyn/"Bone Marrow Involvement?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpres/"Diagnosis Result"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpsp/"Immunophenotype result"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tmp4: ;
proc report data=tmp4 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Surgery or Procedure(CP)}" 
		subject latype eotdat_raw icdat_raw CPTERM PT SOC CPSTDAT_raw CPONGO CPIND CPTYPE CPRES CPPOYN);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define CPTERM/"Procedure/surgery name"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PT/"PT Term"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define soc/"SOC Term"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPSTDAT_raw/"Date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPONGO/"Occurrence Stage"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPIND/"Indication"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPTYPE/"Sample type"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPRES/"Pathology Result"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPPOYN/"Disease transformation occured"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tpm5:;
proc report data=tmp5 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Radiotherapy(PR)}" 
		subject latype eotdat_raw icdat_raw  PRTERM PRSTDAT_raw PRONGO PRENDAT_raw PROCCUR PRDOSE PRUN PRUNSP);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define PRTERM/"Anatomical Site"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRSTDAT_raw/"Start date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRONGO/"Ongoing"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRENDAT_raw/"End date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PROCCUR/"Occurrence Stage"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRDOSE/"Total dose"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRUN/"Unit"   style(column)=[cellwidth=5% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRUNSP/"Other, specify"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

run;

ods rtf close;
title;
footnote;

ods listing;

%mend reportrtf;

%macro reportpdf(subj=);
*确定导出RTF文件的路径及风格;
ods pdf file="&root.\&_mode.\Output\PDF\&_Date.\XYZ_PatientProfile_&subj..pdf"  style=styles.custom; /**/

*设置导出RTF文件的参数;
ods escapechar = "~"; 
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods startpage=no;*不同的proc report结果之间去掉分页符;
ods PDF TITLE= "PatientProfile" ANCHOR = "PatientProfile" NOTOC;

*设置RTF页眉：subjectno, ICF date, EOT date, tumor type;;
title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: XYZ Subject Number: #byval(subject)"; *指调用下方define的某个变量，需要在 proc report的by后面加上这个变量;
title3 h=9pt j=l  "Date of ICF Signed: #byval(icdat_raw)  EOT Date: #byval(eotdat_raw)  Tumor Type: #byval(latype)";

*设置RTF页脚:raw data 下载日期，当前页数/总页数（总页数output per subj时不需要，output all subj时需要）;
footnote2 h=9pt j=l"Raw data extracted on &_Date." ;*j=r "Page #byval1 of &lastpage.";*&_Date.为raw data下载日期，在程序最开始人工输入;

*导出数据集tmp1:;
proc report data=tmp1 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject icdat_raw eotdat_raw latype;
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Lymphatic Physical Examination(LPE)}" 
		subject latype eotdat_raw icdat_raw lpevisit lpedat_raw lpeayn lpeas lpeassp); 

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define lpevisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpedat_raw/"Exam Date"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeayn/"Abnormal lymph nodes assessed?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeas/"Anatomical site"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeassp/"Other, specify"   style(column)=[cellwidth=35% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tpm2: ;
proc report data=tmp2 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Biopsy(BMB)}"  
       subject latype eotdat_raw icdat_raw bmbvisit bmbdat_raw bmbyn1 bmbres);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define bmbvisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define  bmbdat_raw/"Sample Collection date"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbyn1/"Bone Marrow Involvement?"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbres/"Diagnosis Result"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tmp3:;
proc report data=tmp3 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Aspirate(BMP)}" 
		subject latype eotdat_raw icdat_raw  bmpvisit BMPDAT_raw BMPIYN BMPRES BMPSP);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define bmpvisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpdat_raw/"Sample Collection date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpiyn/"Bone Marrow Involvement?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpres/"Diagnosis Result"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpsp/"Immunophenotype result"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tmp4: ;
proc report data=tmp4 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Surgery or Procedure(CP)}" 
		subject latype eotdat_raw icdat_raw CPTERM PT SOC CPSTDAT_raw CPONGO CPIND CPTYPE CPRES CPPOYN);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define CPTERM/"Procedure/surgery name"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PT/"PT Term"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define soc/"SOC Term"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPSTDAT_raw/"Date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPONGO/"Occurrence Stage"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPIND/"Indication"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPTYPE/"Sample type"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPRES/"Pathology Result"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPPOYN/"Disease transformation occured"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tpm5: ;
proc report data=tmp5 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Radiotherapy(PR)}" 
		subject latype eotdat_raw icdat_raw  PRTERM PRSTDAT_raw PRONGO PRENDAT_raw PROCCUR PRDOSE PRUN PRUNSP);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define PRTERM/"Anatomical Site"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRSTDAT_raw/"Start date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRONGO/"Ongoing"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRENDAT_raw/"End date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PROCCUR/"Occurrence Stage"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRDOSE/"Total dose"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRUN/"Unit"   style(column)=[cellwidth=5% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRUNSP/"Other, specify"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

run;

ods PDF close;
title;
footnote;

ods listing;

%mend reportpdf;

*将所有受试者ID作为宏变量，逐个受试者导出output;
%macro loop;
proc sql noprint;
select distinct subject into: subjlist separated by " "
from rawdata.final;
quit;

%let subjcount=%sysfunc(countw(&subjlist,%str( ))); 
%do i=1 %to &subjcount;

%let subjcurrent=%scan(&subjlist,&i,%str( ));
%put &subjcount.;
%put &subjcurrent.;
%reportrtf(subj=&&subjcurrent);
%reportpdf(subj=&&subjcurrent);

%end;
%mend loop;

%loop;

*/////////////////////////////////////////////////////////////////////////////////;

*2.所有受试者导成一个RTF：
结构：ODS的开始及结束设置在%report之外，%report内仅设置呈现在RTF中的内容，需要在%report里先定义去掉分页符ods startpage=now;
ods noresults;
ods path Work.Templat(UPDATE) Sashelp.Tmplmst(READ); 

*确定导出RTF文件的路径及风格;
ods rtf file="&root.\&_mode.\Output\XYZ_PatientProfile_All.rtf"  style=styles.custom; /*_&subj.*/

*设置导出RTF文件的参数;
ods escapechar = "~"; 
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods rtf TITLE="PatientProfile" ANCHOR="PatientProfile"  NOTOC_DATA;

%macro report(subj=);
ods startpage=now;*不同的proc report结果之间去掉分页符;

*设置RTF页眉：subjectno, ICF date, EOT date, tumor type;;
title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: XYZ Subject Number: #byval(subject)"; *指调用下方define的某个变量，需要在 proc report的by后面加上这个变量;
title3 h=9pt j=l  "Date of ICF Signed: #byval(icdat_raw)  EOT Date: #byval(eotdat_raw)  Tumor Type: #byval(latype)";

*设置RTF页脚:raw data 下载日期，当前页数/总页数（总页数output per subj时不需要，output all subj时需要）;
footnote2 h=9pt j=l"Raw data extracted on &_Date.";* j=r "Page #byval1 of &lastpage.";*&_Date.为raw data下载日期，在程序最开始人工输入;

*导出数据集tmp1:;
proc report data=tmp1 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;
where subject="&subj.";
column   ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Lymphatic Physical Examination(LPE)}" 
		subject latype eotdat_raw icdat_raw lpevisit lpedat_raw lpeayn  lpeas lpeassp); 
define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define lpevisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpedat_raw/"Exam Date"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeayn/"Abnormal lymph nodes assessed?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeas/"Anatomical site"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeassp/"Other, specify"   style(column)=[cellwidth=35% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

ods startpage=no;*不同的proc report结果之间去掉分页符;

*导出数据集tpm2: ;
proc report data=tmp2 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Biopsy(BMB)}"  
       subject latype eotdat_raw icdat_raw bmbvisit bmbdat_raw bmbyn1 bmbres);
define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define bmbvisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbdat_raw/"Sample Collection date"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbyn1/"Bone Marrow Involvement?"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmbres/"Diagnosis Result"   style(column)=[cellwidth=30% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tmp3:;
proc report data=tmp3 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Bone Marrow Aspirate(BMP)}" 
		subject latype eotdat_raw icdat_raw  bmpvisit BMPDAT_raw BMPIYN BMPRES BMPSP);
define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define bmpvisit/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpdat_raw/"Sample Collection date"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpiyn/"Bone Marrow Involvement?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpres/"Diagnosis Result"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define bmpsp/"Immunophenotype result"   style(column)=[cellwidth=25% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tmp4: ;
proc report data=tmp4 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Surgery or Procedure(CP)}" 
		subject latype eotdat_raw icdat_raw CPTERM PT SOC CPSTDAT_raw CPONGO CPIND CPTYPE CPRES CPPOYN);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define CPTERM/"Procedure/surgery name"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PT/"PT Term"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define soc/"SOC Term"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPSTDAT_raw/"Date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPONGO/"Occurrence Stage"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPIND/"Indication"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPTYPE/"Sample type"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPRES/"Pathology Result"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define CPPOYN/"Disease transformation occured"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

*导出数据集tpm5:;
proc report data=tmp5 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by  subject icdat_raw eotdat_raw latype;  
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Concomitant/Subsequent Radiotherapy(PR)}" 
		subject latype eotdat_raw icdat_raw  PRTERM PRSTDAT_raw PRONGO PRENDAT_raw PROCCUR PRDOSE PRUN PRUNSP);

define subject/"Subject number"  noprint flow ;
define icdat_raw/"ICF"  noprint  flow ;
define eotdat_raw/"EOT" noprint  flow ;
define latype/"Tumor type" noprint  flow ;

define PRTERM/"Anatomical Site"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRSTDAT_raw/"Start date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRONGO/"Ongoing"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRENDAT_raw/"End date"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PROCCUR/"Occurrence Stage"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRDOSE/"Total dose"   style(column)=[cellwidth=10% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRUN/"Unit"   style(column)=[cellwidth=5% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define PRUNSP/"Other, specify"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;

run;

%mend report;


*将所有受试者ID作为宏变量，逐个受试者导出output;
%macro loop;
proc sql noprint;
select distinct subject into: subjlist separated by " "
from all;
quit;

%let subjcount=%sysfunc(countw(&subjlist,%str( ))); 
%do i=1 %to &subjcount;

%let subjcurrent=%scan(&subjlist,&i,%str( ));
%put &subjcount.;
%put &subjcurrent.;

%report(subj=&&subjcurrent);

%end;
%mend loop;

%loop;

ods rtf close;
title;
footnote;

ods listing;
