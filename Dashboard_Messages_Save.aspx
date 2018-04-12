<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" validateRequest="false"%>

<!--#include File="../Globals/Globals.aspx" -->
<% sServiceTitle = "Recovery Network" %>

<!--#include File="DashboardFunctions.aspx" -->

<%
Dim nMsgTo As Integer = 0
Dim sMsgTo, sTitle, sMsg, sql, sSMS As String
Dim sMobilePhone As String = ""
Dim sMobileNetwork As String = ""
Dim gcmregId As String = ""
Dim nAppVersion As Integer = 0
Dim nRowsAffected As Integer
Dim sDeviceType As String = ""
sMsgTo = Request("MsgTo")+""
sTitle = (Request("Title")+"").Trim().Replace("'", "''")

If sMsgTo.ToLower() = "lisa" Then
	sMsgTo = "ACHESS"
Else If sMsgTo = "" Then
	Dim nToMsgID = Request("ToMsgID")+""
	Int32.TryParse(nToMsgID, nToMsgID)
	sMsgTo = MyCodeName(nToMsgID)
End If

If sTitle.Length = 0 Then
    sTitle = "No subject"
End If

'Do not replace "'" yet - we may need to truncate it first if too long
sMsg = (Request("Msg")+"").Trim()
Dim oMsgID As Object
Dim sEmailAddress, sURL As String

If sMsg.Length > 0 And sMsgTo.Length > 0 Then
    oMsgID = SendChessMailMessage(CodeName, "", sMsgTo,sTitle, sMsg, UserIntegerValue("UserTypeFlags"))
    trace.warn("oMsgID: " & oMsgID)

    If Not (IsDbNull(oMsgID) OrElse IsNothing(oMsgID)) Then
        trace.warn("Passed If Statement")
        'Give them 5 reward points if they are not maxed out at 15 for the month
        If sTitle.IndexOf("Re: ") = 0 Then
            GiveRewardPoints(nUserID, "ChessMail", 3, 15)   'Response ear 3 points
        Else
            GiveRewardPoints(nUserID, "ChessMail", 5, 15)
        End If

        rs = GetUserRecord(sMsgTo, True)
        If rs.Read() Then
			nMsgTo = rs("UserID")
			sMobilePhone = rs("MobilePhone")
			sMobileNetwork = rs("PhoneNetwork")
			sDeviceType = rs("DeviceType")
			sEmailAddress = (rs("EMail") & "").Trim()
			nAppVersion = rs("AppVersion")
			gcmRegID = rs("GCMRegistrationID") & ""
        End If
        rs.Close()

        If CanReceiveNotifications(sDeviceType, sMobilePhone, sMobileNetwork, gcmRegID, nAppVersion) Then
            'Respect user settings for notifications
            Dim oSendNotification As Object = ExecuteScalar("SELECT NewMsg FROM NotificationSettings WHERE UserID = (SELECT UserID FROM MobileUsers WHERE CodeName=@CodeName)",sMsgTo)

            If (oSendNotification Is Nothing) OrElse (oSendNotification Is DBNull.Value) OrElse CType(oSendNotification,Boolean) Then
                sSMS = CodeName+" has sent you a CHESS mail. To read it, "
                CodeName = ""
                If UserData.ScreenName.toString() <> "" Then
                    CodeName = UserData.ScreenName.toString()
                Else
                    CodeName = UserData.CodeName.toString()
                End If
				If String.Compare(sDeviceType, "Android", True)=0 AndAlso gcmRegID.Length > 0 Then
					NotificationsHelper.SendAndroidNotification(Me,gcmRegId,"cm/ListMsgs.aspx","New CHESS mail from "+CodeName,"Click to open the message","cm",0,"achess")
				ElseIf String.Compare(sDeviceType, "iPhone", True)=0 And sMobilePhone.Length>=10 AndAlso sMobileNetwork.Length>=3 Then
					'NotificationsHelper.SendTextMessage(sMobilePhone, sMobileNetwork, gProjMail, CodeName+" has sent you a CHESS mail. Click to open My Messages: achess://cm")
				End If
            End If
		Else If sEmailAddress.Length > 0 Then
            'Respect user settings for notifications
            Dim oSendNotification As Object = ExecuteScalar("SELECT NewMsg FROM NotificationSettings WHERE UserID = (SELECT UserID FROM MobileUsers WHERE CodeName=@CodeName)",sMsgTo)

            If (oSendNotification Is Nothing) OrElse (oSendNotification Is DBNull.Value) OrElse CType(oSendNotification,Boolean) Then
				CodeName = ""
				If UserData.ScreenName.toString() <> "" Then
					CodeName = UserData.ScreenName.toString()
				Else
					CodeName = UserData.CodeName.toString()
				End If
				'Dim MsgLink As String = IIF(isChess2Server, "https://chess2.wisc.edu/achess/", "https://chess.wisc.edu/achess/")
				Dim MsgLink As String = PageHelper.WebsiteAddress(Me)
				sMsg = "Title: " + sTitle + "<p>"+sMsg.Replace(vbCRLF,"<br />")+"</p><p><a href="""+MsgLink+"CM/ShowMsg.aspx?MsgID=" & oMsgID & """>Click Here</a> to see the message</p>"
				SendEmailMessageHTML(sEmailAddress, gProjSenderMail, "New ACHESS mail message from " + CodeName, sMsg)
			End If
		End If
		If Request("from_Page") = "user_reports" Then
	        Response.Write("success")
		Else
			Response.Redirect("../Dashboard/Dashboard_Messages.aspx?UserID=" & nMsgTo, True)
		End If
    End If
End If
Response.Redirect(Request.ServerVariables("HTTP_REFERER"), True)
%>