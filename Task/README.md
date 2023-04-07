# Task Overview
This code parses both DEF and LEF files to extract and process the necessary information to calculate both No. of Site Rows and Placement Utilization.

# Description
This code goes through different steps so as to parse DEF and LEF files and create the necessary data structures to facilitate the processing of necessary information to calculate the No. of Site Rows and Placement Utilization of the design, which are as folows:
* Define directories where DEF and LEF files are located and calling the subroutines created to process, calculate, and print the required parameters.
* No. of Site Rows calculation through no_site_rows subroutine is as follows:
    * Open DEF file.
    * Match for site row lines and count them.
    * Such count is the No. of Site Rows.
* Placement Utilization calculation through placement_utilization and core_area subroutines is as follows:
    * Create array @lef_array to store names and sizes of all cells in LEF file.
    * Create hash %cell_area from array @lef_array to store names and areas of all cells in LEF file.
    * Initialize hash %cell_no from hash %cell_area to store names and no. instances of all cells in design.
    * Open DEF file and search in every line in the COMPONENTS section for every cell name stored in hash %cell_no.
    * Increment no. of instances in hash %cell_no for each cell based on successful matching.
    * Create hash %fill_cell_area from hash %cell_area by matching through it to store names and areas of filler cells in LEF file.
    * Create hash %fill_cell_no from hash %cell_no by matching through it to store names and no. of instances of filler cells in design.
    * Create hash %design_cell_area from hashes %cell_area and %cell_no by multiplication to store total area of all cells in design.
    * Create hash %design_fill_cell_area from hashes %fill_cell_area and %fill_cell_no by multiplication to store total area of filler cells in design.
    * Create variable $total_cell_area from hash %design_cell_area to store total area of all cells in design.
    * Create variable $total_fill_cell_area from hash %design_fill_cell_area to store total area of filler cells in design.
    * Call core_area subroutine to calculate total core area.
    * Calculate placement utilization by subtracting $total_fill_cell_area from $ total_cell_area and dividing by $core_area.
* Total Core Area calculation through core_area subroutine is as follows:
    * Open DEF file.
    * Create variable $conversion_factor by scanning DEF file for conversion factor to store it for any calculations.
    * Create variables $y1, $no_sites, and $site_width by matching through first site row statement in DEF file.
    * Create variables $y2 and $site_height by matching through second site row statement in DEF file.
    * Variables $y2 and $y1 store y-coordinates of first and second site rows to create variable $site_height to store site row height.
    * Variable $site_width stores single site width.
    * Create variable $site_row_area from variables $no_sites, $site_width, and $site_height by multiplying them to store single site row area.
    * Create variable $core_area from variables $no_site_rows and $site_row_area by multiplying them to store total core area.

# Getting Started
## Dependencies
* Perl Language Interpreter
* Makefile

## Execution
* Unzip Task_Moamen_Alkady.rar.
* Open terminal in ./Task directory.
* Enter 'make' command in terminal.