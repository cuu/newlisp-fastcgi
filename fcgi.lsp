#!/usr/bin/newlisp
; single version
(load "web.lsp"); well,you can load it or put it into modules dir
(import "/usr/local/lib/libfcgi.so.0.0.0" "FCGI_Accept")
(import "/usr/local/lib/libfcgi.so.0.0.0" "FCGI_puts")
(import "/usr/local/lib/libfcgi.so.0.0.0" "FCGI_printf")
(constant 'print FCGI_printf)

(while (>= (FCGI_Accept) 0)
	(setq src_file (env "SCRIPT_FILENAME"))
	(if (file? src_file)
		(Web:eval-template (read-file src_file))
		(print "Not Found!")
	)
)
(exit 0)  



