*Clear all temporary datasets, logs, lst;
dm 'out;clear;';
dm 'log;clear;';
dm 'lst;clear;';

proc datasets nolist memtype=data library=work kill;quit;