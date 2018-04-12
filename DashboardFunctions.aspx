<% @Import Namespace=" System.Web.Script.Serialization" %>
<% @Import Namespace="System.Data" %>
<% @Import Namespace="System.Linq" %>

<script language="vb" runat="server">
Dim dt,dt1,dt2 As System.Data.DataTable
Dim dv,dv1,dv2 As System.Data.DataView
Dim nNumSettings As Integer
Dim nNumUsers, nNumUsers1 As Integer
Dim bSettings_Applied As Boolean

Dim user_redpin_info_hash As New Hashtable()
'Dim user_redpin_info_MaxDate_hash As New Hashtable()
Dim user_redpin_info_MaxDate_dict As Dictionary(Of Integer, Date) = New Dictionary(Of Integer, Date)() 

Function UpdateDashBoardRedFlags(UserID As Integer, FlagType As String)
	If FlagType = "UserVisible" Then
		ExecuteNonQuerySP("_DashboardData", "HideUser", UserID)
	Else 
		ExecuteNonQuerySP("_DashboardData", "HideFlag", UserID, 0, FlagType)	
	End If
End Function

Function GetUserRecord(nUserID)
    Return ExecuteReaderSP("_MobileUsers", "UserData", nUserID)
End Function

Function CountNewFeeds(nUserID)
    Return ExecuteScalarSP("_TeamFeedNew", nUserID, "CountTopFeeds")
End Function

Function GetCurrentFeed(nUserID As Integer, bUserReader As Boolean, sCommand As String)
    If bUserReader Then
        Return ExecuteReaderSP("_TeamFeedNew", nUserID, sCommand)
    Else
        Return ExecuteDataTableSP("_TeamFeedNew", nUserID, sCommand)
    End If
End Function

Function GetArchivedFeed(nUserID As Integer, bUserReader As Boolean, sCommand As String)
    If bUserReader Then
        Return ExecuteReaderSP("_TeamFeedNew", nUserID, sCommand)
    Else
        Return ExecuteDataTableSP("_TeamFeedNew", nUserID, sCommand)
    End If
End Function

Function IsPhotoApproved(nImageID As Integer)
    Return ExecuteScalarSP("_MyPhotosNew", 0, nImageID, "IsPhotoApproved") > 0
End Function

Function MyWallWriter(nUserID As Integer)
    Dim s1 As String = ExecuteScalar("SELECT ScreenName FROM MobileUsers WHERE UserID=@nUserID", nUserID)
    If (s1+"").Length = 0 Then
        s1 = ExecuteScalar("SELECT CodeName FROM MobileUsers WHERE UserID=@nUserID", nUserID)
    End If
    Return s1
End Function

Public Class ChartEx
	Public name As String
	Public data As New List(Of Integer)
	Public Sub New()
		me.data = New List(Of Integer)
	End Sub
End Class

Function xAxisData()
	Dim xAxis As List(Of Integer) = New List(Of Integer)()
	With xAxis
		.Add(2007)
		.Add(2008)
		.Add(2009)
		.Add(2010)
	End With
	Return xAxis
End Function

Function yAxisData(id As Integer)
	Dim yAxis As ChartEx = New ChartEx()
	With yAxis
		If id = 0 Then
			.name = "Advocates"
			.data.add(350)
			.data.add(410)
			.data.add(220)
			.data.add(450)
		ElseIf id=1 Then
			.name = "Gosnold"
			.data.add(450)
			.data.add(220)
			.data.add(410)
			.data.add(350)
		Else
			.name = "Loyola"
			.data.add(400)
			.data.add(315)
			.data.add(315)
			.data.add(400)
		End If
	End With
	Return yAxis
End Function

Function cmMyPatientList(nCounselorID As Integer, sParam As String, useReader As Boolean)
    'If useReader Then
