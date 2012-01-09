<html>
<head>
<title><% (print "Newlisp fastcgi ") %> </title>
</head>
<body>
<%
(print "It works newlisp " (date) "<br />")
(print (sys-info)  )

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

