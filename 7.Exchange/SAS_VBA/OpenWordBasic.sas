***Open Doc1.docm with macros***;
options noxwait noxsync;
x '"C:\Program Files\Microsoft Office\Office16\WINWORD.EXE"';

data _null_;
x=sleep(5);
run;

filename cdms dde 'WinWord|System';

data _null_;
file cdms;
put '[FileOpen.Name = "C:\Users\yuanyuanp\Desktop\Doc1.docm "]';
/*put '[RUN("NewMacros")]';*/
run;
