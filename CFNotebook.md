# C# Code for Custom Function
# Yuanyuan Pei/May23,2022
## 1. Update Folder Name
```C#
    ///Update FolderName (add suffix or rearrange) (input e.g.:CYCLE)
	//CodedValue: 99-Other, please specify
	ActionFunctionParams afp = (ActionFunctionParams)ThisObject;
	DataPoint dpt = afp.ActionDataPoint;
	Subject subj = dpt.Record.Subject;

	string updFolderOID = "CYCLE";
	Instance inst = subj.instances.FindByFolderOID(updFolderOID);

	if (!CustomFunction.DataPointIsEmpty(dpt))
	{
		if (dpt.Data !== "99")
			inst.SetInstanceName(dpt.Data + " Day 01");
		else
			inst.SetInstanceName(dpt.UserValue().ToString() + " Day 01");
	}
	return null;
	///Update PageName (肿瘤评估非靶病灶_1_肝左叶，16进制unicode与中文互转）
	ActionFunctionParams afp = (ActionFunctionParams)ThisObject;
	DataPoint dpt = afp.ActionDataPoint;

	string Name_ID = "TUSPID";
	string Name_LOC = "TUSPLOC";
	DataPoint dpt_ID = dpt.Record.DataPoints.FindByFieldOID(Name_ID);
	DataPoint dpt_LOC = dpt.Record.DataPoints.FindByFieldOID(Name_LOC);

	string name = "";
	try
	{
		name = "_" + dpt_ID.Data + "_" + dpt_LOC.Data;
		//肿瘤评估非靶病灶的十六进制：
		dpt.Record.DataPage.Name = HexToCN(@"\u80bf\u7624\u8bc4\u4ef7\u005f\u9776\u75c5\u7076") + name;
	}
	catch
	{
	}
	return null;
}
private string HexToCN(string Hex_code)
{
	string outStr = "";
	if (!string.IsNullOrEmpty(Hex_code))
       {
		string[] strList = Hex_code.Replace("\\", "").Split('u');
		for (int i=1;i<strList.Length;i++)
         {
			outStr +=(char) int.Parse(strList[i]),System.Globalization.NumberStyles.HexNumber;
        }
    }
	return outStr;
}
```
## 2. Delete Folder Name Suffix
```C#
    ///Clear FolderName Suffix (input:)
	ActionFunctionParams afp = (ActionFunctionParams)ThisObject;
	DataPoint dpt = afp.ActionDataPoint;
	Subject subj = dpt.Record.Subject;
	Instances insts = subj.instances;

	foreach (Instance inst in insts)
	{
		if (inst.Folder.OID == "UNS" || inst.Folder.OID == "TU" || inst.Folder.OID == "CXD1") continue;
		inst.SetInstanceName("");
	}
	return null;
```
## 3. DSL_AE, Dynamic Search List.
```C#
	//760-DSL_AE, Dynamic Search List.
	//Linked edit checks:
	//1.If AETERM is not empty or AESTDAT is not empty, then CMINDAE1->set DSL_AE,CMINDCAE2->set DSL_AE,CMINDCAE3->set DSL_AE
	//2.If CMINDCAE1 is present, then CMINDCAE1->set DSL_AE
	//3.If CMINDCAE2 is present, then CMINDCAE2->set DSL_AE
	//4.If CMINDCAE3 is present, then CMINDCAE3->set DSL_AE

	DynamicSearchParams dsl = (DynamicSearchParams)ThisObject;//dsl参数
	DataPoint dp = dsl.DataPoint;//根据dsl参数找到当前数据点
	Subject sb = dp.Record.Subject;//找到当前受试者
	KeyValueCollection AE = new KeyValueCollection();//新建AE用于收集keyvalue
	Records rdsAE = sb.Instances.FindByFolderOID("LOG").DataPages.FindByFormOID("AE").Records;//找到受试者所有AE记录rdsAE
	for (int i = 1; i < rdsAE.Count; i++)  //每条AE记录来说（如AE#1,AE#2,AE#3...)
	{
		Record rdAE = rdsAE.FindByRecordPosition(i); //AE#i记录赋给rdAE
		if (rdAE.Active) //如果rdAE未失活
		{
			DataPoints dptsAE = rdAE.DataPoints; //找到该条AE记录的所有数据点dptsAE
					
			bool isEntry = false; //预设isEntry为F
			foreach (DataPoint dptAE in dptsAE) //该条AE记录的所有数据点中，对每个数据点来说
			{
				if (dptAE.EntryStatus == EntryStatusEnum.EnteredComplete) //如果数据点的entry状态为已录入
				{
					isEntry = true; //isentry为T
					break;//跳出整个foreach循环,continue跳出当前循环
				}
			}

			if (isEntry) //如果数据点状态为is entry
			{
				DataPoint dpAEterm = rdsAE.FindByRecordPosition(i).DataPoints.FindByFieldOID("AETERM"); //通过AE#i找到数据点AETERM
				DataPoint dpAEstdat = rdsAE.FindByRecordPosition(i).DataPoints.FindByFieldOID("AESTDAT"); //通过AE#i找到数据点AESTDAT
				AE.Add(new KeyValue(i.ToString(), i + "-" + dpAEterm.Data + "-" + dpAEstdat.Data)); //变量AE加一条value，key为i，值为i-TERM-DAT
			}
		}
	}
	return AE;

```
## 4. DSL_AE_Check: AE record is modified, then check whether the linked variable is updated.
```C#
			//Linked edit check:
			//If AETERM is Present or AESTDAT is Present or SUBJNUM is Present, then AETERM->CF DSL_AE_Check.

			ActionFunctionParams afp = (ActionFunctionParams)ThisObject;
			DataPoint input_DP = afp.ActionDataPoint;

			Subject subj = input_DP.Record.Subject;
			const string Term_OID = "AETERM";
			const string Date_OID = "AESTDAT";
			const string queryText = "The selected Adverse Event value has been modified on the Adverse Event form. Please re-select the correct event.";

			//Build DSL options
			DataPoints Term_DPs = CustomFunction.FetchAllDataPointsForOIDPath(Term_OID, null, null, subj, false);
			ArrayList arlValues = new ArrayList();
			arlValues.Add(string.Empty);

			for (int i = 0; i < Term_DPs.Count; i++)
			{
				DataPoint dpTerm = Term_DPs[i];
				string val;
				if (!dpTerm.Record.Active) continue;
				string recPos = dpTerm.Record.RecordPosition.ToString().PadLeft(3, '0');
				DataPoint dpDate = dpTerm.Record.DataPoints.FindByFieldOID(Date_OID);

				if (dpTerm.Data.Length > 160)
					val = String.Format("{0} > {1} > {2}", recPos, ((dpTerm.Data).Trim()).Substring(0, 160), dpDate.Data);
				else
					val = String.Format("{0} > {1} > {2}", recPos, (dpTerm.Data).Trim(), dpDate.Data);
				arlValues.Add(val);
			}

			//Find corresponding log dps on all corresponding forms using Dynamic SearchList
			string[] DSLFields =
			{
			"EXAE", "EXAE1", "EXAE2" , "EXOAE", "EXOAE1", "EXOAE2", "CMINDAE1", "CMINDAE2", "CMINDAE3", "PRINDAE1", "PRINDAE2", "PRINDAE3", "ECGINDAE1", "ECGINDAE2", "ECGINDAE3", "ECHOAE1", "ECHOAE2", "ECHOAE3"
		}
			;
			for (int i = 0; i < DSLFields.Length; i++)
			{
				DataPoints dpsDSL = CustomFunction.FetchAllDataPointsForOIDPath(DSLFields[i], null, null, subj);

				//Check currently entered value in DSL
				for (int j = 0; j < dpsDSL.Count; j++)
				{
					DataPoint dpDSL = dpsDSL[j];
					if (!dpDSL.Record.Active || dpDSL.Data.Length == 0) continue;
					bool IsNonConformant = !arlValues.Contains((dpDSL.Data).ToString());

					//dpDSL.SetNonConformant(IsNonConformant);
					CustomFunction.PerformQueryAction(queryText, 1, true, true, dpDSL, IsNonConformant);
				}
			}
			return null;
```
## 5. Derive values from Folder1-Form1 to FolderPost-Form1
```C#
			//1.if SCR_TLBNUM or TLBSC or TLBLOC or TLBPOS is not empty, then POST_TLBYN -> CF_Derive
			//2.if POST_TLBYN is not empty, then POST_TLBYN -> CF_Derive
			//为啥要写2条EC？Shaw Zhang: 1.里面筛选期的变量时固定的，没有动态的；2.里面的POST_TLBYN在一个Logline的表里。
			//所涉及的变量全都是default表/访视中的话，可以合在一起写，有logline的，有动态的，addevent出来的表里的变量，最好和default的表的变量分开
			//A表1数据点和2数据点是不同动态触发的 或者1数据点没动态 2有动态 也分开写
			//A表1，2都是3数据点=yes触发的 这种可以写一条

			ActionFunctionParams afp = (ActionFunctionParams)ThisObject;//流入的dp是POSTTU页面的数据点
			Subject sb = afp.ActionDataPoint.Record.Subject;//找到受试者

			DataPage dpgFU = afp.ActionDataPoint.Record.DataPage; //找到POSTTU页面，用于判断active和向页面中添加记录

			Records rdsBL = sb.Instances.FindByFolderOID("SCREEN").DataPages.FindByFormOID("TUTLS").Records;//找到筛选期的所有TU记录

			DataPoint dpYN = afp.ActionDataPoint.Record.DataPoints.FindByFieldOID("TLBYN"); //用于POSTTU添加记录时的判断条件

			if (dpgFU.Active == false || (dpYN.Data != "1" && dpYN.ChangeCount < 2))
				return null;

			while (rdsBL.Count > dpgFU.Records.Count)
				dpgFU.AddLogRecord();//添加记录

			//添加记录中的每个变量的值
			for (int i = 1; i < rdsBL.Count; i++)
			{
				if (rdsBL.FindByRecordPosition(i).Active == false)
				{
					dpgFU.Records.FindByRecordPosition(i).Active = false;
				}
				else
				{
					dpgFU.Records.FindByRecordPosition(i).Active = true;

					DataPoint dpTLBLSC = rdsBL.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBNUM");
					DataPoint dpTLFUSC = dpgFU.Records.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBNUM");

					dpTLFUSC.UnFreeze();
					if (dpYN.Data == "1")
						dpTLFUSC.Enter(dpTLBLSC.Data, null, 0);
					else
						dpTLFUSC.Enter("", null, 0);
					dpTLFUSC.Freeze();



					DataPoint dpTLBLS = rdsBL.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBSC");
					DataPoint dpTLFUS = dpgFU.Records.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBSC");

					dpTLFUS.UnFreeze();
					if (dpYN.Data == "1")
						dpTLFUS.Enter(dpTLBLS.Data, null, 0);
					else
						dpTLFUS.Enter("", null, 0);
					dpTLFUS.Freeze();


					DataPoint dpTLBNUM = rdsBL.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBLOC");
					DataPoint dpTLFNUM = dpgFU.Records.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBLOC");

					dpTLFNUM.UnFreeze();
					if (dpYN.Data == "1")
						dpTLFNUM.Enter(dpTLBNUM.Data, null, 0);
					else
						dpTLFNUM.Enter("", null, 0);
					dpTLFNUM.Freeze();

					DataPoint dpTLBNU = rdsBL.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBPOS");
					DataPoint dpTLFNU = dpgFU.Records.FindByRecordPosition(i).DataPoints.FindByFieldOID("TLBPOS");

					dpTLFNU.UnFreeze();
					if (dpYN.Data == "1")
						dpTLFNU.Enter(dpTLBNU.Data, null, 0);
					else
						dpTLFNU.Enter("", null, 0);
					dpTLFNU.Freeze();


				}
			}
			return null;
```
## 6. Calculate sum of dp in logline form (TLBPPD in log, TLBSUM not in log)
```C#
			///1.SCR_TLBPPD is present, then TLBPPD ->CF_SUM
			///2.SCR_TLBPPD is present or TLBSUM is not ampty, then TLBSUM -> CF_SUM
			///
			ActionFunctionParams afp = (ActionFunctionParams) ThisObject;
			DataPoint dpTL = afp.ActionDataPoint;

			Subject subj = dpTL.Record.Subject;
			string insOID = dpTL.Record.DataPage.Instance.Folder.OID;//找当前的Ins
			//SUM在整个肿评page中不在logline里，仅有一个数据点
			DataPoint dpSUM = dpTL.Record.DataPage.MasterRecord.DataPoints.FindByFieldOID("TLBSUM");
			//找当前的datapage:TUTR
			DataPage dpgTL = dpTL.Record.DataPage;

			double i_DP = 0;

			for (int i = 0; i < dpgTL.Records.Count; i++)//SCR的肿评是logline，所以会有n个records
			{
				Record recTL = dpgTL.Records.FindByRecordPosition(i);//找到每个record
				DataPoint dose_temp = recTL.DataPoints.FindByFieldOID("TLBPPD");//找出每个record中的TLBPPD
				//*:匹配前面的子表达式任意次,+:匹配前面的子表达式一次或多次(大于等于1次）
				//?:当该字符紧跟在任何一个其他限制符（*,+,?，{n}，{n,}，{n,m}）后面时，匹配模式是非贪婪的。
				//非贪婪模式尽可能少地匹配所搜索的字符串，而默认的贪婪模式则尽可能多地匹配所搜索的字符串。
				//例如，对于字符串“oooo”，“o+”将尽可能多地匹配“o”，得到结果[“oooo”]，而“o+?”将尽可能少地匹配“o”，得到结果 ['o', 'o', 'o', 'o']
				//Regex: Regular Expression，^:行首，$：行尾，[+-]：正负号，[.]：小数点，\d：匹配一个数字字符，*：匹配\d任意次，?：尽可能少地匹配所搜索的字符串
				//@：表示其后的字符串是个逐字字符串verbatim string，@只能对字符串常量作用，@会取消字符串中的转义符。类似于SAS中的%Qsysfunc,不加@的话\n翻译为换行。加@\n翻译为\和n
				if (dose_temp.Active && !CustomFunction.DataPointIsEmpty(dose_temp) && Regex.IsMatch(dose_temp.Data, @"^[+-]?\d*[.]?\d*$"))
				{
					i_DP = i_DP + double.Parse(dose_temp.Data.ToString());//求和，double.parse指将dp的值存为string后转为double数字
				}
			}

			string totals = i_DP.ToString();//将和转为string格式

			dpSUM.Enter(totals, null, 0);//数值，单位，changecode

			return null;
```
## 7. AETERM Overlap Check
```c#
			///////////////////////////////////////
			///From Weiping
			///AETERM OVERLAP CHECK:

			//Define a query text 

			string QUERY_TEXT = "The same AE term is reported more than once. Please check if any overlap on AE duration.";

			//Get the target fields OID

			const string fieldOID = "AETERM";
			const string fieldOID_STDAT = "AESTDAT";
			const string fieldOID_ENDAT = "AEENDAT";

			//optional fields OID

			const string fieldOID_STTIM = "AESTTIM";
			const string fieldOID_ENTIM = "AEENTIM";

			//Get the data point from edit Check

			ActionFunctionParams afp = (ActionFunctionParams)ThisObject;
			DataPoint input_dp = afp.ActionDataPoint;

			//Get all records of the current data page

			Records allRecords = input_dp.Record.DataPage.Records;

			//Sort all the records according to the record position

			allRecords = GetSortedRecords(allRecords);


			bool openQuery = false;

			DataPoint i_dp = null;

			DataPoint j_dp = null;

			DateTime i_dp_STDTC, i_dp_ENDTC, j_dp_ENDTC, j_dp_STDTC;

			//Loops all the records in current data page

			for (int i = allRecords.Count - 1; i > 1; i--)

			{

				if (allRecords[i].Active)

				{

					//Get the current date and time fields

					i_dp = allRecords[i].DataPoints.FindByFieldOID(fieldOID);

					//Get the current record AE start date and time

					i_dp_STDTC = getDateTime(allRecords[i].DataPoints.FindByFieldOID(fieldOID_STDAT), allRecords[i].DataPoints.FindByFieldOID(fieldOID_STTIM));

					//Get the current record AE End date and time

					i_dp_ENDTC = getDateTime(allRecords[i].DataPoints.FindByFieldOID(fieldOID_ENDAT), allRecords[i].DataPoints.FindByFieldOID(fieldOID_ENTIM));


					openQuery = false;

					if (i_dp_STDTC != DateTime.MaxValue)

					{

						//Loops agian for all the records in current data page

						for (int j = i - 1; j > 0; j--)

						{

							if (allRecords[j].Active)

							{
								//Get the previous date and time fields

								j_dp = allRecords[j].DataPoints.FindByFieldOID(fieldOID);

								//Get the previous record AE start date and time

								j_dp_STDTC = getDateTime(allRecords[j].DataPoints.FindByFieldOID(fieldOID_STDAT), allRecords[j].DataPoints.FindByFieldOID(fieldOID_STTIM));

								//Get the previous record AE End date and time

								j_dp_ENDTC = getDateTime(allRecords[j].DataPoints.FindByFieldOID(fieldOID_ENDAT), allRecords[j].DataPoints.FindByFieldOID(fieldOID_ENTIM));

								//Compare the current record datetime and the previous record datetime

								if (string.Compare(i_dp.Data, j_dp.Data, true) == 0 && i_dp_STDTC != DateTime.MaxValue && j_dp_STDTC != DateTime.MaxValue && i_dp_STDTC <= j_dp_ENDTC && i_dp_ENDTC >= j_dp_STDTC)

								{

									openQuery = true;

									break;

								}

							}

						}

					}

					//Open query use the PerformQueryAction Method

					CustomFunction.PerformQueryAction(QUERY_TEXT, 1, false, false, i_dp, openQuery, afp.CheckID, afp.CheckHash);

				}

			}

			return null;

		}

		//The below function is use to sort the records 

		Records GetSortedRecords(Records unSortedRecords)

		{

			//Use the record position to sort the collected records

			Record[] tmpRecords = new Record[unSortedRecords.Count];

			for (int i = 0; i < unSortedRecords.Count; i++)

			{

				Record record = unSortedRecords[i];

				tmpRecords[record.RecordPosition] = record;

			}



			//return a sorted records

			Records sortedRecords = new Records();

			for (int i = 0; i < tmpRecords.Length; i++)

			{

				sortedRecords.Add(tmpRecords[i]);

			}

			return sortedRecords;

		}

		//The below function is use to combine the AE date and time

		DateTime getDateTime(DataPoint DAT, DataPoint TIM)

		{

			//Combine the date and time

			DateTime tmp_DTC = DateTime.MaxValue;

			if (DAT != null && DAT.StandardValue() is DateTime)

			{

				if (TIM != null && TIM.Data != string.Empty && TIM.StandardValue() is TimeSpan)

				{

					tmp_DTC = Convert.ToDateTime(DAT.StandardValue()).Add((TimeSpan)(TIM.StandardValue()));

				}

				else

				{

					tmp_DTC = DateTime.Parse(DAT.StandardValue().ToString());

				}

			}

			return tmp_DTC;
```
## 8. Check TU Method of the same lesion in different folders
```c#
			////////////////////////////////////////////////////////
			////Check同一病灶不同周期的检查方法是否一致
            
			//Get the target fields OID

			const string TUMETH = "TUMETH";
			const string TUTL = "TUNT";
			bool IsOpenQuery = false;

			//Define query text variable

			string queryText = "";

			//Get data point from edit check

			ActionFunctionParams afp = (ActionFunctionParams)ThisObject;

			DataPoint dpACT = afp.ActionDataPoint;

			//Get the current subject and TUMETH data points

			Subject subj = dpACT.Record.Subject;

			DataPoints dpsTUMETH = CustomFunction.FetchAllDataPointsForOIDPath(TUMETH, TUTL, null, subj);

			if (dpsTUMETH != null)

			{

				//Loops the TUMETH data points

				for (int i = 0; i < dpsTUMETH.Count; i++)

				{

					//Get the first record and the data point in this record

					IsOpenQuery = false;

					Record iRec = dpsTUMETH[i].Record;

					DataPoint iTUMETH = dpsTUMETH[i];

					DataPoint iTUWKS = iTUMETH.Record.DataPoints.FindByFieldOID("TUWKS");

					DataPoint iTUWKSO = iTUMETH.Record.DataPoints.FindByFieldOID("TUWKSO");

					DataPoint iTUMETHO = iTUMETH.Record.DataPoints.FindByFieldOID("TUMETHO");

					if (!iRec.Active || CustomFunction.DataPointIsEmpty(iTUMETH)) continue;

					for (int j = 0; j < dpsTUMETH.Count; j++)

					{

						//Get another record and the data point in this record

						Record jRec = dpsTUMETH[j].Record;

						DataPoint jTUMETH = dpsTUMETH[j];

						DataPoint jTUWKS = jTUMETH.Record.DataPoints.FindByFieldOID("TUWKS");

						DataPoint jTUWKSO = jTUMETH.Record.DataPoints.FindByFieldOID("TUWKSO");

						DataPoint jTUMETHO = jTUMETH.Record.DataPoints.FindByFieldOID("TUMETHO");

						if (!jRec.Active || CustomFunction.DataPointIsEmpty(jTUMETH)) continue;

						//open query once the record position is not equal and the data is not equal

						if (((iTUMETH.Data != jTUMETH.Data) || (iTUMETHO.Data != String.Empty && jTUMETHO.Data != string.Empty && iTUMETHO.Data != jTUMETHO.Data)) && ((iTUWKS.Data != jTUWKS.Data) || (iTUWKSO.Data != String.Empty && jTUWKSO.Data != string.Empty && iTUWKSO.Data != jTUWKSO.Data)) && iTUMETH.Record.DataPage.PageRepeatNumber == jTUMETH.Record.DataPage.PageRepeatNumber)

						{

							IsOpenQuery = true;

						}



					}

					//Use the translation workbench to get a chinese query text ID

					queryText = Localization.GetLocalDataString(6081, "eng");

					//Open query use the PerformQueryAction Method

					CustomFunction.PerformQueryAction(queryText, 1, false, false, iTUMETH, IsOpenQuery, afp.CheckID, afp.CheckHash);

				}

			}

			return null;
```
# Yuanyuan Pei/Jun08,2022
## 9. Used in check steps, to exclude some folders
```C#
//Exclude_SCREEN_folder
DataPoint dp=(DataPoint) ThisObject;
        Instance ins=dp.Record.DataPage.Instance;
        if (ins != null)
        {
            if (ins.Folder.OID=="SCREEN")
            {
                return false;
            }
        }

        return true;
```
## 10. Used in check steps, to transfer string to value

