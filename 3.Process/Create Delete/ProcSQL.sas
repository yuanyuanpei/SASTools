*Create new table,insert at the last line ;
proc sql;
create table xx (var1 char(3) label="label1",
				var2 num format=date9.,
				var3 num informat=best8.)
				; *num不可用length=..;
insert into xx
				set var1="asd",
				    var2=22345,
					var3=12
				set var1="qwe",
				    var2=23447,
					var3=34.3
				;
insert into xx (var1,var2,var3)
				values("1st",22346,33),
				values("2nd",.,89)
				;*空值为.或"";
insert into xx (var1,var2,var3)
				select x,y,z from sashelp.table
				;
quit;
proc sql;
create table countx as
select distinct var1,count(var2) as cnt
from xxx
where var3="AA" and var4 =2
group by var1;
quit;

*e.g.add sum line at the last line of the table;

proc sql noprint;
create table sdv as
select a,b,c,d 
from demp;

insert into sdv (a,b,c,d)
select 'Total' as a, 
		sum(b) as b,
		sum(input(c,best.)) as c,
		calculated c / calculated b as d format=percent7.1
from demp;
quit;

*Create table from a left join b;
proc sql;
create table ax as
select xx.a,xx.b,xx.c,input(substr(xx.d,1,10),yymmdd10.)-input(substr(yy.d,1,10),yymmdd10.) as delta
from xx left join yy
on xx.a=yy.p and xx.b=yy.m;
quit;

*create table from a except/intersect/union/outer union b;
proc sql;
create table exc as
select x from a
union/outer union/except/intersect ALL/CORR
select x from b; *CORR删除重复的行;
quit;

*drop table;
proc sql;
drop table ae,mh,sv,ds;
quit;