'        Return ExecuteReaderSP("_MobileUsers", "MyPatients", nCounselorID, sParam)
'    Else
'        Return ExecuteDataTableSP("_MobileUsers", "MyPatients", nCounselorID, sParam)
'    End If
	Dim sCommandName As String = "PatientsInfo"
	If UserIsCounselor() Then
		Return ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "counselor")
	Else
		Return ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "admin")
	End If
	'Return ExecuteDataTableSP("_DashboardData", "PatientsInfo", 0)
End Function

Function CheckRedFlagSetting(oDataView As System.Data.DataView, sColumnName As String)
	Dim settingsQuery = From rowView As System.Data.DataRowView In oDataView Where rowView.Row.Item("RedFlagsColumn") = sColumnName			
	Return settingsQuery(0)("RedPin")	
End Function

Function ApplySettings_RedFlags(ByRef oDataTable_RedFlags As System.Data.DataTable, nUserID As Integer, redFlagValue_Check As Integer)
	Dim oDataTable As System.Data.DataTable = ExecuteDataTableSP("_Dashboard_Settings", "SelectUserEvents", nUserID, "counselor", 0)
	Dim oDataView As System.Data.DataView = oDataTable.DefaultView
	Dim rs As System.Data.SqlClient.SqlDataReader
	Dim subquery1_table As System.Data.DataTable
	
	bSettings_Applied = false
	nNumSettings = oDataTable.Rows.Count	
	If nNumSettings > 0 Then
		bSettings_Applied = true
	End If
	
	Dim oDataTableUser As System.Data.DataTable
	Dim oDataViewUser As System.Data.DataView
	
	Dim filterUser As Boolean = false
	Dim conditionCheck As Boolean = false
	Dim subquery1 As String = ""	
	
	
	 For Each Row in oDataTable_RedFlags.Rows	'Looping through red flag users
	 	
	 	oDataTableUser = ExecuteDataTableSP("_Dashboard_Settings", "SelectUserEvents", Row("UserID"), "user", nUserID)
		filterUser = false
		conditionCheck = false
		
		If oDataTableUser.Rows.Count > 0 Then 'Check if there are user settings for this Counselors
			filterUser = true
			oDataViewUser = oDataTableUser.DefaultView 
			If bSettings_Applied = false Then
				'nNumSettings = oDataTableUser.Rows.Count	
				bSettings_Applied = true
			End If  
		End If
		
		Dim user_redpin_info_table As New System.Data.DataTable
		rs = ExecuteReaderSP("_Dashboard_Settings","GetRedFlagColumns")
		If rs.hasRows() Then 'Check If RedFlag Column Names are present
			user_redpin_info_table.Clear()	
			While rs.Read()	'Looping through RedFlag Column Names
				
				If filterUser Then 	'If there are user settings for this Counselor
					If Row(rs("RedFlagsColumn")) = redFlagValue_Check AND CheckRedFlagSetting(oDataViewUser, rs("RedFlagsColumn")) Then
							Row(rs("RedFlagsColumn")) = redFlagValue_Check					
					Else
						Row(rs("RedFlagsColumn")) = 0
					End If				
				Else If nNumSettings > 0 Then	 'If there are NO user settings for this Counselor, then apply Counselor settings
					If Row(rs("RedFlagsColumn")) = redFlagValue_Check AND CheckRedFlagSetting(oDataView, rs("RedFlagsColumn")) Then	
						Row(rs("RedFlagsColumn")) = redFlagValue_Check						
					Else
						Row(rs("RedFlagsColumn")) = 0
					End If					
				End If
					
				If Row(rs("RedFlagsColumn")) = redFlagValue_Check Then	'If the flag is ON for the user bring it's information to be shown on UI					
				'subquery1 = Row("UserID")
					subquery1 = "SELECT TOP 1 arp.redpin_date, arp.redpin_type,arp.redpin, (CASE WHEN arp.redpin_type LIKE '%WSD%' THEN (SELECT  TOP 1 dss.Score FROM DashboardSurveyScores dss WHERE dss.UserID=arp.user_id AND dss.EntryID = arp.real_id ORDER BY dss.SurveyID DESC) ELSE 0 END) AS score from allredpins arp WHERE arp.redpin=1 AND arp.user_id = " + Convert.ToString(Row("UserID")) + " AND arp.redpin_type LIKE '%' + (SELECT EventShortName from DashboardSettingsEvents where RedFlagsColumn = '" + rs("RedFlagsColumn")+ "') + '%' ORDER BY arp.id DESC"					
					subquery1_table = ExecuteDataTable(subquery1)
					If subquery1_table.Rows.Count > 0 Then
						'user_redpin_info_table.Rows.Add(subquery1_table.Rows(0))
						If user_redpin_info_table.Rows.Count = 0 Then
							user_redpin_info_table = subquery1_table.Clone
						End If
						user_redpin_info_table.ImportRow(subquery1_table.Rows(0))						
					End If
				End If	'If the flag is ON for the user bring it's information to be shown on UI
			 
			End While	'Looping through RedFlag Column Names
         	rs.Close()
		End If 'Check If RedFlag Column Names are present
		
		If user_redpin_info_table.Rows.Count > 0 Then
			Row("RedFlag_Final") = 1
			user_redpin_info_table = SortDataTable(user_redpin_info_table, "redpin_date")
			user_redpin_info_hash.Add(Row("UserID"), user_redpin_info_table)	
				
			user_redpin_info_MaxDate_dict.Add(CType(Row("UserID"), Integer), CType(user_redpin_info_table.Rows(0)("redpin_date"), Date))
		End If			
     Next	'Looping through red flag users
	 	 
	 If user_redpin_info_MaxDate_dict.Count > 0 Then
		 Dim sorted = From pair In user_redpin_info_MaxDate_dict Order By pair.Value Descending
		 user_redpin_info_MaxDate_dict = sorted.ToDictionary(Function(p) p.Key, Function(p) p.Value)
	 End If
	 		
	'Delete rows that are filtered out after applying settings	
	Dim result() As System.Data.DataRow = oDataTable_RedFlags.Select("RedFlag_Final = 0")	
	For Each row As System.Data.DataRow In result
	    row.Delete()
	Next
	oDataTable_RedFlags.AcceptChanges()
				  
	 Return oDataTable_RedFlags
