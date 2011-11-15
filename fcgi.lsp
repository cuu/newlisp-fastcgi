#!/usr/bin/newlisp
; single version
(load "import.lsp")

(define (fcgi_module m)
	(if
		(= ostype "Linux") (load (string "/usr/share/newlisp/modules/" m))
	)

)
(constant 'module fcgi_module)

(define (fcgi_print)
    (setq arg "")
    (dolist (x (args))
       (setq arg (append arg (string x)))
    )
	(FCGI_printf arg)
)

(define (fcgi_println)
    (setq arg "") 
    (dolist (x (args))
       (setq arg (append arg (string x)))
    )
	(setq arg (append arg "\n")) ; NEW LINE FEED	
	(FCGI_printf arg)
)

(constant 'print fcgi_print)
(constant 'println fcgi_println)

(define (fcgi_exit)
	(if-not (nil? (last-error))
		(print (last-error)))
	(if-not (nil? (sys-error))
		(print (sys-error)))
)
(constant 'exit fcgi_exit)

(define (put-page file-name , page start end)
    (set 'page (read-file file-name))
    (set 'start (find "<%" page))
    (set 'end (find "%>" page))
    (while (and start end)
        (print (slice page 0 start))
        (eval-string (slice page (+ start 2) (- end start 2)) MAIN (print   (last-error)))
        ;(if-not (nil? err-ret)   (print (string err-ret)))
        (set 'page (slice page (+ end 2)))
        (set 'start (find "<%" page))
        (set 'end (find "%>" page)))
    (print page))


(define (find_dir str)
    (setq pos 0)
    (setq pos1 0)
    (while (setq pos (find "/" str 0 pos1))
        (setq pos1 (+ pos 1)) 
    )   
;   (println pos pos1)
	(slice str 0  pos1)
)

;---------------------------------------------------------------------------
(while (>= (FCGI_Accept) 0)
	(setq src_file (env "SCRIPT_FILENAME"))
		
	(if (file? src_file)
;	(change-dir (find_dir (append (env "DOCUMENT_ROOT") (env                "DOCUMENT_URI"))) )

		(put-page src_file)
		(print src_file " Not Found!")
	)
)
(exit 0)  



