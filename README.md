NEWLISP FastCGI port
=============

Installation
-----------

###	debian system.

	apt-get install libfcgi-dev & spawn-fcgi.
		
	then download fcgi.lsp to anywhere
	
	(or (chmod +x fcgi.lsp) (chmod 755 fcgi.lsp))
	
	TURN OFF UTF8 SUPPORT when compling newlisp

	delete this -DSUPPORT_UTF8 flag in your makefile

usage:
-----

	spawn-fcgi -p 9000 -f /tmp/fcgi.lsp -U www-data -G www-data -F 10
	Write down preload modules in modules.lsp
	If import C libs , check it out in import.lsp
	I am not recommand (import) or (module) in website's lsp files
	Also, it's not a best choice to try use newlisp only in your project.

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

NORMAL ERROR ISSUES
-----
	when load some modules ,it is actually import some C .so to work
	so check if there is the right .so file on computer
	Like postgre.lsp need libpq.so.5.1,but today libpq is .so.5.2 
	so need edition by hand.
	It it easy if rung ./fcgi.lsp first, it'll show errors 

	2012 January 2 OSX Lion:
	First is turn newlisp to real 64-bits 

	make -f makefile_darwinLP64
	
	then edit lib fcgi' code to fix import error of _environ expected
	
	in the beginning of fcgi_stdio.c ,find the line of extern char** environ; 

	#if !defined (__APPLE__)
    extern char** environ;
	#else
	#include <crt_externs.h>
	#define environ (*_NSGetEnviron())
	#endif
	
	make clean && make && sudo make install 
	That will fix this error.
	
	for faster add a function in fcgi_stdio.c, FCGI_printf will have bugs on % ,so I need a nother function
	No issues with %

	int FCGI_guuprintf( void *str)
	{
    	return FCGI_fwrite(str, strlen(str), 1 , FCGI_stdout);
	}


	
END
-----

I think newlisp can be a great connector for all  languages ,c php,etc
Not just use it for only 
So that
It can help me to develop faster than ever.

