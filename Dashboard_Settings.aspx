<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->

<div>    
<table class="InvisibleTable">
  <tr>
    <td>
     <div style="font-weight:bold">Default red pin settings for all <%=UserData.FirstName%> <%=UserData.LastName%>'s patients</div>           
    </td>
    <td>
   	  <%
            Dim sCommandName As String = "PatientsInfo"
            Dim dt As System.Data.DataTable
			If UserIsCounselor() Then
				dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "counselor")
			Else
				dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "admin")
			End If
			
            Dim nPatientUserID As Integer = 0 
            Dim sPatientName As String
            If (Request("PID") + "").Length > 0 Then
                nPatientUserID = Request("PID") + ""
                sPatientName = ScreenNameByID(nPatientUserID)		
        %>
       	 <div style="font-weight:bold">Default red pin settings for <%=sPatientName%></div>  
        <%Else%>
         	<div style="font-weight:bold">Select a user from drop down to view default red pin settings</div>                   
        <% End IF %>
        <br/>
        <div>
       
        <b>Select User: </b>
        <select name="PID" id="PID" onChange="ReloadSettings(this.value);">
            <option value="">Select User</option>
        <%
            For Each Row in dt.Rows
        %>
            <option value="<%=Row("UserID")%>"<% If Row("UserID") = nPatientUserID Then %> selected="selected"<% End If %>><%=Row("FirstName")%> <%=Row("LastName")%></option>
        <%
            Next
			dt.Dispose()
        %>    
        </select>
        </div>
    </td>
  <tr>
<tr>
<td>
<form name="SettingsForm" id="SettingsForm" action="Settings_Save.aspx?Type=Clinician" method="post"><br />
	<input type="hidden" name="UserID" value="<%=nUserID%>" />   
    <table class="Diff-Row-Border-Table Header-Center">
    <tr class="Black-Header-Border-Bottom"> 
        <th colspan="2" class="RightBorder">Event</th>
        <th class="RightBorder">Include as red pin</th>
        <th>Email alert</th>
        <%
			Dim bAltRow As Boolean = true
			Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReaderSP("_Dashboard_Settings","SelectUserEvents",nUserID,"counselor",0)
			If rs.hasRows() Then 
			While rs.Read()
		%>
         <% bAltRow = Not bAltRow %>
         <% If rs("RedFlagsColumn")+"" <> "" Then %>
  	 	<tr id="<%=rs("EventID")%>" <%If bAltRow Then%> class="altRow"<%End If%>>
       		
            <td colspan="2" class="RightBorder"><%=rs("EventName")%></td>
           
            <td class="RightBorder" style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>chk" name="<%=rs("EventID")%>chk" 
            <%If rs("RedPin") Then%>checked="checked" <%End If%> /></td>
            <td style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>email" name="<%=rs("EventID")%>email" 
			<%If rs("EmailAlert") Then%>checked="checked" <%End If%>/></td>
        </tr>
        <% End If %>
		 <%
         	 End While
         	 rs.Close()
			 Else
			 	rs = ExecuteReaderSP("_Dashboard_Settings","SelectEvents")
				If rs.hasRows() Then 
				While rs.Read()
		 %>
         <% bAltRow = Not bAltRow %>
         <% If rs("RedFlagsColumn")+"" <> "" Then %>
         <tr id="<%=rs("EventID")%>" <%If bAltRow Then%> class="altRow"<%End If%>>       		
       		
            <td colspan="2" class="RightBorder"><%=rs("EventName")%></td>
           
            <td class="RightBorder" style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>chk" name="<%=rs("EventID")%>chk" /></td>
            <td style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>email" name="<%=rs("EventID")%>email" /></td>
        </tr>
        <% End If %>
         <%		
				 End While
				 rs.Close()
	     	 End If
			 End If
         %>    
    </table>
    <br/>
    <table>
    <tr>
    <td style="text-align:right;">
    <span id="MsgDiv" class="alert"><%If Request("Msg")&"" <> "" Then%><%=Request("Msg")%>
    <script>
		setTimeout("document.getElementById('MsgDiv').innerHTML='';", 3000);
    </script>
    <%End If%></span>    
    </td>
    <td style="text-align:right;">
	    <input type="submit" class="Blue-Button" value="submit" onClick="validate('SettingsForm', false);return false;"/>
    </td>
    </tr>
    </table>
</form>
</td>


