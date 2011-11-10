;newlisp fastcgi support [dexterkidd#me.com]
(define (getpid) (sys-info 7))
(define (getparent_id) (sys-info 6))

(define (put-page file-name , page start end)
    (set 'page (read-file file-name))
    (set 'start (find "<%" page))
    (set 'end (find "%>" page))
    (while (and start end)
        (print (slice page 0 start))
		
       	(eval-string (slice page (+ start 2) (- end start 2)) MAIN (print (last-error)))
		;(if-not (nil? err-ret)   (print (string err-ret)))

        (set 'page (slice page (+ end 2)))
        (set 'start (find "<%" page))
        (set 'end (find "%>" page)))
    (print page))


(define (set_env lookstr nextstr  buf)

	(setq find_start (+ (find lookstr buf) (length lookstr) ) )
	(setq y (- (find nextstr buf)  2))

	(if (or (nil? y) (< y 0))
			 (setq y 0)) 
	(env lookstr  (slice buf find_start (- y find_start)) )
	; env ddoes not show the nil env value
)
;;;;------------------------------------------------- INIT 
;(set 'mem (share))
;(share mem true)
(load "config.lsp")

(set 'socket (net-listen port))
(if (nil? socket) (begin (print (net-error)) (exit)))
(sleep 2500)
(setq lookstr "SCRIPT_FILENAME")
;(setq (global 'y) 0)
(set 'fcgi_footer (pack "c c c c c c c c c c c c c c c c c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 0x00 0x00 0x00 0x01 0x03 0x00 0x01 0x00 0x08 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00))

;(set 'html_headers "Content-type: text/html\r\n\r\n")
(set 'html_headers "")

(define (fcgi_ret) 
	(while (setq server (net-accept socket))

		(if (not (net-select server "read" 10000))
			(begin 
				(if (net-error) (print (net-error)))
				(setq content "net-select server read error" )
			)
			(begin 
				(net-receive server buffer 4096) ;; fastcgi headers more or less 1024 bytes 
				(setq y 0)
				(replace "\000" buffer "\001")
				(setq res_len (length buffer))
				(setq find_start (+ (find lookstr buffer) (- (length lookstr) 0)) )
				(setq y (find (pack "c 4s" 0x0c  "QUER") buffer))
				(if (nil? y) (setq y 0))
				(setq lsp_file (slice buffer find_start (+ 0 (- y find_start))) )
					
				(if (file? lsp_file)
					(begin
						
						(set_env "QUERY_STRING" "REQUEST_METHOD"  buffer)
						(set_env "REQUEST_METHOD" "CONTENT_TYPE"  buffer)
						(set_env "CONTENT_TYPE" "CONTENT_LENGTH"  buffer)
						(set_env "CONTENT_LENGTH" "SCRIPT_NAME"  buffer)
						
						(set_env "SERVER_ADDR" "SERVER_PORT" buffer)
						(set_env "SERVER_NAME" "REDIRECT_STATUS" buffer)	

                		(setq content "")
						(setq tmp_file (string tmp_dir "/" (getpid) ".newlisp")) 
		                (device (open  tmp_file "w"))
        	    	        (put-page lsp_file)
	            	    (close (device))
                    	
						(setq content (read-file tmp_file))
	   		            ;(while (not (nil?  (setq reads (read-buffer in buff 65535))))
						;	(setq content (append content buff))
            			;)   
					)
					(begin
						(setq content  (string  lsp_file "not found " y))
					)
				)	
			)
		)
		;; process lsp to  html
		(setq src (length content))
		(if (or  (< src jump ) (= src jump) ) ; if the lsp file is smaller than 64512 send once
			(begin
				(set 'totallen (length (string html_headers content) ))
		
				(set 'len_str (format "%x" totallen))
				(if (> (length len_str) 2)
					(set 'fcgi_header (pack "c c c c >d c c"  0x01 0x06 0x00 0x01 totallen 0x00 0x00))
				)
				(if (<= (length len_str) 2)
					(set 'fcgi_header (pack "c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 totallen 0x00 0x00))
				)

				(set 'output (append fcgi_header html_headers content fcgi_footer))
				;(println "\n" (getpid) )
				;(if (not (net-select server "w" 1000))
				;(begin
				;	(net-close server))
				;(begin
					(net-send server output)
					(net-close server)
				;)
				;)
			)
			(begin ;; bigg than jump (64512) ,send multi times  
				(setq jug true)
				(setq st 0)
				(while (true? jug)
					(if (or (< (- src st) jump ) (= (- src st) jump))
						(begin
							(setq vcontent (slice content st (- src st)))
							(set 'totallen (length vcontent))

							(set 'len_str (format "%x" totallen))
							(if (> (length len_str) 2)
								(set 'fcgi_header (pack "c c c c >d c c"  0x01 0x06 0x00 0x01 totallen 0x00 0x00))
							)   
							(if (<= (length len_str) 2)
								(set 'fcgi_header (pack "c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 totallen 0x00     0x00))
							)					
							
							(set 'output (append fcgi_header  vcontent fcgi_footer))
                                ;(println "\n" (getpid) )
							;(if (not (net-select server "w" 1000))
						;		(begin
						;			(if (net-error) (print (net-error)))
	;								(net-close server))
	;							(begin
									(net-send server output)
									(net-close server);)
							;)
							(setq jug nil);means quit while
						)
						(begin
							(setq vcontent (slice content st jump))
							(if (!= 0 st)
								(set 'totallen (length vcontent))
								(set 'totallen (+ (length vcontent) (length html_headers)))
							)
			                (set 'len_str (format "%x" totallen))
                        	(if (> (length len_str) 2)
                           		(set 'fcgi_header (pack "c c c c >d c c"  0x01 0x06 0x00 0x01 totallen 0x00 0x00))
                           	)   
                            (if (<= (length len_str) 2)
                            	(set 'fcgi_header (pack "c c c c c c c c"  0x01 0x06 0x00 0x01 0x00 totallen 0x00     0x00))
                            )
							(if (!= 0 st)
                                (set 'output (append fcgi_header  vcontent))
								(set 'output (append fcgi_header  html_headers vcontent))
							)
                                			;(println "\n" (getpid) )
                            ;(if (not (net-select server "w" 1000))
                            ;	(begin
							;		(if (net-error) (print (net-error))))
                             ;   (begin
                                	(net-send server output);)
                            ;)

							(setq st (+ st jump))
						)
					);end if or < - src st jmp = ....
				);end while true? jug	
			)
		); end if < src jump

	); end while setq server net-accept socket
); end fcgi_ret

;(setf pidarray (array children_num))
;(setf parray (array children_num))

;(for (x 0 (- children_num 1))
;	(setq (nth x pidarray) (fork (fcgi_ret)))
	;(sleep 1000)
;)

;; master start all process to work
(if (= (getparent_id) 0)
	(fcgi_ret)
)
