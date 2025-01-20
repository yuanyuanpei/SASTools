proc sql noprint;
select distinct subject into: all_subj separated by " "
from all_subj;

select distinct subject into: new_subj separated by " "
from new_subj;

select distinct subject into: subj_chg separated by " "
from subj_chg;

quit;
*������������ID��Ϊ���������������ߵ���output;
%macro loop_chg;
*1.Output 本次所有受试者的RTF;
%let subjcount=%sysfunc(countw(&all_subj,%str( ))); 
%do i=1 %to &subjcount;
%let subjcurrent=%scan(&all_subj,&i,%str( ));%put &subjcount.;%put &subjcurrent.;
%reportrtf(path=&root.\&_mode.\Output\RTF\&_Date.,subj=&&subjcurrent,otpt=);
%reportpdf(path=&root.\&_mode.\Output\PDF\&_Date.,subj=&&subjcurrent,otpt=);
%end;

*2.与上轮比较新加的受试者;
%let subjcount2=%sysfunc(countw(&new_subj,%str( ))); 
%do i=1 %to &subjcount2;
%let subjcurrent2=%scan(&new_subj,&i,%str( ));%put &subjcount2.;%put &subjcurrent2.;
%reportrtf(path=&root.\&_mode.\Output\Compare\&_LDate.-&_Date.,subj=&&subjcurrent2,otpt=_new);
%reportpdf(path=&root.\&_mode.\Output\Compare\&_LDate.-&_Date.,subj=&&subjcurrent2,otpt=_new);
%end;


*3.两轮均有的受试者，有change的，需运行docm(RTF\20230802\Change?);
%let subjcount3=%sysfunc(countw(&subj_chg,%str( ))); 
%do i=1 %to &subjcount3;
%let subjcurrent3=%scan(&subj_chg,&i,%str( ));%put &subjcount3.;%put &subjcurrent3.;
%reportrtf(path=&root.\&_mode.\Output\RTF\&_Date.CHG,subj=&&subjcurrent3,otpt=);
%end;


%mend loop_chg;

%loop_chg;
