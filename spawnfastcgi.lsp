;newlisp fastcgi support [dexterkidd#me.com]
(define (getpid) (sys-info 6))

(define (put-str str , page start end)
    (set 'page str)
    (set 'start (find "<%" page))
    (set 'end (find "%>" page))
	(setq ret "")
    (while (and start end)
	(setq ret (append ret (slice page 0 start)))
	(setq lsp_body (slice page (+ start 2) (- end start 2)))
	(setq $0 0)

;	(catch (read-expr lsp_body MAIN () $0) 'get-expr)
	(catch (read-expr lsp_body MAIN () $0) 'get-expr)
	(do-while (and (nil? (find "ERR:" get-expr)) (not (nil?  get-expr)))
		(if (true? (find "ERR:"  get-expr))
			(begin
			(setq ret (append ret (string get-expr)))
			)
			(begin
				(catch (eval-string  (string get-expr)) 'err-ret)
				(if-not (nil? err-ret)
					(setq ret  (append ret (string err-ret)))
					(if-not (nil? (sys-error))
						(setq ret  (append ret (string (sys-error)))))
				)
			)
		)   
		;(setq get-expr  (read-expr lsp_body MAIN () $0))
		(catch (read-expr lsp_body MAIN () $0) 'get-expr)
		(if (true? (find "ERR:"  get-expr))
			(setq ret (append ret (string get-expr)))
		)
	);;ends of do-while

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
;;;;------------------------------------------------- INIT 
;(semaphore)
(set 'mem (share))
;(set 'sid (semaphore))
;(semaphore sid)
(share mem true)


(set 'port 9000)
(setq children_num 2)

(set 'socket (net-listen port))
(if (nil? socket) (exit))
(sleep 2500)
(setq lookstr "SCRIPT_FILENAME")
(setq (global 'y) 0)

(set 'fcgi_footer (pack "c c c c c c c c c c c c c c c c c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 0x00 0x00 0x00 0x01 0x03 0x00 0x01 0x00 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00))

(set 'headers "Content-type: text/html\r\n\r\n")

(define (fcgi_ret) 
;	(semaphore sid -1);; wait at the first of forking
	(while (setq server (net-accept socket))
;		(while (not (net-select socket "read" 2000))
;			(if (net-error) (print (net-error))))

		(if (not (net-select server "read" 4000))
			(begin 
				(if (net-error) (print (net-error)))
				(setq content "net-select server read error" )
			)
			(begin 
				(net-receive server buffer 8192) 
				(replace "\000" buffer "\001")
		
				(setq res_len (length buffer))
				(setq find_start (+ (find lookstr buffer) (length lookstr)) )
				(for (x find_start res_len 1 (= 12 (char (nth x buffer))) ) (begin (setq y x)) )

				(setq lsp_file (slice buffer find_start (+ 1 (- y find_start))) )
	
				(if (file? lsp_file)
					(setq content  (eval-page lsp_file))
					(setq content  " File not found")
				)
			)
		)
		;; process lsp to  html
	
		(set 'totallen (length (string headers content) ))
		(set 'len_str (format "%x" totallen))
		(if (> (length len_str) 2)
			(set 'fcgi_header (pack "c c c c >d c c"  0x01 0x06 0x00 0x01 totallen 0x00 0x00))
		)
		(if (<= (length len_str) 2)
			(set 'fcgi_header (pack "c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 totallen 0x00 0x00))
		)

		(set 'output (append fcgi_header headers content fcgi_footer))
		;(println "\n" (getpid) )
		(if (not (net-select server "w" 1000))
			(begin
				(net-close server))
			(begin
				(net-send server output)
				(net-close server))
		)
	); end while setq server net-accept socket
); end fcgi_ret

(setf pidarray (array children_num))
(setf parray (array children_num))

(for (x 0 (- children_num 1))
	(setq (nth x pidarray) (spawn 'p1 (fcgi_ret)))
	;(sleep 1000)
)

;; master start all process to work
(if (= (getpid) 0)
;	(semaphore sid (+ 1 children_num))
)
