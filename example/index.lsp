<%
;	(module "web.lsp")
	(Web:send-headers)
%>
<html>
<head>
<title><% (print "Title damn it") %> </title>
</head>
<body>
<%
(print (string "It works newlisp " (date) "<br />"))
(print (string (sys-info) ) )

%>
<form action="#">
	<input name="name" value="" /> <br />
	<input name="pass" value="" /> <br />
	<input name="sub" type="submit" value="sub" /> <br />
</form>
<%
	(println "<br /> here is:<br />")
	(print "<br/> QUERY_STRING is<br />")

	(print (env "QUERY_STRING"))

%>
</body>
</html>

