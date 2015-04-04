This vim script generates data flow documentation automatically from some R code assuming some conventions to read and write files are followed. 

For example, we have an R script `normalization.R` with the following function definition:

	single_mapping_cik_filename = function() {
		m = read_merged()
		mcf = process_mapping_cik_filename(m)
		write_mapping_cik_filename(mcf)
	}

In this function, we have one input and one output. The documentation of data flow for this file will be as follows:

	normalization.R
		single_mapping_cik_filename 
			< merged
			process_mapping_cik_filename
			> mapping_cik_filename

The definitions of read/write functions are done in some other place. The documentation generator assumes that all input and output operations are done by independent functions with this naming convention: `read_x` or `write_x`

It is possible to check all open R scripts and generate documentation but I didn't do this because some of the R scripts are out of interest. Thus, the documentation generator assumes that all the R script files to be listed first in `automatic_flow.otl` file which is both the input and the output of the generator. 

For example, I have the following list of R files in `automatic_flow.otl`:

	Automatically Generated Flows
	=============================

	Source Files id=r_files
	----------------
	master.R
	normalization.R
	filing_functions.R

The generator script crawls these 3 R files and extracts all the functions that contain a read/write function inside.

Customizing for your project
----------------------------

1. You should specify the path to the `automatic_flow.otl` file for your project by changing the following line in `vim-dataflow-generator-r.vim`:

	let path_to_generated_doc = "~/projects/SEC_Filings/parser/automatic_flow.otl"

2. List all the R files in `automatic_flow.otl` under the line `Source Files id=r_files`

Running the generator
---------------------

1. Open all the R files for which you are going to generate documentation in Vim.

2. Run the command in Vim's command line:

	:DataflowAllScripts

