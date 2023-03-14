*Fetch root of current program;

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