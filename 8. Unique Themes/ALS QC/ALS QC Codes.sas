filename input  'C:\CWP\ALS QC\ALS.xlsx';
filename output  'C:\CWP\ALS QC\SCREEN_QClist.xlsx';
proc import datafile = input out = Fields dbms = xlsx replace;
getnames = yes;
sheet = Fields;
run;
proc import datafile = input out = Forms dbms = xlsx replace;
getnames = yes;
sheet = Forms;
run;
proc import datafile = input out = DataDictionaryEntries dbms = xlsx replace;
getnames = yes;
sheet = DataDictionaryEntries;
run;

*************核查实验室字段是否勾选分析名及临床意义选项**********;
data test1;
set Fields(keep = FormOID FieldOID DraftFieldActive DataFormat AnalyteName IsClinicalSignificance);
if DraftFieldActive = 'TRUE' and dataformat = '12.5' and ( AnalyteName = '' or IsClinicalSignificance = 'FALSE');
Findings = '请核查此字段是否为实验室字段，以及是否勾选了分析名及临床意义选项';
run;

*************核查实验室表格的采样日期是否勾选了Oberservation Date of Form***********;
proc sql;
	create table _test2 as select distinct FormOID from Fields
	where DraftFieldActive = 'TRUE' and AnalyteName ^= '';
	create table test2 as select a.FormOID,b.FieldOID,b.CanSetDataPageDate,'核查实验室表格的采样日期未勾选了Oberservation Date of Form' as Findings from _test2 as a
	left join Fields as b on a.FormOID = b.FormOID
	where b.FieldOID = 'LBDAT' and b.CanSetDataPageDate = 'FALSE';
quit;


*************字段的默认值长度需要跟字段的格式匹配**********************;
Data test3(keep = FormOID FieldOID DataFormat DefaultValue comments);
	set Fields;
	if DraftFieldActive = 'TRUE' and DefaultValue ^= '' and DataDictionaryName = '';
	varLength = kLength(DefaultValue);
	if index(DataFormat,'$')>0 then NUM = scan(DataFormat,-1,'$') * 1;
	else NUM = DataFormat * 1;
	if NUM < varLength then do
	comments = '字段的默认值长度字段的格式不匹配';
	output;
	end;
run;


***************日期型字段需要设置未来日期和不规则数据的系统核查**********************;
Data test4;
set Fields(keep = FormOID FieldOID DraftFieldActive DataFormat  QueryFutureDate QueryNonConformance);
if DraftFieldActive = 'TRUE' and (DataFormat = 'yyyy mm dd' or DataFormat = 'yyyy mm- dd-'or DataFormat = 'dd MMM yyyy' or 
DataFormat = 'dd- MMM- yyyy' or DataFormat = 'yyyy/mm/dd' or DataFormat = 'yyyy/mm-/dd-'or DataFormat = 'dd/MMM/yyyy' or DataFormat = 'dd-/MMM-/yyyy') and (QueryFutureDate = 'FALSE' or QueryNonConformance = 'FALSE');
Findings = '日期型字段需要设置未来日期和不规则数据的系统核查';
run;


***************数值型字段需要设置不规则数据的系统核查**********************;
Data test5(keep = FormOID FieldOID ControlType DataFormat QueryNonConformance Findings);
set Fields;
if  DataFormat ^= ''  and substr(DataFormat,1,1) ^= '$'  and EntryRestrictions = '' and ViewRestrictions = '' and DraftFieldActive = 'TRUE' and ControlType = 'Text' and DataDictionaryName = '' and QueryNonConformance = 'FALSE';
Findings = '数值字段需要设置不规则数据的系统核查';
run;


*********************字段OID以数字开头或者有小写字母，或者长度大于8，或字段OID与字段名称，变量名称不一致*****************;
Data test6;
set Fields(keep = FormOID FieldOID DraftFieldActive VariableOID DraftFieldName);
if  DraftFieldActive = 'TRUE' and VariableOID ^ = '' and  (PRXMATCH("/^[0-9]/",FieldOID) > 0 or PRXMATCH("/[a-e]/",FieldOID) > 0 or Length(FieldOID) > 8 or FieldOID ^= VariableOID or FieldOID ^= DraftFieldName or VariableOID ^= DraftFieldName);
Findings = '字段OID以数字开头或者有小写字母，或长度大于8，或字段OID与字段名称，变量名称不一致,请核查是否有问题';
run;

********************对研究者设置了录入和查看限制的字段，不需要做签名，审核和原始数据核查**********************;
Data test8(keep = FormOID FieldOID ViewRestrictions EntryRestrictions DoesNotBreakSignature SourceDocument ReviewGroups Findings);
set Fields;
if  DraftFieldActive = 'TRUE' and (ViewRestrictions ^= '' or EntryRestrictions ^= '') and (DoesNotBreakSignature = 'FALSE' or SourceDocument = "TRUE" or ReviewGroups ^= '');
Findings = '对研究者设置了录入和查看限制的字段，不需要做签名，审核和原始数据核查';
run;

