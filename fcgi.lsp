#!/usr/bin/newlisp
; single version
(load "import.lsp")
(define (fcgi_print)
	(setq arg "")
    (dolist (x (args))
		(setq arg (append arg (string x)))
    )

;	(FCGI_vprintf arg)
;	(setq arg (append arg "\r\n"))
;	(FCGI_puts arg)
	(for (x 0  (- (length arg) 1) )
		(FCGI_putchar (char (nth x arg)))
	)
)

(define (fcgi_println)
    (setq arg "") 
    (dolist (x (args))
       (setq arg (append arg (string x)))
    )
	(setq arg (append arg "\n")) ; NEW LINE FEED	
;	(FCGI_vprintf arg)
;	(setq arg (append arg "\r\n"))
;	(FCGI_puts arg)
    (for (x 0  (- (length arg) 1) )
        (FCGI_putchar (char (nth x arg)))
    )

)

(constant 'print fcgi_print)
(constant 'println fcgi_println)


(define (fcgi_module m)
    (if 
        (= ostype "Linux") (load (string "/usr/share/newlisp/modules/" m)) 
    )   

)
(constant 'module fcgi_module)

(define (fcgi_exit)
	(if-not (nil? (last-error))
		(print (last-error)))
	(if-not (nil? (sys-error))
		(print (sys-error)))
)
(constant 'exit fcgi_exit)

(define OPEN_TAG "<%")
(define CLOSE_TAG "%>")

(define (eval-template str (ctx MAIN) , start end next-start next-end block (buf ""))
  (setf start (find OPEN_TAG str))
  (setf end (find CLOSE_TAG str))
  
  ;; Prevent use of code island tags inside code island from breaking parsing.
  (when (and start end)
    (while (and (setf next-end (find CLOSE_TAG (slice str (+ end 2))))
                (setf next-start (find OPEN_TAG (slice str (+ end 2))))
                (< next-end next-start))
      (inc end (+ next-end 2)))
    (when (and start (not end)) (throw-error "Unbalanced tags.")))
  
  (while (and start end)
    (write-buffer buf (string "(print [text]" (slice str 0 start) "[/text])"))
    (setf block (slice str (+ start 2) (- end start 2)))
    (if (starts-with block "=")
      (write-buffer buf (string "(print " (rest block) ")"))
      (write-buffer buf (trim block)))
    (setf str (slice str (+ end 2)))
    (setf start (find OPEN_TAG str))
    (setf end (find CLOSE_TAG str))

    ;; Prevent use of code island tags inside code island from breaking parsing.
    (when (and start end)
      (while (and (setf next-end (find CLOSE_TAG (slice str (+ end 2))))
                  (setf next-start (find OPEN_TAG (slice str (+ end 2))))
                  (< next-end next-start))
        (inc end (+ next-end 2)))
      (when (and start (not end)) (throw-error "Unbalanced tags."))))

  (write-buffer buf (string "(print [text]" str "[/text])"))
  (eval-string buf ctx (print (last-error))))

(define (put-page file-name , page start end)
    (set 'page (read-file file-name))

;	(replace "%" page "%%")

    (set 'start (find "<%" page))
    (set 'end (find "%>" page))
    (while (and start end)
;		(if (!= start 0)
	        (print (slice page 0 start))
;		)
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
;		(eval-template (read-file src_file))
		(print src_file " Not Found!")
	)
)
(exit 0)  



