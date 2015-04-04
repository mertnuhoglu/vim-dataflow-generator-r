" UPDATE the path to the generated document
let g:path_to_generated_doc = "~/projects/SEC_Filings/parser/automatic_flow.otl"

command! EFlowAutomatic :exe 'e ' . g:path_to_generated_doc

function! DataflowFromRCode()
	" rules:
	" 1. shell scripts
	"	wrap files written by shell scripts inside a dummy R function that
	"	starts with write
	"	put #@ write_ function at the end of the line such as:
	" > company_exchange_from_10k_filings #@ write_company_exchange_from_10k_filings
	let @f = expand('%')
	normal! gg"0yG
	split
	enew
	set buftype=nofile
	file dataflow
	normal! "0p
	" remove comments except #@ comments
	g/#[^@]/d
	# delete everything except io conventions and wrapper functions
	v/\(single\|process\|read\|write\|function\|download\|unzip\|convert\|main\)\|\(\<\w\+\.sh\|#@\)\>/d
		" requires paranthesis
		"v/\(single\|process\|read\|write\|function\|download\|unzip\|convert\|main\).*(\|\(\<\w\+\.sh\|#@\)\>/d

	" filter function calls/documentary uses of io keywords
	g/write \|read \|log(\|@todo\|^\s*#/d
	" filter out read/write function definitions
	" g/^read\|^write/d
	" remove read. part of read functions and put < symbol
	g/.read\(_\|\.\)/ s/.\{-}read./\t< /
	" remove write. part of write functions and put > symbol. non-greedy match
	" st. keep #@ write_ comments
	g/.write\(_\|\.\)/ s/.\{-}write./\t> /

	" keep shell script calls
	g/.*\w*\.sh\>/ s/.*\(\<\w\+\.sh\)[^#@]*/\t\1 /

	" keep readLines fread writeLines
	g/writeLines/ s/.*\(writeLines\)/\t> \1/
	g/fread\|readLines/ s/.*\(fread\|readLines\)/\t< \1/

	" remove function arguments except apply functions
	%s/\(apply\)\@<!(.*)//g
	" remove trycatch error blocks
	g/error\s*=\s*/d
	" function name
	%s/ = function[^#@]*/ /
	" keep process function calls
	g/=\s*process_.*/ s/^.*=\s*/\t/
	g/=/d
	g/print$/d
	" now remove functions without anything below
	g/^\(\w\|\.\).*\n^\(\w\|\.\)\@=/d
	execute 'normal! ggO'
	normal! "fP
	normal! j>G
	normal! gg"dyG
endfunction
command! DataflowFromRCode call DataflowFromRCode()

function! DataflowScript(script_filename)
	exe 'b ' . a:script_filename
	silent! DataflowFromRCode
	bd
	EFlowAutomatic
	normal! G"dp
endfunction

function! DataflowAllScripts()
	" run on a buffer list of R script filenames such as:
	" index_controller.R
	" index_download_functions.R

	" v2
	EFlowAutomatic
	let start = search("id=r_files")
	let end = search("id=end_r_files") - 1
	let files = filter(getline(start, end), 'v:val =~ "\w*\.R\s*$"')
	
	" remove previous flow first
	EFlowAutomatic
	/id=r_flow
	normal! 2jdG
	" produce list of files
	"EnewAndPaste
	"v/^\w*\.R$/d
	"bd
	for file in files
		call DataflowScript(file)
	endfor
endfunction
command! DataflowAllScripts call DataflowAllScripts()



