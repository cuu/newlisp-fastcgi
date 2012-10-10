 (if 
        (= ostype "Linux") (setq fcgi_lib "/usr/lib/libfcgi.so") 
		(= ostype "OSX"  ) (setq fcgi_lib "/opt/lib/libfcgi.0.0.0.dylib")
		;;and windows by yourself
 )

(import fcgi_lib  "FCGI_Accept")

(import fcgi_lib "FCGI_guuprintf")
