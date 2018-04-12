<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="DashboardFunctions.aspx"-->

<%
Dim nPatientID As Integer= Request("PID")& ""
Dim nSiteID As Integer = 30

If Not UserIsSuperAdmin Then
    nSiteID = UserIntegerValue("SiteID")
End If

sServiceTitle = "Weekly Survey - Check-in Report" 

%>

<div class="alert"><%=Request("Msg") & ""%></div>

<form autocomplete="off" id="cmForm" name="cmForm" action="WSList.aspx" method="post" onSubmit="return false;"> 
<h1><%=sServiceTitle%></h1>
<%

Dim bSendNotification As Boolean = False
dt2 = ExecuteDataTableSP("_WeeklySurveyData", "GetUserWeeklySurveyDataDesc", nPatientID)
dv2 = dt2.DefaultView

Dim sPostedOn As String
Dim sToday As String = Format(Now, "M/d/yyyy")

'Dim bUserNotified As Boolean = (ExecuteScalarSP("_WeeklySurveyData", "GetUsersNotifiedToday", nSiteID) > 0)
'
'If bUserNotified Then
'    bSendNotification = False
'End If
%>

<%'If bSendNotification Then%>
    <!--  <p><button type="button" onClick="confirmReminders();">
          Remind Patients to Complete their Surveys
      </button></p>-->
<%'Else%>
    <!--  <p><span style="color:#338033;">Notifications Sent Today</span></p>-->
<%'End If%>
</form>

<h3><font color="#006699">Check-in Status for <%=FullNameByID(nPatientID)%></font></h3>

<table id="wsSummaryTable" class="Border-Table WhiteTable">
<tr> 
  <th>Check-in Date</th>
  <th>Score</th>
</tr>

<%
Dim bNotify As Boolean
If dv2.Count > 0 Then
	For i=0 To dv2.Count-1
%>
	  <tr <% If i Mod 2 = 1 Then %>class="altRow"<% End If %>>	
		<td><%=Format(dv2(i)("PostedOn"), "M/d/yyyy")%></td>  
		<td>&nbsp; <%=dv2(i)("Score")%></td>  
	 </tr>
<%
Next
Else
%>
	 <tr>
        <td colspan="4"><h3>No Records found</h3></td>        
     </tr>
<%
End If
%>
</table>

<%
dt2.Dispose()
%>

<script type="text/javascript">
function confirmReminders() {
    if (confirm("Are you sure you want to remind all patients who haven't completed their surveys?")) {
        window.location.href="../Admin/WSNotify.aspx?SiteID=<%=PageHelper.EncodeIntegerToString(nSiteID)%>&GUID=<%=PageHelper.EncodeIntegerToString(nPatientID)%>";
        return true;
    }
    return false;
}
</script>
