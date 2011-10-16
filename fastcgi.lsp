;; newlisp fastcgi support [dexterkidd#me.com]
(define (put-str str , page start end)
    (set 'page str)
    (set 'start (find "<%" page))
    (set 'end (find "%>" page))
	(setq ret "")
    (while (and start end)
	(setq ret (append ret (slice page 0 start)))
	(setq lsp_body (slice page (+ start 2) (- end start 2)))
	(setq $0 0)

	(setq get-expr (read-expr lsp_body MAIN () $0))
	(if (not (nil? get-expr))
		(begin
		(do-while (not (nil? get-expr))
			(setq ret (append ret (string (eval-string  (string get-expr)))))
			(setq get-expr  (read-expr lsp_body MAIN () $0))
		)
		)
	)

        (set 'page (slice page (+ end 2)))
        (set 'start (find "<%" page))
        (set 'end (find "%>" page)))
	
	(setq ret (append ret page))
	ret
)


(define (eval-page file-name , page start end)
	(set 'page (read-file file-name))
		(put-str page)
)



(set 'port 9000)
(set 'socket (net-listen port))
(setq lookstr "SCRIPT_FILENAME")
(setq (global 'y) 0)

(set 'fcgi_footer (pack "c c c c c c c c c c c c c c c c c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 0x00 0x00 0x00 0x01 0x03 0x00 0x01 0x00 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00))

(set 'headers "Content-type: text/html\r\n\r\n")

;(if (not (nil? (net-error)))
;	(print "net-error")
;	(print (net-error))
;	(exit)
;)

(set 'server (net-accept socket))
(net-select server  "read" 1000) ; read the latest
(net-receive server buffer 8192)
;; processing lsp to html
(replace "\000" buffer "\001")
(setq res_len (length buffer))
(setq find_start (+ (find lookstr buffer) (length lookstr)) )
(for (x find_start res_len 1 (= 12 (char (nth x buffer))) ) (begin (setq y x)) )

(setq lsp_file (slice buffer find_start (+ 1 (- y find_start))) )

(if (file? lsp_file)
	(begin
		; existed
		(setq content (string (eval-page lsp_file)))
		
	)
	(begin
		(setq content  "file not found")
	)
)
;; process lsp to  html

;(set 'content (string "<html><title>haha</title><h1>fuckyou</h1></html>"))

(set 'totallen (length (string headers content) ))
(set 'len_str (format "%x" totallen))
(if (> (length len_str) 2)
	(set 'fcgi_header (pack "c c c c >d c c"  0x01 0x06 0x00 0x01 totallen 0x00 0x00))
)
(if (<= (length len_str) 2)
	(set 'fcgi_header (pack "c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 totallen 0x00 0x00))
)

(set 'output (append fcgi_header headers content fcgi_footer))

(net-send server output)
(close server)


