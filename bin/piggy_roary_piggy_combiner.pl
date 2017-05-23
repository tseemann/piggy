#!/usr/bin/env perl

#use Text::CSV;

#$csv = Text::CSV->new({ sep_char => ',', binary => 1 });

$out_dir=$ARGV[0];
$roary_dir=$ARGV[1];
$method=$ARGV[2];

print STDOUT "Combining gene and IGR matrices...\n";
print STDERR "Combining gene and IGR matrices...\n";

open OUTPUT, ">$out_dir/roary_piggy_combined.tab";

open INPUT_R, "$roary_dir/gene_presence_absence.csv";
while(<INPUT_R>){
	$line=$_;
	$line=~s/\R//g;
	$line=~s/^"//;
	$line=~s/"$//;
	@line_array=split(/","/, $line);
	
	#if($csv->parse($line)){
		
	#	@line_array=$csv->fields();
		
		if($line =~ /^Gene","/){
			@header_array=@line_array;
			
			$col_count=scalar(@line_array);
		
			$isolate_sta=14;
			$isolate_end=$col_count - 1;
		
			for($i=$isolate_sta; $i<=$isolate_end; $i++){
				#push @isolate_array, $header_array[$i];
			}
		}else{
			# Only use single copy genes.
			if($line_array[5] == 1){
				for($i=$isolate_sta; $i<=$isolate_end; $i++){
					if($line_array[$i]){
						$isolate=$header_array[$i];
						$gene_id=$line_array[$i];
						$gene=$line_array[0];
			
						#print "$isolate\n";
			
						$gene_id_hash{$isolate}{$gene_id}=$gene;
					}
				}
			}
		}
	#}
}

open INPUT_I, "$out_dir/IGR_presence_absence.csv";
while(<INPUT_I>){
	$line=$_;
	$line=~s/\R//g;
	$line=~s/^"//;
	$line=~s/"$//;
	@line_array=split(/","/, $line);
	
	if($line =~ /^Gene","/){
		@header_array=@line_array;
		
		$col_count=scalar(@line_array);
		
		$isolate_sta=14;
		$isolate_end=$col_count - 1;
		
		#for($i=$isolate_sta; $i<=$isolate_end; $i++){
		#	push @isolate_array, $header_array[$i];
		#}
	}else{
		@int_gene_array=();
		%int_gene_hash=();
		for($i=$isolate_sta; $i<=$isolate_end; $i++){
			if($line_array[$i]){
				$isolate=$header_array[$i];
				if($line_array[$i] =~ /^(\S+)/){
					$int_id=$1;
				}
				$int=$line_array[0];
				
				#$int_id_hash{$isolate}{$int_id}=$int;
			
				@int_id_array=split(/_\+_\+_/, $int_id);
				
				if($gene_id_hash{$isolate}{$int_id_array[1]} && $gene_id_hash{$isolate}{$int_id_array[2]}){
				
					$tmp_gene_1=$gene_id_hash{$isolate}{$int_id_array[1]};
					$tmp_gene_2=$gene_id_hash{$isolate}{$int_id_array[2]};
					
					if($method eq "GENE_PAIR"){
					
						if($int_id_array[3] eq "CO_F"){
							$tmp_gene_2="*$tmp_gene_2";
						}elsif($int_id_array[3] eq "CO_R"){
							$tmp_gene_1="*$tmp_gene_1";
						}elsif($int_id_array[3] eq "DP"){
							$tmp_gene_1="*$tmp_gene_1";
							$tmp_gene_2="*$tmp_gene_2";
						}
					
						@tmp_gene_array=("$tmp_gene_1", "$tmp_gene_2");
						@tmp_gene_array=sort(@tmp_gene_array);
		
						$tmp_gene_1_2="$tmp_gene_array[0]_+_+_$tmp_gene_array[1]";
		
						$int_gene_hash{$tmp_gene_1_2}++;
						
					}elsif($method eq "UPSTREAM"){
					
						if($int_id_array[3] eq "CO_F"){
							$tmp_gene_2="*$tmp_gene_2";
						
							$int_gene_hash{$tmp_gene_2}++;
						}elsif($int_id_array[3] eq "CO_R"){
							$tmp_gene_1="*$tmp_gene_1";
						
							$int_gene_hash{$tmp_gene_1}++;
						}elsif($int_id_array[3] eq "DP"){
							$tmp_gene_1="*$tmp_gene_1";
							$tmp_gene_2="*$tmp_gene_2";
						
							$int_gene_hash{$tmp_gene_1}++;
							$int_gene_hash{$tmp_gene_2}++;
						}
					}				
				}
			}
		}
		
		@int_gene_array=sort { $int_gene_hash{$b} <=> $int_gene_hash{$a} } keys %int_gene_hash;
		
		foreach $int_gene(@int_gene_array){
			print OUTPUT "$int\t$int_gene\t$int_gene_hash{$int_gene}\n";
		}
	}
}

print STDOUT "Gene and IGR matrices combined.\n";
print STDERR "Gene and IGR matrices combined.\n";

