use strict;
use warnings;
use Data::Dumper;

$| = 1;

=pod
.DEF file parser that calculates no. of site rows and placement utilization.
Script must be executed in ./scripts directory.
=cut

sub main { 
    my $def_file = 'Task_1/sources/mips_routed.def';
    my $lef_file = 'Task_1/sources/NangateOpenCellLibrary.macro.lef';
    #my $def_file = '../sources/mips_routed.def';
    #my $lef_file = '../sources/NangateOpenCellLibrary.macro.lef';
    my $no_site_rows = no_site_rows($def_file);
    my $placement_utilization = placement_utilization($def_file, $lef_file);
    print "No. of site rows is $no_site_rows" . "\n";
    print "Placement utilization is $placement_utilization" . "\n";
}

sub no_site_rows() {
   my $def_file = shift;
   open(DEF, $def_file) || die "Unable to open $def_file" . "\n";
   my $count = 0;
   while (my $line = <DEF>) {
    chomp $line;
    if ($line =~ /ROW\s*/) {
        $count++;
    }
   }
   close(DEF);
   return $count;
}

sub placement_utilization() {
   my($def_file, $lef_file) = @_;
   my @lef_array;
   open(LEF, $lef_file) || die "Unable to open $lef_file" . "\n";
   while (my $line = <LEF>) {
    chomp $line;
    if ($line =~ /MACRO\s*(.+)/) {
        push @lef_array, $1;
    }
    if ($line =~ /\s*SIZE\s*([\d\.]+)\s*BY\s*([\d\.]+)/) {
        push @lef_array, $1, $2;
    }
   }
   close(LEF);
   my %cell_area;
   for (my $i = 0 ; $i < scalar(@lef_array) ; $i = $i + 3) {
    $cell_area{"$lef_array[$i]"} = $lef_array[$i + 1] * $lef_array[$i + 2];
   }
   #print Dumper(@lef_array);
   #print Dumper(%cell_area);

   return 0;
}

main();