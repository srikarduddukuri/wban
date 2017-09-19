#!/usr/bin/perl
$ofile="simresult.txt";
open OUT, ">>$ofile" or die "$0 cannot open output file $ofile: $!";
print "====== Analyzing Data ======= \n";

$granularity=$ARGV[0];
$tracefile=$ARGV[1];
open (DR,STDIN);
$gclock=0;
$rrepdrop=0;
$srrep=0;
if ($granularity==0) {$granularity=30;}

while(<>){
	chomp;
	if(/AGT/) {
		if(/^s/){
			@mline = split(':', $_);
			@mline2 = split('\[', $mline[0]);
			$s1=$mline2[2];
			@mline3 = split(' ', $mline[1]);
			$d1=$mline3[1];
			
			@tline = split('_', $_);
			$src=$tline[1];

			@line = split(' ',$_);
			$dstscnt[$src] += $line[7];
			$sbytes += $line[7];

			if ($snodecheck[$src] == 0 ) {
				$snodecheck[$src] = 1;
				$dstid[$src] = $d1;
			} 
			if ($snodecheck[$src] == 1 ) {
				$dststarttime[$src] = $line[1];
				if ( $dstid[$src] != $d1 ) {
					if      (!$dstid2[$src]) {
						$dstid2[$src]=$d1;
					} elsif ($dstid2[$src] == $d1) {
						$dstid2[$src]=$d1;
					} elsif (!$dstid3[$src]) {
						$dstid3[$src]=$d1;
					} elsif ($dstid3[$src] == $d1) {
						$dstid3[$src]=$d1;
					} elsif (!$dstid4[$src]) {
						$dstid4[$src]=$d1;
					} elsif ($dstid4[$src] == $d1) {
						$dstid4[$src]=$d1;
					} else {
						$xxy=$dstid2[$src];
					}

				}
			}
			if ($check[$line[5]] == 1 ) {
				$check[$line[5]] = 2;  # status ID for received packet
				$etoe[$line[5]] =  $etoe[$line[5]] - $line[1];
			} else {
				$check[$line[5]] = 3;  # status ID for lost packet
			}


			if ($line[6] eq 'cbr') {
				$type[$src]='cbr';
			} elsif ($line[6] eq 'tcp') {
				$type[$src]='tcp';
			}
				
			$scnt++;
		}

		if(/^r/){

			@tline = split('_', $_);
			$dst=$tline[1];

			@line = split(' ',$_);
			if($check[$line[5]] == 0 || $check[$line[5]] == 1){
			   	if ($check[$line[5]] == 1){
					$thcnt -= $hcnt[$line[5]];     
					$rcnt--;     
			    	}

				if ($rnodecheck[$dst] == 0 ) {
					$rnodecheck[$dst] = 1;
					$dstendtime[$dst] = $line[1];
				}

				$dstsum[$dst] += $line[7];
				$rbytes +=$line[7];

				$etoe[$line[5]] = $line[1];
				$check[$line[5]] = 1;
				$rtime[$line[5]] = $line[1];
				if ($first==0) {
					$gclock = $line[1];
					$endtime=$line[1];
					$first=1;
				}
				$hcnt[$line[5]] = 1;
				$thcnt++;     
				$rcnt++;

				if ($psize == 0) {$psize=$line[7];}
				if ($line[6] eq 'cbr') {
					$type[$dst]='cbr';
				} elsif ($line[6] eq 'tcp') {
					$type[$dst]='tcp';
				}
			} else {
				print OUT "Analysis Error: ";
				print OUT "$_\n";
			}
		}
	} elsif (/^f.*RTR/){
		@line = split(' ',$_);
		if($check[$line[5]] == 1){
			$hcnt[$line[5]] += 1;
			#$tmp=$hcnt[$line[5]]; print OUT "hcnt:  $tmp\n";
			#$tmp2=$line[5]; print OUT "mid:  $tmp2\n";
			$thcnt++;
		} elsif ($check[$line[5]] == 0){  #Lost messages
		} else {
			print OUT "Analysis Error: ";
			print OUT "$_\n";
		}


	} elsif (/^s.*DSR/){
		if (/^s.*REPLY/) {
			$srrep++;
			}
		$saodvcnt++;		
	} elsif (/^r.*DSR/){
		$raodvcnt++;		
	} elsif (/^D.*REPLY/) {
		$rrepdrop++
	}
	 
}

