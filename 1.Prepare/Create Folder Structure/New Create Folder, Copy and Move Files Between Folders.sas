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

*读取某个文件夹下的所有文件:;
**使用SAS PC版:;
/*filename yyy pipe "dir ""&root.\&_mode.\Program"" /b";*/
使用SASEG服务器版:;

data yyy;
   *keep pname;
   length pname   $100 FileRef $8;

   /* Assign the fileref */
   call missing(FileRef); /* Blank, so SAS will assign a file name */
   rc1 = filename(FileRef, "&root.\&_mode.\Program"); /* Associate the file name with the directory */
   if rc1 ^= 0 then
      abort;

   /* Open the directory for access by SAS */
   DirectoryID = dopen(FileRef);
   if DirectoryID = 0 then
      abort;

   /* Get the count of directories and datasets */
   MemberCount = dnum(DirectoryID);
   if MemberCount = 0 then
      abort;

   /* Get all of the entry names ... directories and datasets */
   do MemberIndex = 1 to MemberCount;
      pname = dread(DirectoryID, MemberIndex);
      if missing(pname) then
         abort;

      output;
   end;

   /* Close the directory */
   rc2 = dclose(DirectoryID);
   if rc2 ^= 0 then
      abort;
run;
