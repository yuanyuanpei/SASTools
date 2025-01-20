*Clear SAS environment;



data folder;
set ALSBI.folders;
keep OID Ordinal FolderName translate_FolderName;
rename OID=FolderOID Ordinal=FolderSeq FolderName=FolderNameCN translate_FolderName=FolderNameEN;
run;

data form;
set ALSBI.Forms;
keep OID Ordinal DraftFormName translate_DraftFormName;
where DraftFormActive="TRUE";
rename OID=FormOID Ordinal=FormSeq DraftFormName=FormNameCN translate_DraftFormName=FormNameEN;
run;

data fieldr;
set ALSBI.Fields;
keep FormOID FieldOID Ordinal DataFormat DataDictionaryName ControLType PreText translate_PreText SASLabel;
where DraftFieldActive="TRUE";
rename Ordinal=FieldSeq PreText=FieldNameCN translate_PreText=FieldNameEN;
run;
*fields in active forms;
proc sql;
create table field as
select * from fieldr
where formOID in (select formOID from form);
quit;
*fields using coding dictionary;
data coDict;
set ALSBI.Fields;
keep FormOID FieldOID CodingDictionary PreText translate_PreText ;
where DraftFieldActive="TRUE" and CodingDictionary ^= "" ;
rename  PreText=FieldNameCN translate_PreText=FieldNameEN;
run;

*All dictionaries;
data dict;
set ALSBI.DataDictionaryEntries;
keep DataDictionaryName codedData UserDataString translate_UserDataString Specify;
where DataDictionaryName ^="";
rename UserDataString=OptionCN translate_UserDataString=OptionEN;
run;

*All dictionaries with/without specify=TRUE;
proc sql;
create table dictSPY as
select * from dict
where DataDictionaryName in (select DataDictionaryName from dict where specify="TRUE");

create table dictNoSPY as
select * from dict
where DataDictionaryName not in (select DataDictionaryName from dict where specify="TRUE");
quit;

*Connect all folder, form, filed, dictionary together in one dataset;
proc sql;
create table allals as
select form.formOID,form.formnameCN,form.formnameEN,field.FIELDoid,
FIELD.FIELDNAMECN,FIELD.FIELDNAMEEN,FIELD.DATADICTIONARYNAME,
DICT.CODEDDATA,DICT.OPTIONCN,DICT.OPTIONEN,DICT.SPECIFY
from (form left join field on form.formOID=field.FormOID)left join dict
on field.DataDictionaryName=dict.DataDictionaryName;
quit;

*Import sitelist;
data sitelst;
set sitebi.sheet1;
run;



