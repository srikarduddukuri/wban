#!/bin/sh
ns grid.tcl 
time cat out.tr |./energshort.pl ;
time tac out.tr |./datashort.pl ;
gedit simresult.txt