close DR;

#print OUT "End node: \n";
$m=$#dstscnt;
#print OUT "Max End node: $m\n";
for ($i=0;$i <= $#dstscnt; $i++) {
	#if ($nodecheck[$i] ==1) {
	#if ($dstsum[$i] > 0 ) {
	#if ($dstscnt[$i] > 0 || $dstsum[$i] >0) {
	if ($dstscnt[$i] > 0 ) {
		$dstnode=$dstid[$i];
		$srcnode=$i;
		$dstrcvd = $dstsum[$dstnode];
		$dstsent = $dstscnt[$srcnode];
		$et=$dstendtime[$dstnode];
		#print OUT "endtime for $dstnode is $et\n";
		$st=$dststarttime[$srcnode];
		if ($dstsent !=0 ){
			$dr= $dstrcvd/$dstsent*100;
		} else {
			$dr=0;
		}
		if ($et != 0) {
			$thr=$dstrcvd/$et;
		} else {
			$thr=0;
		}
		$ptype=$type[$srcnode];
		$j++;
#		print OUT "$j: $ptype: $srcnode => $dstnode : thr=$thr, dlv=$dr, sbytes=$dstsent, rbytes=$dstrcvd, st=$st, et=$et\n";

		if (!($dstid2[$srcnode] eq '')) {
			$j++;
			$dstnode2=$dstid2[$srcnode];
			$dstrcvd = $dstsum[$dstnode2];
			$et=$dstendtime[$dstnode2];
			if ($dstsent !=0 ){
				$dr= $dstrcvd/$dstsent*100;
			} else {
				$dr=0;
			}
#			print OUT "$j: $ptype: DUP: $srcnode => $dstnode2 : thr=$thr, dlv=$dr, sbytes=$dstsent, rbytes=$dstrcvd, st=$st, et=$et\n";
		}
		if (!($dstid3[$srcnode] eq '')) {
			$j++;
			$dstnode3=$dstid3[$srcnode];
			$dstrcvd = $dstsum[$dstnode3];
			$et=$dstendtime[$dstnode3];
			if ($dstsent !=0 ){
				$dr= $dstrcvd/$dstsent*100;
			} else {
				$dr=0;
			}
#			print OUT "$j: $ptype: DUP2: $srcnode => $dstnode3 : thr=$thr, dlv=$dr, sbytes=$dstsent, rbytes=$dstrcvd, st=$st, et=$et\n";
		}
		if (!($dstid4[$srcnode] eq '')) {
			$j++;
			$dstnode4=$dstid4[$srcnode];
			$dstrcvd = $dstsum[$dstnode4];
			$et=$dstendtime[$dstnode4];
			if ($dstsent !=0 ){
				$dr= $dstrcvd/$dstsent*100;
			} else {
				$dr=0;
			}
#			print OUT "$j: $ptype: DUP2: $srcnode => $dstnode4 : thr=$thr, dlv=$dr, sbytes=$dstsent, rbytes=$dstrcvd, st=$st, et=$et\n";
		}


		$tdr+=$dr;
		$tdstthr+=$thr;
		$tdstrcnt+=$dstsum[$i];
		$tdstscnt+=$dstscnt[$i];
	}

}

$number = @etoe;
$tdelay = 0;
$maxdid=0;        #packet id for max delay
$mindid=0;
$counter = 0;
$maxdelay = 0;
$mindelay = 300;

