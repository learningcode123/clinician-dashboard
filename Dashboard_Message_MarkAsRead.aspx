<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage"%>
<!--#include File="../Globals/Globals.aspx" -->
<%
' Save the private message as read
Dim msgId As Integer = 0
If Request("msgId")+"" <> "" Then
	msgId = Request("msgId")
End If

Dim sql As String = "UPDATE PrivateMessages SET Received='1' WHERE MsgID= @MsgID"
ExecuteNonQuery(sql, msgId)
%>