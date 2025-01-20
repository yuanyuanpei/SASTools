*Fetch root of current program;
%let _mode=Prd;* Dev for development programs and Prod for production programs.;

*Method 1, available on SAS PC;
%macro currentroot;
    %global currentroot;
    %let currentroot=%sysfunc(getoption(sysin));
    %if "&currentroot" eq "" %then %do;
        %let currentroot=%sysget(SAS_EXECFILEPATH);
    %end;
%mend;

%currentroot

%put &currentroot.;

*Fetch part of current root(e.g. part before prd);

%let root=%substr(%str(&currentroot),1,%index(%str(&currentroot.),%str(Prd))-1);

%put &root.;

*Method 2, available on SAS EG;
%let currentPath = %scan(&_sasprogramfile.,1,"'");
%put &currentPath.;

%let root=%substr(%str(&currentPath),1,%index(%str(&currentPath),%str(\&_mode.\))-1);
%put &root.;