$maxhid=0;        #packet id for max hop counts
$minhid=0;
$maxhcnt = 0;
$minhcnt = 300;
$maxdelay0=0;$maxdid0=0;
$maxdelay1=0;$maxdid1=0;
$maxdelay2=0;$maxdid2=0;
$maxdelay3=0;$maxdid3=0;
$maxdelay4=0;$maxdid4=0;
$maxdelay5=0;$maxdid5=0;
$maxdelay6=0;$maxdid6=0;
$maxdelay7=0;$maxdid7=0;
$maxdelay8=0;$maxdid8=0;
$lohcnt  = 0;      # number of packets under minimum threshold of hop counts
$hihcnt0 = 0;      # number of packets over minimum threshold of hop counts
$delay0 = 0;	  #sum of delays of the packets in interval 0
$hcntlevel = 1;   # First minimum threshold of hop counts
$hihcnt  = 0;      # number of packets over minimum threshold of hop counts
$hcntlevel1 = 1;   # First minimum threshold of hop counts
$hihcnt1 = 0;      # number of packets over minimum threshold of hop counts
$delay1 = 0;	  #sum of delays of the packets in interval 1
$hcntlevel2 = 2;   # Second threshold of hop counts
$hihcnt2 = 0;      # number of packets over minimum threshold of hop counts
$delay2 = 0;	  #sum of delays of the packets in interval 2
$hcntlevel3 = 3;   # Third threshold of hop counts
$hihcnt3 = 0;      # number of packets over minimum threshold of hop counts
$delay3 = 0;	  #sum of delays of the packets in interval 3
$hcntlevel4 = 4;   # Fourth threshold of hop counts
$hihcnt4 = 0;      # number of packets over minimum threshold of hop counts
$delay4 = 0;	  #sum of delays of the packets in interval 4
$hcntlevel5 = 5;   # Fourth threshold of hop counts
$hihcnt5 = 0;      # number of packets over minimum threshold of hop counts
$delay5 = 0;	  #sum of delays of the packets in interval 5
$hcntlevel6 = 10;   # Fourth threshold of hop counts
$hihcnt6 = 0;      # number of packets over minimum threshold of hop counts
$delay6 = 0;	  #sum of delays of the packets in interval 6
$hcntlevel7 = 15;   # Fourth threshold of hop counts
$hihcnt7 = 0;      # number of packets over minimum threshold of hop counts
$delay7 = 0;	  #sum of delays of the packets in interval 7
$hcntlevel8 = 20;   # Fourth threshold of hop counts
$hihcnt8 = 0;      # number of packets over minimum threshold of hop counts
$delay8 = 0;	  #sum of delays of the packets in interval 8

for ($count = 0;$count < $number;$count++) {
	#if($check[$count] == 1 || $check[$count] == 2 ) {
	if( $check[$count] == 2 ) {
		$tdelay = $tdelay + $etoe[$count];
		if($maxdelay < $etoe[$count]) { $maxdelay = $etoe[$count]; $maxdid=$count;}
		if($mindelay > $etoe[$count]) { $mindelay = $etoe[$count]; $mindid=$count;}
		$counter++;
		$thcnt2 = $thcnt2 + $hcnt[$count];
		if($maxhcnt < $hcnt[$count]) { $maxhcnt = $hcnt[$count]; $maxhid=$count;}
		if($minhcnt > $hcnt[$count]) { $minhcnt = $hcnt[$count]; $minhid=$count}

		if($hcnt[$count] > $hcntlevel) { $hihcnt++;}
		if(     $hcnt[$count] <= $hcntlevel ) { 
			$lohcnt++;
			$hihcnt0++;
			$delay0 += $etoe[$count];
			if($maxdelay0 < $etoe[$count]) { $maxdelay0 = $etoe[$count]; $maxdid0=$count;}
			#print OUT STDOUT "$count \n";
		} elsif($hcnt[$count] > $hcntlevel1 && $hcnt[$count] <= $hcntlevel2 ) { 
			$hihcnt1++;
			$delay1 += $etoe[$count];
			if($maxdelay1 < $etoe[$count]) { $maxdelay1 = $etoe[$count]; $maxdid1=$count;}
		} elsif($hcnt[$count] > $hcntlevel2 && $hcnt[$count] <= $hcntlevel3 ) { 
			$hihcnt2++;
			$delay2 += $etoe[$count];
			if($maxdelay2 < $etoe[$count]) { $maxdelay2 = $etoe[$count]; $maxdid2=$count;}
		} elsif($hcnt[$count] > $hcntlevel3 && $hcnt[$count] <= $hcntlevel4 ) { 
			$hihcnt3++; 
			$delay3 += $etoe[$count];
			if($maxdelay3 < $etoe[$count]) { $maxdelay3 = $etoe[$count]; $maxdid3=$count;}
			#print OUT STDOUT "$count\n";
		} elsif($hcnt[$count] > $hcntlevel4 && $hcnt[$count] <= $hcntlevel5 ) { 
			$hihcnt4++; 
			$delay4 += $etoe[$count];
			if($maxdelay4 < $etoe[$count]) { $maxdelay4 = $etoe[$count]; $maxdid4=$count;}
		} elsif($hcnt[$count] > $hcntlevel5 && $hcnt[$count] <= $hcntlevel6 ) { 
			$hihcnt5++; 
			$delay5 += $etoe[$count];
			if($maxdelay5 < $etoe[$count]) { $maxdelay5 = $etoe[$count]; $maxdid5=$count;}
		} elsif($hcnt[$count] > $hcntlevel6 && $hcnt[$count] <= $hcntlevel7 ) { 
			$hihcnt6++; 
			$delay6 += $etoe[$count];
			if($maxdelay6 < $etoe[$count]) { $maxdelay6 = $etoe[$count]; $maxdid6=$count;}
		} elsif($hcnt[$count] > $hcntlevel7 && $hcnt[$count] <= $hcntlevel8 ) { 
			$hihcnt7++; 
			$delay7 += $etoe[$count];
			if($maxdelay7 < $etoe[$count]) { $maxdelay7 = $etoe[$count]; $maxdid7=$count;}
		} elsif($hcnt[$count] > $hcntlevel8 ) { 
			$hihcnt8++;
			$delay8 += $etoe[$count];
			if($maxdelay8 < $etoe[$count]) { $maxdelay8 = $etoe[$count]; $maxdid8=$count;}
		} else {
			print OUT "Error! for pkt ID : $count\n";
		}
	}
}