End Function

Function SortDataTable(table As System.Data.DataTable, ParamArray columns As String()) As System.Data.DataTable
    If columns.Length = 0 Then
        Return table
    End If

    Dim firstColumn = columns.First()

    Dim result = table.AsEnumerable().OrderByDescending(Function(r) r(firstColumn))

    For Each columnName As String In columns.Skip(1)
        result = result.ThenBy(Function(r) r(columnName))
    Next

    Return result.AsDataView().ToTable()

End Function

Function GetRedpinColumn_Code(redflagColumn)
	Return ExecuteScalar("SELECT EventShortName FROM DashboardSettingsEvents WHERE RedFlagsColumn='"+ redflagColumn +"'")
End Function

Function SendEmailAlert_InactiveUsers()
	Dim InActivityEmailSent_RecordCount As Integer = ExecuteScalarSP("InActivityEmail_Proc", "GetInAct_ES_Count")
	If InActivityEmailSent_RecordCount = 0 Then
		ExecuteScalarSP("InActivityEmail_Proc", "InsertInAct_ES")		
		UpdateAllUsersInactivity()
	Else
		Dim InActivityEmailSent_Row AS System.Data.DataTable = ExecuteDataTableSP("InActivityEmail_Proc", "GetFirstRecord")
		If (InActivityEmailSent_Row.Rows.Count > 0 And (InActivityEmailSent_Row.Rows(0)("date_sent").ToShortDateString() <> DateTime.Now.ToShortDateString())) Then						
			ExecuteScalarSP("InActivityEmail_Proc", "UpdateInAct_ES", InActivityEmailSent_Row.Rows(0)("id").ToString())						
			InActivityEmailSent_Row.Dispose()
			UpdateAllUsersInactivity()
		End If
	End If
End Function

