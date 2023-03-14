
ods path show;
*define the save address of style template;
ods path Work.Templat(UPDATE) Sashelp.Tmplmst(READ); 

*Check source style definition;
proc template;
    source styles.RTF;
run;

*Modify RTFstyle template;
proc template;
	define style Styles.Custom;
	parent = Styles.RTF;
	replace Body from Document /
		bottommargin = 1in
		topmargin = 1in
		rightmargin = 1in
		leftmargin = 1in;
	replace Table from Output /
		frame = box /* outside borders: void, box, above/below, vsides/hsides, lhs/rhs */  
		/* if want to fix the bottom line, please use above and add a new line in footnote1 in loa_tfoot*/
		rules = all /* internal borders: none, all, cols, rows, groups */
		cellpadding = 0.5pt /* the space between table cell contents and the cell border */
		cellspacing = 0pt /* the space between table cells, allows background to show */
		borderwidth = 0.5pt /* the width of the borders and rules */;
		* Leave code below this line alone ;
   replace fonts /
        'TitleFont' = ("Times New Roman",13pt,Bold  ) /* Titles from TITLE statements */
        'TitleFont2' = ("Times New Roman",12pt,Bold  ) /* Procedure titles ("The _____ Procedure")*/
        'StrongFont' = ("Times Roman",10pt,Bold)
        'EmphasisFont' = ("Times Roman",10pt,Italic)
        'headingEmphasisFont' = ("Times Roman",11pt,Bold Italic)
        'headingFont' = ("Times Roman",11pt,Bold) /* Table column and row headings */
        'docFont' = ("Times Roman",11pt) /* Data in table cells */
        'footFont' = ("Times Roman",13pt) /* Footnotes from FOOTNOTE statements */
        'FixedEmphasisFont' = ("Courier",9pt,Italic)
        'FixedStrongFont' = ("Courier",9pt,Bold)
        'FixedHeadingFont' = ("Courier",9pt,Bold)
        'BatchFixedFont' = ("Courier",6.7pt)
        'FixedFont' = ("Courier",9pt); 
	style SystemFooter from SystemFooter /
		font = fonts("footFont");
	end;
run;