*******************带字典的字段的编码值与默认值不一致********************;
Data test10;
set Fields(keep = FormOID FieldOID DraftFieldActive DataDictionaryName DefaultValue);
if  DraftFieldActive = 'TRUE' and DefaultValue ^= '' and DataDictionaryName ^= '';
run;
Data test11;
set DataDictionaryEntries(keep = DataDictionaryName CodedData);
run;
proc sort data = test10;
by DataDictionaryName;
run;
proc sort data = test11;
by DataDictionaryName;
run;
data _test12;
merge test11 test10;
by DataDictionaryName;
if DefaultValue ^= '';
retain DictionaryValue;
if first.DataDictionaryName then DictionaryValue = CATS('' , CodedData,'|');
else DictionaryValue = CATS(DictionaryValue,CodedData , '|');
if last.DataDictionaryName then output;
run;

data test12(drop = CodedData DraftFieldActive);
	retain FormOID FieldOID DataDictionaryName DefaultValue DictionaryValue;
	set _test12;
	if DefaultValue ^= DictionaryValue then do
		Findings = '带字典的字段的编码值与默认值不一致';
		output;
	end;
RUN;

*****************字段需要做SDV和DM reivew***************;
Data test22(keep = FormOID FieldOID  DoesNotBreakSignature SourceDocument ReviewGroups Findings);
set Fields;
if  VariableOID ^= '' and DraftFieldActive = 'TRUE' and DefaultValue = '' and ViewRestrictions = '' and EntryRestrictions = '' and (SourceDocument = "FALSE" or ReviewGroups = '');
Findings = '字段需SDV和DM Review，请核查是否需要勾选';
run;

***************字段格式长度与字典编码制长度不匹配********************;
Data test23;
set Fields(keep = FormOID FieldOID DraftFieldActive DataDictionaryName DataFormat);
if DraftFieldActive = 'TRUE' and DataDictionaryName ^= "";
run;
Data test24;
set DataDictionaryEntries(keep = DataDictionaryName CodedData);
if Length(CodedData) >= 2;
run;
proc sort data = test23;
by DataDictionaryName;
run;
proc sort data = test24 ;
by DataDictionaryName;
run;
data test25;
merge test23(in = in2) test24(in=in1);
if index(DataFormat,'$')>0 then NUM = scan(DataFormat,-1,'$') * 1;
else NUM = DataFormat * 1;
by DataDictionaryName;
if in1 and in2 and NUM < Length(CodedData);
Findings = '字段格式长度与字典编码制长度不匹配';
run;


**************************同一个表中不能有重复的SAS Label***************;
Data test26(keep = FormOID SASLabel FieldOID);
set Fields;
if  DraftFieldActive = 'TRUE' and SASLabel ^= '';
run;
proc sort data = test26 out = dupout  nouniquekey;
by FormOID SASLabel;
run;
data dupout;
	set dupout;
	Findings = '同一个表格中有相同的SAS Label,请修改';
run;

***************SAS Label不等于字段的Pretext****************************;
Data test31(keep = FormOID FieldOID PreText SASLabel Findings);
set Fields;
if  SASLabel ^= PreText and VariableOID ^= '' and DraftFieldActive = 'TRUE' and ViewRestrictions = '';
	Findings = 'SAS Label与字段信息不一致，请核实';
run;

**************Power User角色不要限制任何字段的View权限*******************;
Data test32(keep = FormOID FieldOID  ViewRestrictions Findings);
set Fields;
if  VariableOID ^= '' and DraftFieldActive = 'TRUE' and index(ViewRestrictions,'Power User') > 0;
Findings = 'Power User角色不要限制任何字段的View权限';
run;

*************检查框类型字段不能勾选必填的系统质疑**********************;
Data test33(keep = FormOID FieldOID ControlType IsRequired comments);
	set Fields;
	if DraftFieldActive = 'TRUE' and ControlType = 'CheckBox' and IsRequired = 'TRUE';
	comments = 'CheckBox字段勾选了必填的系统质疑，请修改';
run;

/*out to excel*/
%macro out(data,data1);
PROC EXPORT DATA=&data. 
            OUTFILE= output
            DBMS=EXCEL2007 REPLACE label;
            SHEET="&data1."; 
RUN;
%mend out;
%out(test6,Field_Variable_Compare);
%out(dupout,SASLabel_Duplicate);
%out(test31,SASLabel_NotEqual_FieldLabel);
%out(test8,SDV_REVIEW_SIGNATRUE);
%out(test32,PowerUser_ViewRestriction);
%out(test1,Lab_Analyte_Setting);
%out(test2,Lab_Observation_Date_Setting);
%out(test3,Default_Value_Setting);
%out(test4,System_Check_FutureDATE);
%out(test5,System_Check_Nonconformance);
%out(test25,DictionaryFormatError);
%out(test12,Default_Value_Dictionary);
%out(test22,SDV_REVIEW_SIGNATRUE1);
%out(test33,CheckBox_RequriedCheck);

