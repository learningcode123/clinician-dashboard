<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<%
	Dim nUserCounselorID As Integer = 0
	Dim sMsg As String = "&Msg=Message Saved"
	Dim nPatientID As Integer = 0
	Dim sDataTypeCode As String = ""
	Dim sLastDone, sMissedDate, sNextDate, sDescription As String
	

	Int32.TryParse(Request("PIDHidden") & "", nPatientID)
	Int32.TryParse(Request("CounselorID") & "", nUserCounselorID)
	sDataTypeCode = Request("DTCodeHidden") & ""
	sLastDone = IIF(Request("LastDone") & "" <> "", Request("LastDone") & "",  Nothing)
	sMissedDate = IIF(Request("MissedDate") & "" <> "", Request("MissedDate") & "",  Nothing)
	sNextDate = IIF(Request("NextDate") & "" <> "", Request("NextDate") & "",  Nothing)
	sDescription = IIF(Request("Description") & "" <> "", Request("Description") & "",  "")
	
	Dim result As Integer = ExecuteNonQuerySP("_Dashboard_EnterData", "UpdateEnterData", nUserCounselorID,nPatientID,sDataTypeCode,sLastDone,sMissedDate,sNextDate,sDescription)
	
	If sMissedDate <> Nothing Then ' Send Email Alter to patient's Counselors	
		Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReader("SELECT UserID, Email, FirstName, LastName FROM MobileUsers WHERE UserID IN (SELECT CounselorID FROM UserCounselors WHERE UserID = " + Convert.ToString(nPatientID) + ")")
		If rs.hasRows() Then 
			Dim sEmailAddress As String = ""
			Dim gProjSenderMail As String = ""
			Dim bSendEmail As Boolean = false
			Dim MsgLink As String = PageHelper.WebsiteAddress(Me)
			Dim sEmailMsg =  ExecuteScalar("SELECT FirstName FROM MobileUsers WHERE UserID = " + Convert.ToString(nPatientID)) + " " + ExecuteScalar("SELECT LastName FROM MobileUsers WHERE UserID = " + Convert.ToString(nPatientID)) + ": " + sDescription + "<br/><a href="""+ MsgLink +"/Login/Login.aspx'>Click Here</a>"
			
			While rs.Read()
				bSendEmail = false
				If Not String.IsNullOrEmpty(rs("Email"))
					sEmailAddress = rs("Email")					
					bSendEmail = ExecuteScalar("SELECT EmailAlert FROM DashboardSettings WHERE UserID = " + Convert.ToString(nPatientID) + " AND UserCounselorID = " +  Convert.ToString(rs("UserID")) + " and EventID = (SELECT EventID FROM DashboardSettingsEvents WHERE EventShortName = '" + sDataTypeCode + "')")
					If bSendEmail Then
						SendEmailMessageHTML(sEmailAddress, gProjSenderMail, "CASA: Red Flag generated", sEmailMsg)
					End If
				End If
			End While
			rs.Close()
		End If
	End If
Response.Redirect("Dashboard_EnterData.aspx?PID=" & nPatientID & "&DataTypeCode=" & sDataTypeCode & sMsg )
%>