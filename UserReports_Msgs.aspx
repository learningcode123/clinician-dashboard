<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" Debug="false" %>

<!--#include File="~/Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="DashboardFunctions.aspx"-->

<%		
	Dim SelectedUserID As Integer
		Int32.TryParse(Request("PID"), SelectedUserID)
	oDataTable = ExecuteDataTableSP("_DashboardData", "MsgListToMe", nUserID, SelectedUserID)
	dv = oDataTable.DefaultView
	
	Dim n = 0
	Dim sFullName As String = ""
	
	For i=0 To dv.Count-1	
	n = 	n + 1	
	sFullName = FullNameByName( dv(i)("MsgFrom") )  					 
%>
  <div style="border-bottom:1px solid #DDD;">
	<span>
		 <strong><%=sFullName%></strong> on <%=Format(dv(i)("MsgDate"),"MMM dd, yyyy") & " at " & Format(dv(i)("MsgDate"),"h:mmtt")%>
	</span>   
   		 <p> <strong> Subject:</strong> <%=Server.HtmlEncode(dv(i)("Title"))%></p> 
		 <p> <strong> Message:</strong> <%=Server.HtmlEncode(dv(i)("Message"))%></p>              		 
  </div>	<!--End Inner Actual Msgs Div-->	<br/> 
 <%Next%>
 <%oDataTable.Dispose()%>
 
<% If n = 0 Then %>
	<h3 style='margin-top:80px;'>No Messages</h3>
<% End If%>