filename input  'C:\CWP\Edit Check QC\ALS.xlsx';
filename DVP  'C:\CWP\Edit Check QC\Edit Check Template.xlsx';
filename output  'C:\CWP\Edit Check QC\Edit Check_QClist.xlsx';

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
proc import datafile = input out = Checks dbms = xlsx replace;
getnames = yes;
sheet = Checks;
run;
proc import datafile = input out = CheckSteps dbms = xlsx replace;
getnames = yes;
sheet = CheckSteps;
run;
proc import datafile = input out = CheckActions dbms = xlsx replace;
getnames = yes;
sheet = CheckActions;
run;
proc import datafile = DVP out = Edit_Check dbms = xlsx replace;
getnames = yes;
sheet = 逻辑核查;
run;

**********************************Only used for A83 *******************************;
Data Edit_Check;
	set Edit_Check;
	Form = scan(scan(Form,2,'('),1,')');
	Query_Target_Field = scan(scan(Query_Target_Field,2,'('),1,')');
run;


*************BypassDuringMigration选项没有勾选**********;
data test1(keep = CheckName CheckActive BypassDuringMigration Findings);
set Checks;
if CheckActive = 'TRUE' and BypassDuringMigration = 'FALSE';
Findings = 'BypassDuringMigration选项没有勾选,请确认';
run;

****************Check Steps*******************;
Data CheckSteps;
	set CheckSteps;
	_StepOrdinal = StepOrdinal * 1;
run;
proc sql;
	create table test2 as select a.CheckName,a._StepOrdinal,a.FormOID,a.FieldOID,a.VariableOID,a.RecordPosition
	,a.DataFormat as Data_Value from CheckSteps as a
	where VariableOID ^= '';
	create table test3 as select a.*,b.DataFormat,b.DataDictionaryName,b.ControlType,b.IsLog from test2 as a
	left join Fields as b on a.FormOID = b.FormOID and  a.FieldOID = b.FieldOID and  a.VariableOID = b.VariableOID;
	create table test4 as select a.*,b.CheckFunction from test3 as a
	left join CheckSteps as b on a.CheckName = b.CheckName and  a._StepOrdinal + 1= b._StepOrdinal;
quit;

*************CheckBox字段不能使用IsEmpty或者IsNotEmpty来判断是否勾选**********************;
data test5;
	set test4;
	if ControlType = 'CheckBox' and CheckFunction ^= '';
	Findings = 'CheckBox字段不能使用IsEmpty或者IsNotEmpty来判断是否勾选';
	drop _StepOrdinal DataFormat DataDictionaryName ControlType;
	Label Data_Value = 'Data Value';
run;

*************Log字段的Record Position不能是0**********************;
data test6;
	set test4;
	if IsLog = 'TRUE' and RecordPosition = '0';
	Findings = 'Log字段的Record Position不能是0';
	drop _StepOrdinal DataFormat DataDictionaryName ControlType;
	Label Data_Value = 'Data Value';
run;

*************所有发送质疑的Edit Check都需要勾选‘Requires Response’ and ‘Requires Manual Close’选项**********;
data test8(keep = CheckName ActionType ActionOptions Findings);
set Checkactions;
if ActionType = 'OpenQuery' and Index(ActionOptions,'To Site from System,RequiresResponse,RequiresManualClose') <= 0;
Findings = 'Edit Check没有勾选‘Requires Response’ and ‘Requires Manual Close’选项或者没有选择‘To Site from system’,请确认';
run;

*************Check Action中必须有一个字段包含在Check Step里**********;
proc sql;
	create table test9 as select a.CheckName,a.FormOID,a.VariableOID from CheckSteps as a
	left join Checkactions as b on a.CheckName = b.CheckName and a.FormOID = b.FormOID and a.VariableOID = b.VariableOID
	where a.CheckName ^= '' and b.CheckName ^= '';
quit;
proc sort data = test9 nodupkey;
by CheckName;
run;
proc sort data = Checks;
by CheckName;
data test10(KEEP = CheckName Findings);
	merge Checks(in = a) test9(in = b);
	by CheckName;
	if a and ^b and CheckActive = 'TRUE';
	Findings = '通常情况Check Action中必须有一个字段包含在Check Step里,请核查此Check是否有问题';
run;

*************DVP中质疑文字和质疑发送的位置需要与EDC中保持一致**********;
proc sql;
	create table test12 as select a.CheckName,a.FolderOID,a.FormOID,a.FieldOID,a.VariableOID,c.PreText,a.RecordPosition,a.ActionType,a.ActionString,b.Form as Form
,b.Query_Target_Field as Field,b.Query_Text as QueryText from Checkactions as a
	left join Edit_Check as b on a.CheckName = b.Check_Code
	left join Fields as c on a.FormOID = c.FormOID and a.FieldOID = c.FieldOID
	where  a.CheckName ^= '' and b.Check_Code ^= '' and a.ActionType = 'OpenQuery';
quit;

*************DVP中质疑文字与EDC中不一致**********;
data test13(keep = CheckName ActionString QueryText Findings);
	set test12;
	if ActionString ^= QueryText;
	drop ActionType PreText Form Field;
	Label ActionString = 'EDC系统中质疑文字'
		  QueryText = 'DVP中质疑文字';
	Findings = 'DVP中质疑文字与EDC中不一致';
run;

*************DVP中质疑发送的位置与EDC中不一致**********;
data test14(keep = CheckName EDC_Field Field Findings);
	set test12;
	if PreText ^= Field;
	EDC_Field = Pretext;
	drop ActionType Form ActionString QueryText Pretext;
	Label EDC_Field = 'EDC系统中字段文字信息'
		  Field = 'DVP中字段文字信息';
	Findings = 'DVP中字段文字信息与EDC中不一致';
run;

*************当质疑逻辑中包含XX为空或者XXX不为空，Check Step中应该使用User Value**********;
data test16;
	set test4;
	if (CheckFunction = 'IsNotEmpty' or CheckFunction = 'IsEmpty') and Data_Value ^= 'UserValue' and DataDictionaryName = '';
	Findings = '除数值类型字段大小比较外，当质疑逻辑中包含XX为空或者XXX不为空，Check Step中应该使用User Value,请核查';
	Label Data_Value = 'Data Value';
	drop _StepOrdinal DataFormat DataDictionaryName ControlType IsLog;
run;

/*out to excel*/
%macro out(data,data1);
PROC EXPORT DATA=&data. 
            OUTFILE= output
            DBMS=EXCEL2007 REPLACE label;
            SHEET="&data1."; 
RUN;
%mend out;
%out(test1,ByPassSetting);
%out(test5,CheckBox_Empty);
%out(test8,Response_ManualClose);
%out(test10,CheckAtion_CheckStep);
%out(test6,RecordPositionSetting);
%out(test13,QueryText_NotMatch);
%out(test14,QueryFiredField_NotMatch);
%out(test16,UserValue_NotUsed);

