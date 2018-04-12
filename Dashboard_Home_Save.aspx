<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="DashboardFunctions.aspx" -->
<%
If Request("PageName") = "Dashboard_Home" Then    
	If Request("Action") = "HideFlag" Then
		UpdateDashBoardRedFlags(PageHelper.DecodeStringToInteger(Request("PID"), -1), Request("flagType"))  
		'test.value=Request("UserId") & "   " & Request("flagType")
		Response.Redirect("Dashboard_Home.aspx")     
	Else If Request("Action") = "MsgAllPatients" Then		 
		Dim sMsg As String= (Request("MsgAllPatients")+"").Trim()
		Dim sTitle As String = "Message from counselor"
		Dim sql As String = "INSERT PrivateMessages(MsgFrom,MsgTo,Title,Message) VALUES(@MsgFrom,@MsgTo,@Title,@Message)"
		Dim nRowsAffected As Integer
        dt = cmMyPatientList(nUserID, "", False)        
        dv = dt.DefaultView
		Dim sMsgTo = ""
		Dim oMsgID As Object	
      
		If sMsg.Length > 0 Then
			For i=0 To dv.Count-1
				'Send the message to each of the users assigned to this case manager
				sMsgTo = dv(i)("CodeName")
				oMsgID = SendChessMailMessage(CodeName, "", sMsgTo,sTitle, sMsg, UserIntegerValue("UserTypeFlags"))
				
				Dim sSms As String
				Dim sMobilePhone As String = ""
				Dim sMobileNetwork As String = ""
				Dim gcmregId As String = ""
				Dim nAppVersion As Integer = 0				
				Dim sDeviceType As String = ""
				rs = GetUserRecord(sMsgTo, True)
				If rs.Read() Then					
					sMobilePhone = rs("MobilePhone")
					sMobileNetwork = rs("PhoneNetwork")
					sDeviceType = rs("DeviceType")					
					nAppVersion = rs("AppVersion")
					gcmRegID = rs("GCMRegistrationID") & ""
				End If
				rs.Close()
				
			If CanReceiveNotifications(sDeviceType, sMobilePhone, sMobileNetwork, gcmRegID, nAppVersion) Then	
            'Respect user settings for notifications
           	 Dim oSendNotification As Object = ExecuteScalar("SELECT NewMsg FROM NotificationSettings WHERE UserID = (SELECT UserID FROM MobileUsers WHERE CodeName=@CodeName)",sMsgTo)

				If (oSendNotification Is Nothing) OrElse (oSendNotification Is DBNull.Value) OrElse CType(oSendNotification,Boolean) Then
					sSMS = CodeName+" has sent you a CHESS mail. To read it, "
					
					If String.Compare(sDeviceType, "Android", True)=0 AndAlso gcmRegID.Length > 0 Then
						NotificationsHelper.SendAndroidNotification(Me,gcmRegId,"cm/ListMsgs.aspx","New CHESS mail from "+CodeName,"Click to open the message","cm",0,"achess")
					ElseIf String.Compare(sDeviceType, "iPhone", True)=0 And sMobilePhone.Length>=10 AndAlso sMobileNetwork.Length>=3 Then
						'NotificationsHelper.SendTextMessage(sMobilePhone, sMobileNetwork, gProjMail, CodeName+" has sent you a CHESS mail. Click to open My Messages: achess://cm") 
					End If              
				End If 
			End If
			
			Next
		End IF
        
        dt.Dispose()
		If oMsgID > 0 Then
	   		Response.Redirect("Dashboard_Home.aspx?MsgSent=success")   
		Else
			Response.Redirect("Dashboard_Home.aspx?MsgSent=There was a problem sending message")   
		End If
	End If
End If
%>
