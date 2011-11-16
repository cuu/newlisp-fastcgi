NEWLISP FastCGI port
=============

Installation
-----------

###	debian system.

	apt-get install libfcgi-dev & spawn-fcgi.
		
	then download fcgi.lsp to anywhere
	
	(or (chmod +x fcgi.lsp) (chmod 755 fcgi.lsp))


usage:
-----

	spawn-fcgi -p 9000 -f /tmp/fcgi.lsp -U www-data -G www-data -F 10


=============

The port is 9000. 
Not finished yet,But it'll work .
Have been tested under nginx/lighttpd ON LINUX 32 .

Work with CGI newlisp code.

Disable function list:
-----

	Processes and the Cilk API
	Socket TCP/IP and UDP network API 
	Reflection and customization 
	newLISP internals API
