#!/usr/bin/perl
$ofile="simresult.txt";
$nNodes=10;
$inEnergy=100;
open OUT, ">$ofile" or die "$0 cannot open output file $ofile: $!";
print "Please Stand By. Analyzing File: *.tr in "; print `pwd`; print "\n";

open OUT, ">$ofile" or die "$0 cannot open output file $ofile: $!";
print OUT "=================== Simulation Result ============================\n";
print OUT " Date:"; print OUT `date`;
print OUT "\n Analyzed File: *.tr in "; print OUT `pwd`;
print OUT "\n==================================================================\n";

while(<>){
	@mline = split(':', $_);
	@mline2 = split('\[', $mline[0]);
	@word = split('\]',$mline2[2]);
	@eng = split(" ",$word[0]);
	@tline = split('_', $_);
	$src=$tline[1];
	$Emin[$src] = $eng[1];
}

for ($i=0;$i < $nNodes; $i++) {
#	print "Node($i) : $Emin[$i]\n";
#	print OUT "Node($i) : $Emin[$i]\n";
 	$total = $total + $Emin[$i];
}

$consume=($total/($nNodes*$inEnergy))*100;
$average=$total/$nNodes;

for ($i=0;$i<$nNodes;$i++) {
	$sub = $average - $Emin[$i];
	if($sub < 0) {
		$sub = $sub * -1;
	}
	$sub_total = $sub_total + $sub;
}
$pyuncha=$sub_total/$nNodes;

#Primary Information 
print OUT " Total Remained Energy    : $total\n";
print OUT " Average Remained Energy  : $average\n";
print OUT " Energy Difference        : $pyuncha\n";
close OUT;
