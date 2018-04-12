<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage"%>
<%
	If Request("requestString") = "GetMaxMsgID"
		Response.Write(ExecuteScalarSP("_DashboardData", "GetMaxMsgID", 0))
	End If
%>