Function UpdateAllUsersInactivity()
		'Dim InActiveUsers_Table AS System.Data.DataTable = ExecuteDataTable("SELECT UserID FROM DashboardRedFlags WHERE UserVisible = 1 AND InactiveUser = 1 AND DateDiff(d, UpdatedOn, GETDATE()) = 0")
		Dim InActiveUsers_Table AS System.Data.DataTable = ExecuteDataTable("SELECT UserID FROM DashboardRedFlags WHERE UserVisible = 1 AND InactiveUser = 1")
		
		Dim InActivity_Status_User_Count As Integer
		Dim nUserID_Tmp As Integer
		Dim ISU_ID As Integer 		
		
		For i=0 To InActiveUsers_Table.Rows.Count-1
			nUserID_Tmp = InActiveUsers_Table.Rows(i)("UserID")	
			InActivity_Status_User_Count = 0
			InActivity_Status_User_Count = ExecuteScalarSP("InActivityEmail_Proc", "GetInAct_SU_Count", nUserID_Tmp.ToString())						
			If InActivity_Status_User_Count > 0 AND ExecuteScalarSP("InActivityEmail_Proc", "GetInAct_SU_Count_0_0", nUserID_Tmp.ToString()) > 0 Then
				ExecuteScalarSP("InActivityEmail_Proc", "UpdateInAct_SU", nUserID_Tmp.ToString())
				ISU_ID = ExecuteScalarSP("InActivityEmail_Proc", "SelectInAct_SU", nUserID_Tmp.ToString())
				ExecuteNonQuerySP("AllRedPins_Proc", "InsertUser_Type_Count", nUserID_Tmp.ToString(), ISU_ID.ToString(), "ACHESSIA")	
				SendEmail(nUserID_Tmp)	
			Else If InActivity_Status_User_Count = 0 Then
				ExecuteScalarSP("InActivityEmail_Proc", "InsertInAct_SU", nUserID_Tmp.ToString())
				ISU_ID = ExecuteScalarSP("InActivityEmail_Proc", "SelectInAct_SU", nUserID_Tmp.ToString())
				ExecuteNonQuerySP("AllRedPins_Proc", "InsertUser_Type_Count", nUserID_Tmp.ToString(), ISU_ID.ToString(), "ACHESSIA")	
				SendEmail(nUserID_Tmp)	
			End If
			
			'IF ExecuteScalarSP("AllRedPins_Proc", "GetUser_Type_Count", nUserID_Tmp.ToString(), "", "ACHESSIA") > 0 Then
'				ExecuteNonQuerySP("AllRedPins_Proc", "UpdateUser_Type_Count", nUserID_Tmp.ToString(), ISU_ID.ToString(), "ACHESSIA")				
'			Else
'				ExecuteNonQuerySP("AllRedPins_Proc", "InsertUser_Type_Count", nUserID_Tmp.ToString(), ISU_ID.ToString(), "ACHESSIA")					
'			End If
		Next i		
End Function
    
Function SendEmail(nUserID As Integer)
		Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReader("SELECT UserID, Email, FirstName, LastName FROM MobileUsers WHERE UserID IN (SELECT CounselorID FROM UserCounselors WHERE UserID = " + Convert.ToString(nUserID) + ")")
		If rs.hasRows() Then 
			Dim sEmailAddress As String = ""
			Dim gProjSenderMail As String = ""
			Dim bSendEmail As Boolean = false
			Dim sDataTypeCode As String = "ACHESSIA"
			Dim sDescription As String = "has been inactive"
			Dim MsgLink As String = PageHelper.WebsiteAddress(Me)
			Dim sEmailMsg =  ExecuteScalar("SELECT FirstName FROM MobileUsers WHERE UserID = " + Convert.ToString(nUserID)) + " " + ExecuteScalar("SELECT LastName FROM MobileUsers WHERE UserID = " + Convert.ToString(nUserID)) + ": " + sDescription + "<br/><a href="""+MsgLink+"/Login/Login.aspx'>Click Here</a>"
			
			While rs.Read()
				bSendEmail = false
				If Not String.IsNullOrEmpty(rs("Email"))
					sEmailAddress = rs("Email")					
					bSendEmail = ExecuteScalar("SELECT EmailAlert FROM DashboardSettings WHERE UserID = " + Convert.ToString(nUserID) + " AND UserCounselorID = " +  Convert.ToString(rs("UserID")) + " and EventID = (SELECT EventID FROM DashboardSettingsEvents WHERE EventShortName = '" + sDataTypeCode + "')")
					If bSendEmail Then
						SendEmailMessageHTML(sEmailAddress, gProjSenderMail, "CASA: Red Flag generated", sEmailMsg)
					End If
				End If
			End While
			rs.Close()
		End If

