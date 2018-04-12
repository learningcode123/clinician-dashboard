<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<%
	Dim nUserID As Integer
	Dim sMsg As String
	Dim nUserCounselorID As Integer = 0
	If Request("Type") = "Clinician" Then
		nUserID = Request("UserID") & ""
		sMsg = "?Msg=New Settings Saved"
	Else If Request("Type") = "User" AND (Request("PIDHidden")+"").Length > 0 Then
		Int32.TryParse(Request("PIDHidden") & "", nUserID)
		Int32.TryParse(Request("CounselorID") & "", nUserCounselorID)
		If nUserID <> 0 Then			
			sMsg = "?Msg1=New Settings Saved&PID="& nUserID
		Else
			nUserID = 0
			sMsg = "?Msg1=Please select a user"
		End If
	Else If (Request("PIDHidden")+"").Length = 0 Then		
		nUserID = 0
		sMsg = "?Msg1=Please select a user"
	End If

	If nUserID > 0 Then
	 Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReaderSP("_Dashboard_Settings","SelectEvents")
	 Dim nEventID, nWSD, nMS, nACHESSIA, nNI As Integer
	 Dim bRedPin, bEmailAlert  As Boolean
	 Dim sIncDecSuffix As String = IIF(Request("Type") = "User", "incdecTextUser", "incdecText")
	 Dim sUserType As String = IIF(Request("Type") = "User", "user", "counselor")

	 If rs.hasRows() Then 
		While rs.Read()
			nEventID = rs("EventID")
			nWSD = 0
			nMS = 0
			nACHESSIA = 0
			nNI = 0
			If rs("EventShortName") = "WSD" Then
				Int32.TryParse(IIF(Request(rs("EventID") & sIncDecSuffix)&"" <> "",Request(rs("EventID") & sIncDecSuffix),0), nWSD)
			Else If rs("EventShortName") = "ACHESSIA" Then
				Int32.TryParse(IIF(Request(rs("EventID") & sIncDecSuffix)&"" <> "",Request(rs("EventID") & sIncDecSuffix),0), nACHESSIA)
			Else If rs("EventShortName") = "NI" Then
				Int32.TryParse(IIF(Request(rs("EventID") & sIncDecSuffix)&"" <> "",Request(rs("EventID") & sIncDecSuffix),0), nNI)
			End If
			bRedPin = Convert.ToBoolean(IIF(Request(rs("EventID") & "chk")&""<>"", 1, 0))
			bEmailAlert = Convert.ToBoolean(IIF(Request(rs("EventID") & "email")&""<>"",1, 0))
			
			Dim result As Integer = ExecuteNonQuerySP("_Dashboard_Settings", "UpdateUserEvents", nUserID,sUserType,nUserCounselorID, nEventID, bRedPin, bEmailAlert, nWSD, nACHESSIA, nNI)		
		End While
		rs.Close()
	End If	
   End If
Response.Redirect("Dashboard_Settings.aspx" & sMsg)
%>