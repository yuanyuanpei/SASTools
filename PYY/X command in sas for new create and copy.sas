
%let path1=C:\Users\yuanyuanp\Desktop;
options noxwait xmin;
*?path1???????TTTT;
x "md ""&path1.\TTTT""";


*?TTTT????????path2;
%let path2=C:\Users\yuanyuanp\Desktop\TTTT;

*?path1???.docx????????path2?;
x "xcopy /y ""&path1.\test1.docx"" &path2.\";

*?path1???.docx????????path2?;
x "move /y ""&path1.\test1.docx"" &path2.\";


*???????:;
systask command "xcopy /y ""&path1.\test1.docx"" &path2.\";