```C#
 //Get data point from Check Step

        DataPoint dp = (DataPoint) ThisObject;

        double i = 0;

        if (dp.Data != null && Double.TryParse(dp.Data.ToString(), out i))

        {
            if (i < 10)

            {
                return true;
            }
        }
        return false;
```
## 11.Dynamic trigger cycle(addMatrix,2021-453-00CH1_V2.0)
```C#
 ActionFunctionParams afp = (ActionFunctionParams) ThisObject;
        DataPoint actionDataPoint = afp.ActionDataPoint;
        Instance instance = actionDataPoint.Record.DataPage.Instance;
        Subject subject = actionDataPoint.Record.Subject;

        int crfVersionId = subject.CrfVersionId;
        string currFolderOid = instance.Folder.OID;
        int instanceRepeatNumber = instance.InstanceRepeatNumber;

        Matrix matrixCND1_1 = Matrix.FetchByOID("CND1_1", crfVersionId);
        Matrix matrixCND1_2 = Matrix.FetchByOID("CND1_2", crfVersionId);
        Matrix matrixCND8 = Matrix.FetchByOID("CND8", crfVersionId);
        Matrix matrixC2D8 = Matrix.FetchByOID ("C2D8", crfVersionId);
        //Judge the current FolderOID whether it belong to default matrixs and return the next matrix.
        string[] strTrigFolderOids =
        {
            "SCR2", "C1D1", "C1D8", "C1D15"
        }
        ;
        string[] strMatrixOids =
        {
            "C1D1", "C1D8", "C1D15", "C2D1"
        }
        ;
        System.Collections.Generic.List<string> listStrTrigFolderOids = new System.Collections.Generic.List<string>(strTrigFolderOids);
        int index = listStrTrigFolderOids.IndexOf(currFolderOid);
        // (x>y) ? a : b ;--if x > y ==true then a, else b;
        string strToBeMergedMatrixOid = (index >= 0 && index <= 4) ? strMatrixOids[index] : string.Empty;

        //To ensure that every cases only contain one bool with true value.
        DataPoint Group1 = subject.GetAllDataPoints().FindByFieldOID("DSSRG1");
        DataPoint Group2 = subject.GetAllDataPoints().FindByFieldOID("DSSRG2");
        bool isNextCycleCND1_1 = false, isNextCycleCND1_2 = false, isNextCycleCND8 = false, isNextCycleC2D8 = false;

        bool NeedCND8 = ((Group1.Active && (Group1.Data == "2" || Group1.Data == "4")) || (Group2.Active && Group2.Data == "1"));

        if (NeedCND8 && instanceRepeatNumber < 11)
        {

            isNextCycleC2D8 = (string.Compare(currFolderOid, "C2D1", true) == 0);
            isNextCycleCND1_1 = (string.Compare(currFolderOid, "C2D8", true) == 0 || (string.Compare(currFolderOid, "CND1", true) == 0 && instanceRepeatNumber % 4 == 3));
            isNextCycleCND1_2 = (string.Compare(currFolderOid, "CND1", true) == 0 && instanceRepeatNumber % 4 == 1);
            isNextCycleCND8 = (string.Compare(currFolderOid, "CND1", true) == 0 && instanceRepeatNumber % 2 == 0);
        }
        else if (NeedCND8 && instanceRepeatNumber >= 11)
        {

            isNextCycleCND1_1 = (string.Compare(currFolderOid, "CND1", true) == 0 && instanceRepeatNumber % 2 != 0);
            isNextCycleCND1_2 = (string.Compare(currFolderOid, "CND1", true) == 0 && instanceRepeatNumber % 2 == 0);
            isNextCycleCND8 = false;
            isNextCycleC2D8 = false;
        }
        else if (!NeedCND8)
        {
            isNextCycleCND1_1 = ( string.Compare(currFolderOid, "C2D1", true) == 0 || (string.Compare(currFolderOid, "CND1", true) == 0 && instanceRepeatNumber % 2 != 0));
            isNextCycleCND1_2 = (string.Compare(currFolderOid, "CND1", true) == 0 && instanceRepeatNumber % 2 == 0);
            isNextCycleCND8 = false;
            isNextCycleC2D8 = false;
        }


        //Add matrix, active or inactive the next matrix according to each bools.
        DataPoint dpYN = actionDataPoint;
        Instance nextIns = GetNextInstance(instance, NeedCND8);
        if (strToBeMergedMatrixOid != string.Empty)
        {
            if (IsYes(dpYN) && nextIns == null)
            {
                Matrix toBeMergedMatrix = Matrix.FetchByOID(strToBeMergedMatrixOid, crfVersionId);
                subject.AddMatrix(toBeMergedMatrix);
            }
            else if (IsYes(dpYN) && nextIns != null)
            {
                nextIns.Active = true;
            }
            else if (!IsYes(dpYN) && nextIns != null)
            {
                nextIns.Active = false;
            }
        }
        if (isNextCycleC2D8 && IsYes(dpYN))
        {
            if (nextIns == null)
            subject.AddMatrix(matrixC2D8);
            else if (nextIns != null)
            nextIns.Active = true;
        }
        else if (isNextCycleC2D8 && !IsYes(dpYN) && nextIns != null)
        {
            nextIns.Active = false;
        }
        if (isNextCycleCND1_1 && IsYes(dpYN))
        {
            if (nextIns == null)
            subject.AddMatrix(matrixCND1_1);
            else if (nextIns != null)
            nextIns.Active = true;
        }
        else if (isNextCycleCND1_1 && !IsYes(dpYN) && nextIns != null)
        {
            nextIns.Active = false;
        }
        if (isNextCycleCND1_2 && IsYes(dpYN))
        {
            if (nextIns == null)
            subject.AddMatrix(matrixCND1_2);
            else if (nextIns != null)
            nextIns.Active = true;
        }
        else if (isNextCycleCND1_2 && !IsYes(dpYN) && nextIns != null)
        {
            nextIns.Active = false;
        }
        if (isNextCycleCND8 && IsYes(dpYN))
        {
            if (nextIns == null)
            subject.AddMatrix(matrixCND8);
            else if (nextIns != null)
            nextIns.Active = true;
        }
        else if (isNextCycleCND8 && !IsYes(dpYN) && nextIns != null)
        {
            nextIns.Active = false;
        }
        Instances Ins = subject.Instances;
        ResetInstanceName(Ins);
        return null;
		//Fuctions 1-5.
        //1.Input an instance then return the next instance according to the visit or InstanceRepeatNumber.

        Instance GetNextInstance(Instance curInstance, bool CohortY)
        {
            Instances ins = curInstance.Subject.Instances;
            Instances insCND1 = curInstance.Subject.GetInstancesByFolderOid("CND1", true);
            if (curInstance.Folder.OID == "SCR2")
            {
                return ins.FindByFolderOID("C1D1");
            }
            else if (curInstance.Folder.OID == "C1D1")
            {
                return ins.FindByFolderOID("C1D8");
            }
            else if (curInstance.Folder.OID == "C1D8")
            {
                return ins.FindByFolderOID("C1D15");
            }
            else if (curInstance.Folder.OID == "C1D15")
            {
                return ins.FindByFolderOID("C2D1");
            }
            else if (curInstance.Folder.OID == "C2D1")
            {
                if (CohortY)
                {
                    return ins.FindByFolderOID("C2D8");
                }
                else
                {
                    return GetInstancePerRepeatNumber(insCND1, 0);
                }
            }
            else if (curInstance.Folder.OID == "C2D8")
            {
                return GetInstancePerRepeatNumber(insCND1, 0);
            }
            else
            {
                return GetInstancePerRepeatNumber(insCND1, curInstance.InstanceRepeatNumber + 1);
            }
        }

		//2.Input some instances with the same FolderOID and InstanceRepeatNumber then return the certain instance.
        Instance GetInstancePerRepeatNumber(Instances instances, int insRepeatNumber)
        {
            for (int i = 0; i < instances.Count; i++)
            {
                if (instances[i].InstanceRepeatNumber == insRepeatNumber)
                {
                    return instances[i];
                }
            }
            return null;
        }

		//3.Input some instances then reset their names.
        void ResetInstanceName(Instances instances)
        {
            for (int i = 0; i < instances.Count; i++)
            {
                double Quo = instances[i].InstanceRepeatNumber / 2;
                if (instances[i].Folder.OID == "CND1")
                {
                    if (NeedCND8 && instances[i].InstanceRepeatNumber <= 12)
                    {
                        if (instances[i].InstanceRepeatNumber % 2 == 0)
                        instances[i].SetInstanceName(((Math.Truncate(Quo) + 3).ToString() + "D1").Trim());
                        else
                        instances[i].SetInstanceName(((Math.Truncate(Quo) + 3).ToString() + "D8").Trim());
                    }
                    else if (NeedCND8 && instances[i].InstanceRepeatNumber > 12)
                    {
                        instances[i].SetInstanceName(((instances[i].InstanceRepeatNumber - 3).ToString() + "D1").Trim());
                    }
                    else
                    instances[i].SetInstanceName(((instances[i].InstanceRepeatNumber + 3).ToString() + "D1").Trim());
                }
                else if (instances[i].Folder.OID != "UNSCH")
                {
                    instances[i].SetInstanceName("");
                }
            }
        }

		//4.Return true when the data of datapoint is "1".
        bool IsYes(DataPoint dp)
        {
            bool flag = (dp != null && dp.Active && dp.Data != string.Empty && dp.EntryStatus != EntryStatusEnum.NonConformant && dp.Data == "1");
            return flag;
        }

		//5.Input certain instance, FormOID and FieldOID then return the certain datapoint.
        DataPoint GetDataPoint(Instance inst, string fmOid, string flOid)
        {
            DataPoint dp = null;
            if (inst == null)
            return dp;
            DataPage page = inst.DataPages.FindByFormOID(fmOid);
            if (page == null)
            return dp;
            return page.MasterRecord.DataPoints.FindByFieldOID(flOid);
        }

```
## 12.lab_outRange_CS_comments
```C#
 /* Calling Check/s: Significance
        * Description:
        * MODIFICATION HISTORY
        * Person Date Comments
        * --------- ------ ---------
        * JW02 20211124
        */
        ActionFunctionParams afp = (ActionFunctionParams) ThisObject;
        DataPoint input_DP = afp.ActionDataPoint;
        Subject subj = input_DP.Record.Subject;
        DataPoints dps = input_DP.Record.DataPage.GetAllDataPoints();
        string queryText = Localization.GetLocalDataString(20507);
        string queryText2 = Localization.GetLocalDataString(20508);

        bool fire = false;
        bool open = false;
        foreach (DataPoint dp in dps)
        {
            fire = false;
            open = false;
            if (dp.Active && dp.Field.IsClinicalSignificance && dp.Record.RecordPosition == 0)
            {
                DataPoint.Significance dpclinc = dp.ClinicalSignificance;
                if (dpclinc != null && dpclinc.Code == null)
                {
                    fire = true;
                }
                if (dpclinc != null && dpclinc.Code != null && dpclinc.Code.Code.ToString() == "CS" && dpclinc.Comment == string.Empty)
                {
                    open = true;
                }
            }
            CustomFunction.PerformQueryAction(queryText, 1, false, false, dp, fire, afp.CheckID, afp.CheckHash);
            CustomFunction.PerformQueryAction(queryText2, 1, false, false, dp, open, afp.CheckID, afp.CheckHash);
        }
        return null;
```
## SAS Prog for Output Patient Profile.RTF(3.1 Output Per Subject)
```SAS
ods _all_ close; 

ods rtf file="&root.\&_mode.\Output\RTF\&_Date.\2020-689-00CH3_PatientProfile_&subj..rtf"  style=styles.custom; /**/

*设置导出RTF文件的参数;
ods escapechar = "~"; *指定（标记行内格式符号的）特殊字符;
ods listing close;
options papersize=A4 orientation=landscape nobyline nodate nonumber;
ods startpage=no;*不同的proc report结果之间去掉分页符;
ods rtf TITLE="PatientProfile" ANCHOR="PatientProfile"  NOTOC_DATA;

*设置RTF页眉：subjectno, ICF date, EOT date, tumor type;;
title1 h=9pt j=l  "Patient Profile";
title2 h=9pt j=l  "Study: 2020-689-00CH3  Subject Number: #byval(subject)  Tumor type: #byval(latype)"; *指调用下方define的某个变量，需要在 proc report的by后面加上这个变量;

*设置RTF页脚:raw data 下载日期，当前页数/总页数（总页数output per subj时不需要，output all subj时需要）;
footnote2 h=9pt j=l"Raw data extracted on &_Date." ;*j=r "Page #byval1 of &lastpage.";*&_Date.为raw data下载日期，在程序最开始人工输入;

*导出数据集tmp1:Lymphatic Physical Examination(LPE);
proc report data=tmp1 nowd headline style(column)={asis=on just=left background=white} STYLE(Header)={background=white } split='|'  spacing = 2 ls=134 ps=54 nowindows;
by subject latype;
where subject="&subj.";
column  ("~{style[bordertopcolor=white borderrightcolor=white borderleftcolor=white just=center]Lymphatic Physical Examination}" 
		subject latype instancename lpedat_raw lpeayn lpeas lpeassp); 

define subject/"Subject number"  noprint flow ;
define latype/"Tumor type" noprint  flow ;
define instancename/"Visit"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpedat_raw/"Exam Date"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeayn/"Abnormal lymph nodes assessed?"   style(column)=[cellwidth=15% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeas/"Anatomical site"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;
define lpeassp/"Other, specify"   style(column)=[cellwidth=20% just=center FONT_SIZE=10pt] style(header)=[just=center FONT_SIZE=10pt]  flow ;


```