*EDC建库时，AESTDAT和AEENDAT日期设为dd-/MMM-/yyyy-;

*数据集中，完整日期的正则表达式为'/\d+\/\w+\/(\d{4})/';
	*\d+:日的一位或两位数字，如9或09;
	*\w+:月份的三个字母，如JAN或Jan;
	*\/:日期中的/，前面加\用于解析/符号;
	*\d{4}:年的四位数字，如2019;

*数据集中，不完整日期的正则表达式为'/un\/\w+\/(\d{4})/i'或'/un\/unk\/(\d{4})/i'或'/un\/unk\/unkn/i';
	*uk:未知;
	*i:不分大小写;

*offline listing的spec中，不完整日期AESTDAT和AEENDAT的填补规则：;
data _null_;
*----------------------------------------*;
*ST的日缺失，用当前月的最早日补充;
if prxmatch("/un\/\w+\/(\d{4})/i",AESTDAT) then do;
	AESTDAT=put(intnx('month',input(substr(AESTDAT,length(AESTDAT-7),8),anydtdte.),0,'B'),date11.);
end;
*EN的日缺失，用当前mm的最晚日补充;
if prxmatch("/un\/\w+\/(\d{4})/i",AEENDAT) then do;
	AEENDAT=put(intnx('month',input(substr(AEENDAT,length(AEENDAT-7),8),anydtdte.),0,'E'),date11.);
end;
*----------------------------------------*;
*ST的月和日都缺失，用1月1号补充;
if prxmatch("/un\/unk\(d{4})/i",AESTDAT) then do;
    AESTDAT = prxchange("s/un\/unk/01\/JAN/i",1,AESTDAT);
end;

*EN的月和日都缺失，用12月31补充;
if prxmatch("/un\/unk\(d{4})/i",AEENDAT) then do;
    AEENDAT = prxchange("s/un\/unk/31\/DEC/i",1,AEENDAT);
end;
*----------------------------------------*;
*ST的年月日都未知，设为空;
if prxmatch("/un\/unk\/unkn/i",AESTDAT) then do;
    AESTDAT = "";
end;

*EN的年月日都未知，设为空;
if prxmatch("/un\/unk\/unkn/i",AEENDAT) then do;
    AEENDAT = "";
end;
run;

*用到的函数:;
data tmp;
b="UK/Jan/2022";
b0=substr(b,length(b)-7,8);*取年和月;
b1=input(b0,anydtdte.);*以01为日补齐日期，并转换为数字;
b2=intnx('month',b1,0,'E');*将b1补齐;*B为当月最早的日，E为当月最晚的日，M为中间那天的日，S为同一天。0指从b1开始之后的第0个月（即当月）;
put b0 b1 b2;
run;
