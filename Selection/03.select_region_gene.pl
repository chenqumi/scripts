#!/usr/bin/perl -w
#yuewei@1gene.com.cn 2016.6.22
#change by baozhigui1607@1gene.com.cn combined three plot
use strict;

die "\nusage: perl $0 <list.log.filter.piratio_fst> <winsize(bp)> <species> <gene.info> <outdir>\n
note:
use the absolute pathway
\n" unless (@ARGV == 5);

my ($list,$win,$species,$geneinfo,$outdir) = @ARGV;


#cat log.filter.piratio_fst.txt by chromosome	

my $num = 1;
open LIST, "$list" or die "$!";
open CAT,">$outdir/$species.all.log.filter.piratio_fst.txt" or die "$!";
print CAT "#num\tchr\tstart\tend\tlog(pi_pop1/pop2)\tfst\n";
while (<LIST>)
{
	chomp;
	open IN, "$_" or die "$!";
	while(<IN>)
	{
		chomp;
		next if /^#/;
		my @tmp = split /\t/,$_;
		my $part = join "\t",@tmp[1..$#tmp];
		print CAT "$num\t$part\n";
		$num++;
	}
	close IN;
}
close LIST;
close CAT;

my $allpiratio_fst = "$outdir/$species.all.log.filter.piratio_fst.txt";
#my ($piratio5,$piratio95,$fst95) = &region($allpiratio_fst);
my ($piratio5,$piratio95,$fst95) = &newregion($allpiratio_fst); ## changed region sub by shichunwei^Oct.28.
#print "$piratio5,$piratio95,$fst95\n";


#plot hist and density
open OUT, ">$outdir/$species.plot_hist_density.r" or die "$!";
print OUT "#!/usr/bin/Rscript\n";
print OUT "pdf(\"$outdir/$species\_hist_density.pdf\")\n";
print OUT "layout(matrix(1:4,2,2))\n";
print OUT "a=read.table(\"$allpiratio_fst\",header=T)\n";
print OUT "x<-a[,5]\n";
print OUT "hist(x,freq=F,breaks=1000,xlab=\"ln(pi_group1/pi_group2)\",ylab=\"Frequency(%)\",main=NULL)\n";
print OUT "plot(ecdf(x),xlab=\"ln(pi_group1/pi_group2)\",ylab=\"Cumulative density\",main=NULL)\n";
print OUT "x<-a[,6]\n";
print OUT "hist(x,freq=F,breaks=1000,xlab=\"Fst\",ylab=\"Frequency(%)\",main=NULL)\n";print OUT "plot(ecdf(x),xlab=\"Fst\",ylab=\"Cumulative density\",main=NULL)\n";
print OUT "dev.off()\n";
close OUT;
`chmod 755 $outdir/$species.plot_hist_density.r`;
`$outdir/$species.plot_hist_density.r`;

#select the region that matches the conditions

my $num1 = 1;
my $num2 = 1;
my $num3 = 1;
my (%group1,%group2);
open OUT1, ">$outdir/$species.group1.region" or die "$!";
print OUT1 "#num\tchr\twin_start\twin_end\tpiratio\tfst\n";
open OUT2, ">$outdir/$species.group2.region" or die "$!";
print OUT2 "#num\tchr\twin_start\twin_end\tpiratio\tfst\n";
open OUT3, ">$outdir/$species.other.region" or die "$!";
print OUT3 "#num\tchr\twin_start\twin_end\tpiratio\tfst\n";
open IN, "$allpiratio_fst" or die "$!";
while (<IN>)
{
	chomp;
	next if /^#/;
	my @tmp = split /\t/,$_;
	if ($tmp[5] >= $fst95 && $tmp[4] <= $piratio5)
	{
		my $part1 = join "\t",@tmp[1..$#tmp];
		print OUT1 "$num1\t$part1\n";
		$num1++;
		$group1{$tmp[1]}{$tmp[2]} = $tmp[3];
	}
	elsif ($tmp[5] >= $fst95 && $tmp[4] >= $piratio95)
	{
		my $part2 = join "\t",@tmp[1..$#tmp];
		print OUT2 "$num2\t$part2\n";
		$num2++;
		$group2{$tmp[1]}{$tmp[2]} = $tmp[3];
	}
	else
	{
		my $part3 = join "\t",@tmp[1..$#tmp];
		print OUT3 "$num3\t$part3\n";
		$num3++;
	}
}
close IN;
close OUT1;
close OUT2;
close OUT3;

#plot the selected region 
my $count_group1 = `less $outdir/$species.group1.region|wc -l`;
chomp $count_group1;
my $count_group2 = `less $outdir/$species.group2.region|wc -l`;
chomp $count_group2;

if ($count_group1 > 1 && $count_group2 > 1)
{
	open OUT, ">$outdir/$species.plot_piratio_fst.r" or die "$!";
	print OUT "#!/usr/bin/Rscript\n";
	print OUT "pdf(\"$outdir/$species\_piratio_fst.pdf\")\n";
	print OUT "a=read.table(\"$outdir/$species.other.region\",header=T)\n";
	print OUT "c=read.table(\"$outdir/$species.group1.region\",header=T)\n";
	print OUT "w=read.table(\"$outdir/$species.group2.region\",header=T)\n";
	print OUT "plot(a[,5],a[,6],type=\"p\",pch=\".\",xlab=\"ln(pi_group1/pi_group2)\",ylab=\"Fst\",col=\"grey\",main=NULL)\n";
	print OUT "abline(h=$fst95,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio5,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio95,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "points(c[,5],c[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"blue\")\n";
	print OUT "points(w[,5],w[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"green\")\n";
	print OUT "dev.off()";
	close OUT;
	`chmod 755 $outdir/$species.plot_piratio_fst.r`;
	`$outdir/$species.plot_piratio_fst.r`;
}
elsif ($count_group1 > 1 && $count_group2 == 1)
{
	open OUT, ">$outdir/$species.plot_piratio_fst.r" or die "$!";
	print OUT "#!/usr/bin/Rscript\n";
	print OUT "pdf(\"$outdir/$species\_piratio_fst.pdf\")\n";
	print OUT "a=read.table(\"$outdir/$species.other.region\",header=T)\n";
	print OUT "c=read.table(\"$outdir/$species.group1.region\",header=T)\n";
	#print OUT "w=read.table(\"$outdir/$species.group2.region\",header=T)\n";
	print OUT "plot(a[,5],a[,6],type=\"p\",pch=\".\",xlab=\"ln(pi_group1/pi_group2)\",ylab=\"Fst\",col=\"grey\",main=NULL)\n";
	print OUT "abline(h=$fst95,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio5,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio95,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "points(c[,5],c[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"blue\")\n";
	#print OUT "points(w[,5],w[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"green\")\n";
	print OUT "dev.off()";
	close OUT;
	`chmod 755 $outdir/$species.plot_piratio_fst.r`;
	`$outdir/$species.plot_piratio_fst.r`;
}
elsif ($count_group1 == 1 && $count_group2 > 1)
{
	open OUT, ">$outdir/$species.plot_piratio_fst.r" or die "$!";
	print OUT "#!/usr/bin/Rscript\n";
	print OUT "pdf(\"$outdir/$species\_piratio_fst.pdf\")\n";
	print OUT "a=read.table(\"$outdir/$species.other.region\",header=T)\n";
	#print OUT "c=read.table(\"$outdir/$species.group1.region\",header=T)\n";
	print OUT "w=read.table(\"$outdir/$species.group2.region\",header=T)\n";
	print OUT "plot(a[,5],a[,6],type=\"p\",pch=\".\",xlab=\"ln(pi_group1/pi_group2)\",ylab=\"Fst\",col=\"grey\",main=NULL)\n";
	print OUT "abline(h=$fst95,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio5,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio95,lty=2,lwd=1.5,col=\"black\")\n";
	#print OUT "points(c[,5],c[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"blue\")\n";
	print OUT "points(w[,5],w[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"green\")\n";
	print OUT "dev.off()";
	close OUT;
	`chmod 755 $outdir/$species.plot_piratio_fst.r`;
	`$outdir/$species.plot_piratio_fst.r`;
}
elsif ($count_group1 == 1 && $count_group2 == 1)
{
	open OUT, ">$outdir/$species.plot_piratio_fst.r" or die "$!";
	print OUT "#!/usr/bin/Rscript\n";
	print OUT "pdf(\"$outdir/$species\_piratio_fst.pdf\")\n";
	print OUT "a=read.table(\"$outdir/$species.other.region\",header=T)\n";
	#print OUT "c=read.table(\"$outdir/$species.group1.region\",header=T)\n";
	#print OUT "w=read.table(\"$outdir/$species.group2.region\",header=T)\n";
	print OUT "plot(a[,5],a[,6],type=\"p\",pch=\".\",xlab=\"ln(pi_group1/pi_group2)\",ylab=\"Fst\",col=\"grey\",main=NULL)\n";
	print OUT "abline(h=$fst95,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio5,lty=2,lwd=1.5,col=\"black\")\n";
	print OUT "abline(v=$piratio95,lty=2,lwd=1.5,col=\"black\")\n";
	#print OUT "points(c[,5],c[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"blue\")\n";
	#print OUT "points(w[,5],w[,6],type=\"p\",pch=\".\",xlab=\"\",ylab=\"\",col=\"green\")\n";
	print OUT "dev.off()";
	close OUT;
	`chmod 755 $outdir/$species.plot_piratio_fst.r`;
	`$outdir/$species.plot_piratio_fst.r`;
}

#merge the region that matches the conditions

open OUT1, ">$outdir/$species.group1.region.merge" or die "$!";
print OUT1 "#num\tchr\twin_start\twin_end\n";
$num1 = 1;
my %new1;
foreach my $k1 (sort keys %group1)
{
	my @k2 = sort {$a <=> $b} keys %{$group1{$k1}};
	my $start = $k2[0];
	my $end = $group1{$k1}{$k2[0]};
	if (@k2 == 1)
	{	
		print OUT1 "$num1\t$k1\t$start\t$end\n";$num1++;
		$new1{$k1}{$start} = $end;
	}
	else
	{
		for (my $i=0;$i<@k2;$i++)
		{
			if (($k2[$i + 1] - $k2[$i]) <= $win)
			{
				$start = &min($k2[$i],$start);
				$end = &max($group1{$k1}{$k2[$i +1]},$end);
				if ($i + 1 == $#k2)
				{
					$new1{$k1}{$start} = $end;
					print OUT1 "$num1\t$k1\t$start\t$end\n";
					$num1++;
					last;
				}
			}
			else
			{
				$new1{$k1}{$start} = $end;
				print OUT1 "$num1\t$k1\t$start\t$end\n";
				$start = $k2[$i +1];
				$end = $group1{$k1}{$k2[$i +1]};
				$num1++;
				if ($i +1 == $#k2)
				{
					$new1{$k1}{$start} = $end;
					print OUT1 "$num1\t$k1\t$start\t$end\n";
					$num1++;
					last;
				}
			}
		}
	}
}
close OUT1;

open OUT2, ">$outdir/$species.group2.region.merge" or die "$!";
print OUT2 "#num\tchr\twin_start\twin_end\n";
$num2 = 1;
my %new2;
foreach my $k1 (sort keys %group2)
{
	my @k2 = sort {$a <=> $b} keys %{$group2{$k1}};
	my $start = $k2[0];
	my $end = $group2{$k1}{$k2[0]};
	if (@k2 == 1)
	{	
		print OUT2 "$num2\t$k1\t$start\t$end\n";$num2++;
		$new2{$k1}{$start} = $end;
	}
	else
	{
		for (my $i=0;$i<@k2;$i++)
		{
			if (($k2[$i + 1] - $k2[$i]) <= $win)
			{
				$start = &min($k2[$i],$start);
				$end = &max($group2{$k1}{$k2[$i +1]},$end);
				if ($i + 1 == $#k2)
				{
					$new2{$k1}{$start} = $end;
					print OUT2 "$num2\t$k1\t$start\t$end\n";
					$num2++;
					last;
				}
			}
			else
			{
				$new2{$k1}{$start} = $end;
				print OUT2 "$num2\t$k1\t$start\t$end\n";
				$start = $k2[$i +1];
				$end = $group2{$k1}{$k2[$i +1]};
				$num2++;
				if ($i +1 == $#k2)
				{
					$new2{$k1}{$start} = $end;
					print OUT2 "$num2\t$k1\t$start\t$end\n";
					$num2++;
					last;
				}
			}
		}
	}
}
close OUT2;


#select the candidate gene
#format for geneinfo
#gene	protein	chr/scaffold	region	start	end
#LOC100808170	XP_003516908.1	CDS	28126	28205
#

open SE1, ">$outdir/$species.selective_gene1" or die "$!";
open SE2, ">$outdir/$species.selective_gene2" or die "$!";
open INFO, "$geneinfo" or die "$!";
while (<INFO>)
{
	chomp;
	if ($_ =~ /^#/)
	{
		print SE1 "$_\n";
		print SE2 "$_\n";
	}
	else
	{
		my $line = $_;
		my @tmp = split /\s+/,$line;
		my $chr = $tmp[2];
		my $start = $tmp[4];
		my $end = $tmp[5];
		foreach my $k1 (sort keys %new1)
		{
			if ($chr eq $k1)
			{
				foreach my $k2 (sort {$a <=> $b} keys %{$new1{$k1}})
				{
					if ($start <= $k2 && $end >= $k2)
					{	print SE1 "$line\n";	}
					elsif ($start >= $k2 && $end <= $new1{$k1}{$k2})
					{	print SE1 "$line\n";	}
					elsif ($start <= $new1{$k1}{$k2} && $end >= $new1{$k1}{$k2})
					{	print SE1 "$line\n";	}
				}
				last;
			}
		}
		foreach my $k1 (sort keys %new2)
		{
			if ($chr eq $k1)
			{
				foreach my $k2 (sort {$a <=> $b} keys %{$new2{$k1}})
				{
					if ($start <= $k2 && $end >= $k2)
					{	print SE2 "$line\n";	}
					elsif ($start >= $k2 && $end <= $new2{$k1}{$k2})
					{	print SE2 "$line\n";	}
					elsif ($start <= $new2{$k1}{$k2} && $end >= $new2{$k1}{$k2})
					{	print SE2 "$line\n"	}
				}
				last;
			}
		}
	}
}
close INFO;
close SE1;
close SE2;


sub min
{
	my ($f1,$f2)=@_;
	if ($f1 > $f2)
	{	return $f2;	}
	else
	{	return $f1;	}
}

sub max
{
	my ($f1,$f2)=@_;
	if ($f1 > $f2)
	{	return $f1;	}
	else
	{	return $f2;	}
}

#get the threadhood for the selection
sub region
{
	my $in = shift;#input the catted log.filter.piratio_fst.txt
	my $total;
	my (%piratio,%fst);
	open ALL, "$in" or die "$!";
	while (<ALL>)
	{
		chomp;
		next if /^#/;
		my @tmp = split /\t/,$_;
		$piratio{$tmp[1]}{$tmp[4]}++;
		$fst{$tmp[1]}{$tmp[5]}++;
		$total++;
	}
	close ALL;

	my %rate_pi;
	my %rate_fst;
	foreach my $k1 (sort keys %piratio)
	{
		foreach my $k2(sort {$a <=> $b} keys %{$piratio{$k1}})
		{
			$rate_pi{$k1}{$k2} = $piratio{$k1}{$k2}/$total;
		}
		foreach my $k2 (sort {$a <=> $b} keys %{$fst{$k1}})
		{
			$rate_fst{$k1}{$k2} = $fst{$k1}{$k2}/$total;
		}
	}
	
	my ($sum_pi,$sum_fst);
	my (%threadhood_pi,%threadhood_fst);

	foreach my $k1 (sort keys %rate_pi)
	{
		foreach my $k2 (sort {$a <=> $b} keys %{$rate_pi{$k1}})
		{
			$sum_pi += $rate_pi{$k1}{$k2};
			if ($sum_pi >= 0.05 && $sum_pi <= 0.95)
			{	$threadhood_pi{$k1}{$k2} = $rate_pi{$k1}{$k2};	}
		}
		foreach my $k2 (sort {$a <=> $b} keys %{$rate_fst{$k1}})
		{
			$sum_fst += $rate_fst{$k1}{$k2};
			if ($sum_fst >= 0.05 && $sum_fst <= 0.95)
			{	$threadhood_fst{$k1}{$k2} = $rate_fst{$k1}{$k2};	}
		}
	}
	
	my (@select_pi,@select_fst);
	foreach my $k1 (sort keys %threadhood_pi)
	{
		@select_pi = sort {$a <=> $b} keys %{$threadhood_pi{$k1}};
		@select_fst = sort {$a <=> $b} keys %{$threadhood_fst{$k1}};
	}
	my ($pi1,$pi2) = ($select_pi[0],$select_pi[-1]);
	my $fst2 = $select_fst[-1];
	return ($pi1,$pi2,$fst2);
}



## changed region sub by shichunwei ^16Oct.28.
sub newregion
{
	my $in = shift;#input the catted log.filter.piratio_fst.txt
	my $total;
	my (%piratio,%fst);
	open ALL, "$in" or die "$!";
	my @pi;
	my @fst;
	while (<ALL>)
	{
		chomp;
		next if /^#/;
		my @tmp = split /\t/,$_;
		push @pi,$tmp[4];
		push @fst,$tmp[5];
		$total++;
	}
	close ALL;

	@pi = sort {$a<=>$b} @pi;
	@fst = sort {$a<=>$b} @fst;

	my $pi1 = $pi[int($total*0.05)];
	my $pi2 = $pi[int($total*0.95)+1];
	my $fst2 = $fst[int($total*0.95)+1];
	print "$pi1\t$pi2\t$fst2\n";
	return ($pi1,$pi2,$fst2);
}
