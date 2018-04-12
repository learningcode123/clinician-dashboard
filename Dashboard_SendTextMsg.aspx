<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="DashboardFunctions.aspx" -->

<%
Dim sSenderEmail As String = ""
Dim bResult As Boolean = false
sSenderEmail = ExecuteScalar("SELECT Email FROM MobileUsers WHERE UserID=@UserID", nUserID)

If Request("TextNotification") = "0" Then 'Send Notification
	If Request("GCMRegId") & "" <> "" Then
		'This works fine - tested
		bResult = NotificationsHelper.SendAndroidNotification(Me, Request("GCMRegId"), Request("NotificationURL"), 
		"You have a message", Request("NotificationTitle"), "cm", 0, "achess")
	End If
Else If Request("TextNotification") = "1" Then 'Send Text Message
	If Request("TextMsg")&"" <> "" Then	
		bResult = NotificationsHelper.SendTextMessage(Request("PhoneNum"), Request("PhoneNetwork"), sSenderEmail, Request("TextMsg") + " achess://home")		
	End If
End If

If bResult Then
		Response.Write("Notification Message Sent")
	Else
		Response.Write("Error: Notification Message Not Sent")
End If
%>
