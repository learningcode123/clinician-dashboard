<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#include File="DashboardFunctions.aspx" --> 
<!-- Called ajaxically to load a list of users for Users.aspx -->

<%
Dim oDataTable_RedFlags As System.Data.DataTable
If UserIsCounselor() Then
	oDataTable_RedFlags = ExecuteDataTableSP("_DashboardData","GetRedFlags", nUserID, 0 , "counselor")
Else
	oDataTable_RedFlags = ExecuteDataTableSP("_DashboardData","GetRedFlags", nUserID, 0 , "admin")
End If

SendEmailAlert_InactiveUsers() ' Send EmailAlert to all inactive users
nNumUsers = oDataTable_RedFlags.Rows.Count

If nNumUsers > 0 Then	'Apply Settings to RedFlagUsers
	oDataTable_RedFlags = ApplySettings_RedFlags(oDataTable_RedFlags, nUserID, 1)
End If
nNumUsers1 = oDataTable_RedFlags.Rows.Count

Dim StartDate As String
Dim sFullName As String = ""
Dim sCodeName As String = ""
Dim UserIssues As String = ""
Dim nPhotoID As Integer = 0
Dim User_Shown As Boolean = false
%>

 <div class="form-item">
  <table id="documentTable" class="Diff-Row-Border-Table" style="font-size:1.1em;">
  <%
  	If nNumUsers > 0 And bSettings_Applied = false Then
  %>
   		  <h3>Please make settings to view red pin users.</h3>  
  <%
 	Else If nNumUsers1 > 0 Then		
  %>
  <%
  		Dim userid_key As Integer 
  		Dim bAltRow As Boolean = True
		Dim redpinColumn_Code As String
		Dim redpin_Row As System.Data.DataRow	
		For Each kvp As KeyValuePair(Of Integer, Date) In user_redpin_info_MaxDate_dict
			 UserIssues = ""
			 userid_key = kvp.Key  
			 Dim Row As System.Data.DataRow = oDataTable_RedFlags.Select("UserID = " + Convert.ToString(userid_key)).FirstOrDefault()
			 sCodeName = Row("CodeName")
			 sFullName = Row("FirstName") & " " & Row("LastName")			 
			 nPhotoID = Row("ImageID")
			 Dim user_redpin_info_table As System.Data.DataTable  = user_redpin_info_hash(userid_key)
			 			 
			 If Row("SurveyScore") = 1 Then 'BAM Score Decline			
			 		redpinColumn_Code = GetRedpinColumn_Code("SurveyScore")			 		
					redpin_Row = (From r In user_redpin_info_table Where r.Field(Of String)("redpin_type").Contains(redpinColumn_Code) Select r).FirstOrDefault()
					If redpin_Row IsNot Nothing Then
						UserIssues &= "<tr><td>BAM Score: " & redpin_Row("score") & " on " & Format(redpin_Row("redpin_date"), "MM/dd/yyyy") & _
								"	&nbsp;<span class='Link' onclick='ShowWeeklySurveySummaryPopUp("& Row("UserID") & ");'>see recent survey scores</span> " & _
								"<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
								"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) & """, ""BAM"");'/></td></tr>"	
					End If							
			End If
			
			If Row("MedicationSurvey") = 1 Then 'Medication Survey	
			 		redpinColumn_Code = GetRedpinColumn_Code("MedicationSurvey")		
					redpin_Row = (From r In user_redpin_info_table Where r.Field(Of String)("redpin_type").Contains(redpinColumn_Code) Select r).FirstOrDefault()
					If redpin_Row IsNot Nothing Then
						UserIssues &= "<tr><td>Has not taken all Medications on " & Format(redpin_Row("redpin_date"), "MM/dd/yyyy") & _								
								"<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
								"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) & """, ""MS"");'/></td></tr>"	
					End If							
			End If
			
			If Row("InactiveUser2") = 1 Then	'InActive User
				redpinColumn_Code = GetRedpinColumn_Code("InactiveUser2")			 		
				redpin_Row = (From r In user_redpin_info_table Where r.Field(Of String)("redpin_type").Contains(redpinColumn_Code) Select r).FirstOrDefault()
				If redpin_Row IsNot Nothing Then
					UserIssues &= "<tr><td>Has not used ACHESS since " & DateTime.Parse(redpin_Row("redpin_date")).ToString("MM/dd/yyyy")              
								
					If (Row("MobilePhone") & "").Length > 0 Then    
					Dim SemdTxtMsgStr As String = "'SendTextMsg("""& PageHelper.EncodeIntegerToString(Row("UserID")) &""", """& Row("CodeName") & _
					  """, """& Row("ScreenName") &""", """& Row("FirstName") &""", """& Row("MobilePhone") & _
					  """, """& Row("DeviceType") &""", """& Row("PhoneNetwork") &""", """& Row("GCMRegistrationID") &""");'"
								   
					  UserIssues &= ". ( Call: "& Row("MobilePhone") &", <a href='#' onclick="& SemdTxtMsgStr &">Notification " & _
					  "<img src='../images/admin/icon-sms.jpg' border='0' onclick="& SemdTxtMsgStr &"></img></a> )"
					End If 	
					UserIssues &= "<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
								"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) &""", ""Inactive"");'/></td></tr>"	
				End If				
			 End If
				
			 If Row("DidUse") = 1 Then	'Used alcohol or drugs			 
					redpinColumn_Code = GetRedpinColumn_Code("DidUse")				
					redpin_Row = (From r In user_redpin_info_table Where r.Field(Of String)("redpin_type").Contains(redpinColumn_Code) Select r).FirstOrDefault()
					
					If redpin_Row IsNot Nothing Then
						UserIssues &= "<tr><td>Used drugs or alcohol on " & DateTime.Parse(redpin_Row("redpin_date")).ToString("MM/dd/yyyy") & _
									"<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
									"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) &""", ""AOD"");'/></td></tr>"		
					End If					
			 End If
			 
			 If Row("NaltroxoneInjection") = 1 Then	'Missed Naltrexone Injection	
			 		redpinColumn_Code = GetRedpinColumn_Code("NaltroxoneInjection")				
			 		redpin_Row = user_redpin_info_table.Select("redpin_type = '" + redpinColumn_Code + "'").FirstOrDefault()				
					If redpin_Row IsNot Nothing Then
						UserIssues &= "<tr><td>Missed Naltrexone Injection on " & If(IsDBNull(redpin_Row("redpin_date")), "(date unknown)", Format(redpin_Row("redpin_date"), "MM/dd/yyyy")) & _
									"<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
									"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) &""", ""NI"");'/></td></tr>"
					End If
			End If
			
			If Row("ERVisit") = 1 Then	'ERVisit	
					redpinColumn_Code = GetRedpinColumn_Code("ERVisit")				
			 		redpin_Row = user_redpin_info_table.Select("redpin_type = '" + redpinColumn_Code + "'").FirstOrDefault()					
					If redpin_Row IsNot Nothing Then
						UserIssues &= "<tr><td>Emergency Room Visit on " & If(IsDBNull(redpin_Row("redpin_date")), "(date unknown)", Format(redpin_Row("redpin_date"), "MM/dd/yyyy")) & _
									"<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
									"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) &""", ""ERV"");'/></td></tr>"
					End If						
			End If
				
			If Row("Arrest") = 1 Then	'Arrest		
					redpinColumn_Code = GetRedpinColumn_Code("Arrest")				
			 		redpin_Row = user_redpin_info_table.Select("redpin_type = '" + redpinColumn_Code + "'").FirstOrDefault()								
					If redpin_Row IsNot Nothing Then
						UserIssues &= "<tr><td>Arrest occurred on " & If(IsDBNull(redpin_Row("redpin_date")), "(date unknown)", Format(redpin_Row("redpin_date"), "MM/dd/yyyy")) & _
									"<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
									"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) &""", ""ARR"");'/></td></tr>"
					End If
			End If
			
			If Row("DetoxAdmission") = 1 Then	
					redpinColumn_Code = GetRedpinColumn_Code("DetoxAdmission")				
			 		redpin_Row = user_redpin_info_table.Select("redpin_type = '" + redpinColumn_Code + "'").FirstOrDefault()							
					If redpin_Row IsNot Nothing Then
						UserIssues &= "<tr><td>DetoxAdmission on " & If(IsDBNull(redpin_Row("redpin_date")), "(date unknown)", Format(redpin_Row("redpin_date"), "MM/dd/yyyy")) & _
									"<img src='../Images/Admin/icon-delete.png' alt='Check Off' style='cursor:pointer;'"& _
									"onclick='HideFlag("""& PageHelper.EncodeIntegerToString(Row("UserID")) &""", ""DA"");'/></td></tr>"
					End If								
			End If					
  %> 
     <% bAltRow = Not bAltRow %>
     <tr <%If bAltRow Then%> class="altRow"<%End If%>>
         <%If nPhotoID = 0 Then%>
            <td class="Profile-Photo" width="15%">
            
            <!--Displays no profile pic-->
            <div id="left">
            
            <div class="profileBox">
                
                <div class="profileContent-noImage ">
                <a href="UserReports.aspx?PID=<%=PageHelper.EncodeIntegerToString(Row("UserID"))%>">
                    <img src="../Images/Users/no-img-vert.gif" border="0" title="No Photo" alt="No Photo" />
                </a> 
                <span class="redpin_bck"></span>
                </div>
                
             </div>
                
                                               
            </div> 
            
            </td>              
         <%Else%>
            <td class="Profile-Photo" width="15%">
            
            <!--Displays profile pic-->
            <div id="left"> 
              
            <div class="profileBox">
                <div class="profileContent">                 
                <a href="UserReports.aspx?PID=<%=PageHelper.EncodeIntegerToString(Row("UserID"))%>">
                    <img src="../MyPhotos/LoadImage.aspx?GUID=<%=PageHelper.EncodeIntegerToString(Row("UserID"))%>&thn=1&IID=
                    <%=PageHelper.EncodeIntegerToString(nPhotoID)%>" border="0" title="<%=sCodeName%>" alt="<%=sCodeName%>"/>
                </a>
                <span class="redpin_bck"></span>                                    
            </div>
            </div>
            
            </div>
            
            </td>                  
         <%
            nPhotoID = 0
            End If
         %>
                      
       <td>
          <table class="patientsList">
            <th style="font-weight:bold;text-align:left;padding:0;">
              <%=sFullName%>
            </th>                              
          <%=UserIssues%>   
         </table>        
         </td>           
    </tr>          
       
          
    
	<%
		Next
	 	oDataTable_RedFlags.Dispose()
    Else If nNumUsers = 0 Then
	%>
     	  No users were found.
    <%
	Else If nNumSettings > 0 Then
	%>
          Users Filtered out after applying settings.
    <%
	End If 	
    %>
    </table>
    <div id="modal-content">
    </div>
  </div>

<script language="vb" runat="server">
'Checks if a value is DBNull or Nothing and returns "" if it is, else returns value as string
Function CheckDBNull(DataString As Object, Optional UseNBSP As Boolean = False) As String
	If DataString Is Nothing OrElse DataString Is DBNull.Value OrElse DataString.ToString().Length = 0 Then
		Return IIF(UseNBSP,"&nbsp;","")
	Else
		Return DataString.ToString()
	End If
End Function
</script>