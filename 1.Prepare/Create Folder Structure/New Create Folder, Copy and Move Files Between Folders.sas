* define the path you want to new create folder structure:;
%let path=C:\Users\yuanyuanp\Desktop;
options noxwait xmin;
x "md  ""&path.\Dev""";
x "md  ""&path.\Dev\Data""";
x "md  ""&path.\Dev\Document""";
x "md  ""&path.\Dev\Log""";
x "md  ""&path.\Dev\Output""";
x "md  ""&path.\Dev\Program""";

x "md  ""&path.\Prd""";
x "md  ""&path.\Prd\Data""";
x "md  ""&path.\Prd\Document""";
x "md  ""&path.\Prd\Log""";
x "md  ""&path.\Prd\Output""";
x "md  ""&path.\Prd\Program""";


*Copy file from path1 folder to path2 folder;
x "xcopy /y ""&path1.\test1.docx"" &path2.\";

*Move file from path1 folder to path2 folder;
x "move /y ""&path1.\test1.docx"" &path2.\";