<!--Patient's settings-->
<td>
<form name="UsersSettingsForm" id="UsersSettingsForm" action="Settings_Save.aspx?Type=User" method="post"><br />
<input type="hidden" name="CounselorID" value="<%=nUserID%>" />   
 <input type="hidden" name="PIDHidden" id="PIDHidden" value="<%If Request("PID")&"" <> "" Then%><%=Request("PID")%><%End If%>" />
    <table class="Diff-Row-Border-Table Header-Center">
    <tr class="Black-Header-Border-Bottom"> 
        <th colspan="2" class="RightBorder">Event</th>
        <th class="RightBorder">Include as red pin</th>
        <th>Email alert</th>
        <%
			bAltRow = true
			rs = ExecuteReaderSP("_Dashboard_Settings","SelectUserEvents",nPatientUserID,"user",nUserID)
			If Not rs.HasRows Then
				rs = ExecuteReaderSP("_Dashboard_Settings","SelectUserEvents",nUserID,"counselor",0)
			End If
			If nPatientUserID <> 0 AND rs.hasRows() Then 
			While rs.Read()
		%>
         <% bAltRow = Not bAltRow %>
         <% If rs("RedFlagsColumn")+"" <> "" Then %>
  	 	<tr id="<%=rs("EventID")%>" <%If bAltRow Then%> class="altRow"<%End If%>>
       		
            <td colspan="2" class="RightBorder"><%=rs("EventName")%></td>
            
            <td class="RightBorder" style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>chk" name="<%=rs("EventID")%>chk" 
            <%If rs("RedPin") Then%>checked="checked" <%End If%> /></td>
            <td style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>email" name="<%=rs("EventID")%>email" 
			<%If rs("EmailAlert") Then%>checked="checked" <%End If%>/></td>
        </tr>
        <% End If %>
		 <%
         	 End While
         	 rs.Close()
			 Else
			 	rs = ExecuteReaderSP("_Dashboard_Settings","SelectEvents")
				If rs.hasRows() Then 
				While rs.Read()
		 %>
         <% bAltRow = Not bAltRow %>
         <% If rs("RedFlagsColumn")+"" <> "" Then %>
         <tr id="<%=rs("EventID")%>" <%If bAltRow Then%> class="altRow"<%End If%>>       		
       		
            <td colspan="2" class="RightBorder"><%=rs("EventName")%></td>
            
            <td class="RightBorder" style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>chk" name="<%=rs("EventID")%>chk" /></td>
            <td style="text-align:center;"><input type="checkbox" id="<%=rs("EventID")%>email" name="<%=rs("EventID")%>email" /></td>
        </tr>
        <% End If %>
         <%		
				 End While
				 rs.Close()
	     	 End If
			 End If
         %>    
    </table>
    <br/>
    <table>
    <tr>
    <td style="text-align:right;">
    <span id="MsgDiv1" class="alert" ><%If Request("Msg1")&"" <> "" Then%><%=Request("Msg1")%>
    <script>
		setTimeout("document.getElementById('MsgDiv1').innerHTML='';", 3000);
    </script>
    <%End If%></span>    
    </td>
    <td style="text-align:right;">
	    <input type="submit" class="Blue-Button" value="submit" onClick="validate('UsersSettingsForm', true);return false;" />
    </td>
    </tr>
    </table>
</form>
</tr>
</table>
</div>

<script type='text/javascript' src='jsInclude/jquery-1.7.2.min.js'></script>
<script>
function ReloadSettings(pid){
	document.getElementById("PIDHidden").value = pid;
	location.href="../Dashboard/Dashboard_Settings.aspx?PID="+pid;
	//return false;
}

function validate(formname, userCheck){	
	var f = document.getElementsByName(formname)[0];
	if(userCheck)
	{
		if(document.getElementById("PID").options[document.getElementById("PID").selectedIndex].value == "")
		{
			alert("please select a user");
			return false;
		}
	}
	var inputTags = f.getElementsByTagName('input');
	var checkboxCount = 0;
	var textboxCount = 0;
//	for (var i=0, length = inputTags.length; i<length; i++) {
//		 if (inputTags[i].type == 'checkbox') {
//			 if(inputTags[i].checked)
//			 	checkboxCount++;
//		 }
//	}
	$('#'+formname).find("input[type=\'checkbox\']").each(function (index) {
		if($(this)[0].checked)
			checkboxCount++;
	});
						 
	$('#'+formname).find("input[type=\'text\']").each(function (index) {																
		if(parseInt($(this)[0].value) > 0)
			textboxCount++;
	});
	//if(checkboxCount == 0)
//	{
//		alert('please make checkbox settings');
//		return false;
//	}
//	else
		f.submit();	
}
</script>
<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->
