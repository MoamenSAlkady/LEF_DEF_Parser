use strict;
use warnings;
use Data::Dumper;

$| = 1;

=pod
.DEF file parser that calculates no. of site rows and placement utilization.
Script must be executed in ./Tasks directory.
=cut

sub main { 
    my $def_file = 'Task_1/sources/mips_routed.def';
    my $lef_file = 'Task_1/sources/NangateOpenCellLibrary.macro.lef';
    my $no_site_rows = no_site_rows($def_file);
    my $placement_utilization = placement_utilization($def_file, $lef_file, $no_site_rows);
    print "No. of site rows is $no_site_rows" . "\n";
    print "Placement utilization is $placement_utilization%" . "\n";
}

sub no_site_rows() {
   my $def_file = shift;
   open(DEF, $def_file) || die "Unable to open $def_file" . "\n";
   my $count = 0;
   while (my $line = <DEF>) {
    chomp $line;
    if ($line =~ /\s*ROW\s*/) {
        $count++;
    }
   }
   close(DEF);
   return $count;
}

sub placement_utilization() {
   my($def_file, $lef_file, $no_site_rows) = @_;
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
   my %cell_no = %cell_area;
   foreach my $cell(keys %cell_no) {
    $cell_no{"$cell"} = 0;
   }

   #print Dumper(%cell_no);
   open(DEF, $def_file) || die "Unable to open $def_file" . "\n";
   while (my $line = <DEF>) {
    chomp $line;
    if ($line =~ /\s*END\s*COMPONENTS/) {
        last;
    }
    foreach my $cell (keys %cell_no) {
        if ($line =~ /\s*$cell\s*/) {
            $cell_no{$cell} = $cell_no{$cell} + 1;
        }
    }
   }
   close(DEF);
   #print Dumper(%cell_no);

    my %fill_cell_area;
    my %fill_cell_no;
    foreach my $cell(keys %cell_area) {
        if ($cell =~ /fill|tap/i) {
            $fill_cell_area{$cell} = $cell_area{$cell};
        }
    }
    foreach my $cell(keys %cell_no) {
        if ($cell =~ /fill|tap/i) {
            $fill_cell_no{$cell} = $cell_no{$cell};
        }
    }
   #print Dumper(%fill_cell_area);
   #print Dumper(%fill_cell_no);

    my %design_cell_area;
    my %design_fill_cell_area;

    foreach my $cell(keys %cell_area) {
        $design_cell_area{$cell} = $cell_area{$cell} * $cell_no{$cell};
    }
    foreach my $cell(keys %fill_cell_area) {
        $design_fill_cell_area{$cell} = $fill_cell_area{$cell} * $fill_cell_no{$cell};
    }

   #print Dumper(%design_cell_area);
   #print Dumper(%design_fill_cell_area);

    my $total_cell_area = 0;
    my $total_fill_cell_area = 0;

    foreach my $cell(keys %design_cell_area) {
        $total_cell_area = $total_cell_area + $design_cell_area{$cell};
    }
    foreach my $cell(keys %design_fill_cell_area) {
        $total_fill_cell_area = $total_fill_cell_area + $design_fill_cell_area{$cell};
    }

   #print "$total_cell_area" . "\n";
   #print "$total_fill_cell_area" . "\n";

    my $core_area = core_area($def_file, $no_site_rows);
    my $placement_utilization = $total_cell_area / $core_area * 100;

    print "$core_area" . "\n";

   return $placement_utilization;
}

sub core_area() {
    my($def_file, $no_site_rows) = @_;
    open(DEF, $def_file) || die "Unable to open $def_file" . "\n";
    my $conversion_factor;
    my $y1 = 0;
    my $y2 = 0;
    my $no_sites;
    my $site_width;
    my $site_height;
    while (my $line = <DEF>) {
    chomp $line;
    if ($line =~ /\s*UNITS\s*DISTANCE\s*MICRONS\s*(\d+)/) {
        $conversion_factor = $1;
    }
    if ($line =~ /\s*ROW\s*STD_ROW_\d+\s*unit\s*\d+\s*(\d+)\s*\S+\s*DO\s*(\d+)\s*BY\s*1\s*STEP\s*(\d+)/ && $y1 == 0) {
        $y1 = $1;
        $no_sites = $2;
        $site_width = $3 / $conversion_factor;
        next;
    }
    if ($line =~ /\s*ROW\s*STD_ROW_\d+\s*unit\s*\d+\s*(\d+)\s*\S+\s*DO\s*\d+\s*BY\s*1\s*STEP\s*\d+/ && $y1 != 0) {
        $y2 = $1;
        $site_height = ($y2 - $y1) / $conversion_factor;
        last;
    }
   }
   close(DEF);
   #print "$y1" . "\n";
   #print "$y2" . "\n";
   #print "$no_sites" . "\n";
   #print "$site_width" . "\n";
   #print "$site_height" . "\n";

   my $site_row_area = $no_sites * $site_width * $site_height;
   my $core_area = $no_site_rows * $site_row_area;

   return $core_area;
}
main();