End Function


Function ApplySettings_UserReports(ByRef dt As System.Data.DataTable, nUserID As Integer)
	Dim oDataTable As System.Data.DataTable = ExecuteDataTableSP("_Dashboard_Settings", "SelectUserEvents", nUserID, "counselor", 0)
	Dim oDataView As System.Data.DataView = oDataTable.DefaultView
	Dim rs As System.Data.SqlClient.SqlDataReader
	Dim subquery1_table As System.Data.DataTable
	
	bSettings_Applied = false
	nNumSettings = oDataTable.Rows.Count	
	If nNumSettings > 0 Then
		bSettings_Applied = true
	End If
	
	Dim oDataTableUser As System.Data.DataTable
	Dim oDataViewUser As System.Data.DataView
	
	Dim filterUser As Boolean = false
	Dim conditionCheck As Boolean = false
	Dim subquery1 As String = ""	
	Dim Applied_users_hash As New List(Of Integer)
							
	For Each Row in dt.Rows	'Looping through user reports info	
		 'If Not Applied_users_hash.Contains(Row("UserID")) Then
			oDataTableUser = ExecuteDataTableSP("_Dashboard_Settings", "SelectUserEvents", Row("UserID"), "user", nUserID)
			filterUser = false
			conditionCheck = false
									
			If oDataTableUser.Rows.Count > 0 Then 'Check if there are user settings for this Counselors								
				filterUser = true
				oDataViewUser = oDataTableUser.DefaultView 
				If bSettings_Applied = false Then
					'nNumSettings = oDataTableUser.Rows.Count	
					bSettings_Applied = true
				End If  
			End If
						
			'Dim userreports_info_table As New System.Data.DataTable
			rs = ExecuteReaderSP("_Dashboard_Settings","Get_RFColumns_ESN")			
			If rs.hasRows() Then 'Check If RedFlagsColumn, EventShortName are present
				'user_redpin_info_table.Clear()					
				While rs.Read()	'Looping through RedFlagsColumn, EventShortName					
					If filterUser Then 	'If there are user settings for this Counselor					
						If Row("redpin_type").Contains(rs("EventShortName")) AND CheckRedFlagSetting(oDataViewUser, rs("RedFlagsColumn")) Then
								Row("RedFlagsColumn") = 1		
								Exit While
						Else	
							Row("RedFlagsColumn") = 0
							
						End If				
					Else If nNumSettings > 0 Then	 'If there are NO user settings for this Counselor, then apply Counselor settings				
						If Row("redpin_type").Contains(rs("EventShortName")) AND CheckRedFlagSetting(oDataView, rs("RedFlagsColumn")) Then								
							Row("RedFlagsColumn") = 1		
							Exit While				
						Else
							Row("RedFlagsColumn") = 0
							
						End If					
					Else
						Row("RedFlagsColumn") = 0
					End If					
					
				End While	'Looping through RedFlagsColumn, EventShortName
				rs.Close()
			End If 'Check If RedFlagsColumn, EventShortName are present
			'Applied_users_hash.Add(Row("UserID"))	
		'End If
     Next	'Looping user reports info
	
	'Commenting out delete operation. All records should be present	
	'Delete rows that are filtered out after applying settings	
'	Dim result() As System.Data.DataRow = dt.Select("RedFlagsColumn = 0")	
'	For Each row As System.Data.DataRow In result
'	    row.Delete()
'	Next
	dt.AcceptChanges()
				  
	Return dt
End Function

</script>