$atdelay = $tdelay / $counter;
$deliveryratio=$rcnt/$scnt*100;
$deliveryratio2=$rbytes/$sbytes*100;
#$cratio=$saodvcnt/$raodvcnt;
$throughput= $rcnt * $psize / $endtime;
$rroutingload= $raodvcnt / $rcnt*100;
$sroutingload= $saodvcnt / $rcnt*100;
$ahcnt=   $thcnt/$rcnt;
$rhihcnt=$hihcnt/$rcnt *100;
$rlohcnt=100-$rhihcnt;
$rhihcnt1=$hihcnt1/$rcnt *100;
$rhihcnt2=$hihcnt2/$rcnt *100;
$rhihcnt3=$hihcnt3/$rcnt *100;
$rhihcnt4=$hihcnt4/$rcnt *100;
$rhihcnt5=$hihcnt5/$rcnt *100;
$rhihcnt6=$hihcnt6/$rcnt *100;
$rhihcnt7=$hihcnt7/$rcnt *100;
$rhihcnt8=$hihcnt8/$rcnt *100;
if ($hihcnt0>0) {$adelay0 = $delay0/$hihcnt0;}
if ($hihcnt1>0) {$adelay1 = $delay1/$hihcnt1;}
if ($hihcnt2>0) {$adelay2 = $delay2/$hihcnt2;}
if ($hihcnt3>0) {$adelay3 = $delay3/$hihcnt3;}
if ($hihcnt4>0) {$adelay4 = $delay4/$hihcnt4;}
if ($hihcnt5>0) {$adelay5 = $delay5/$hihcnt5;}
if ($hihcnt6>0) {$adelay6 = $delay6/$hihcnt6;}
if ($hihcnt7>0) {$adelay7 = $delay7/$hihcnt7;}
if ($hihcnt8>0) {$adelay8 = $delay8/$hihcnt8;}


print OUT " Packet Delivery Ratio    : $deliveryratio\n";
print OUT " Average End2End Delay    : $atdelay\n";
print OUT " Average Number of Hops   : $ahcnt\n";
#print OUT " Control Packet Overhead  : $saodvcnt\n";
print OUT " Throughput               : $throughput\n";
print OUT " Data Packets Sent        : $scnt\n";
print OUT " Data Packets Received    : $rcnt\n";
print OUT " Simulation Endtime       : $endtime\n";
print OUT " Total Delivery Time      : $tdelay\n";
print OUT " Total Number of Hops     : $thcnt\n";
print OUT " Dropped Reply Messages   : $rrepdrop\n";
print OUT " Maximum Number of Hops   : $maxhcnt\n";
print OUT " Minimum Number of Hops   : $minhcnt\n";
print OUT "==================================================================\n";

close OUT;
