<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->

<%
	Dim sCommandName As String = "PatientsInfo"
	Dim dt As System.Data.DataTable 
	
	If UserIsCounselor() Then
		dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "counselor")
	Else
		dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "admin")
	End If
	
	Dim nPatientUserID As Integer = 0 
	Dim sPatientName As String = ""
	Dim sDataTypeCode As String = "NI"
	
	Dim dt1 As System.Data.DataTable = ExecuteDataTableSP("_Dashboard_EnterData", "GetDataTypes", 0, 0,"")
	If (Request("DataTypeCode") + "").Length > 0 Then
		sDataTypeCode = Request("DataTypeCode") + ""
	Else If dt1.Rows.Count > 0 Then'
		sDataTypeCode = dt1.Rows(0)("DataTypeCode")
	End If	
	
	If (Request("PID") + "").Length > 0 Then
		nPatientUserID = Request("PID") + ""
		sPatientName = ScreenNameByID(nPatientUserID)		
%>
<div>  <!--Main Div--> 
	<div style="font-weight:bold">Enter data for <%=sPatientName%></div>           
<%Else%>
 	<div style="font-weight:bold">Select a user from drop down to enter data</div>                   
<% End IF %>
<br/>

<div id="listDiv" class="OutLine" style="width:750px;">  <!--Form Div--> 
<form name="EnterDataForm" action="EnterData_Save.aspx" method="post"><br />
	<input type="hidden" name="CounselorID" id="CounselorID" value="<%=nUserID%>" />
    <input type="hidden" name="PIDHidden" id="PIDHidden" value="<%=nPatientUserID%>" />
    <input type="hidden" name="DTCodeHidden" id="DTCodeHidden"  value="<%=sDataTypeCode%>" />
      <table class="NoOutLine">
      <tr>
	  <td><b>Select User: </b></td>
      <td><select name="PID" id="PID" onChange="ReloadSettings(this.value);">
            <option value="">Select User</option>
        <%
            For Each Row in dt.Rows
        %>
            <option value="<%=Row("UserID")%>"<% If Row("UserID") = nPatientUserID Then %> selected="selected"<% End If %>><%=Row("FirstName") & " " & Row("LastName")%></option>
        <%
            Next
			dt.Dispose()
        %>    
        </select></td>
       </tr>
       <tr>
	    <td><b>Data Type: </b></td>
     	<td><select name="DataType" id="DataType">
        <%
            For Each Row in dt1.Rows
        %>
            <option value="<%=Row("DataTypeCode")%>"<% If Row("DataTypeCode") = sDataTypeCode Then %> selected="selected"<% End If %>><%=Row("DataType")%></option>
        <%
            Next
			dt1.Dispose()
        %>            	
        </select></td>
       </tr>
       <tr><td><b> Last Done: </b></td><td><input type="text" name="LastDone" id="LastDone" /></td></tr>
       <tr><td><b> Missed Date: </b></td><td><input type="text" name="MissedDate" id="MissedDate" /></td></tr>
       <tr><td><b> Next Date: </b></td><td><input type="text" name="NextDate" id="NextDate" /></td></tr>
       <tr><td> <b> Description: </b></td><td><textarea name="Description" id="Description" style="width:500px;"></textarea></td></tr>
     </table>
     
    <div id="MsgDiv" class="alert" style="text-align:center;"><%If Request("Msg")&"" <> "" Then%><%=Request("Msg")%>
    <script>
		setTimeout("document.getElementById('MsgDiv').innerHTML='';", 3000);
    </script>
    <%End If%></div>
    <div style="margin-left:200px;">
	    <input type="submit" class="Blue-Button" value="submit" onClick="validate();return false;"/>
    </div><br/>	
   </form>
  </div><br/>	<!--Close Form Div--> 

<% If sPatientName<> "" Then %>
 <div name="DataContent" style="width:1050px;"> <!--DataContent Div--> 
 	<div style="font-weight:bold">Data of <%=sPatientName%></div>
    <table class="Diff-Row-Border-Table Header-Center">
   	  <tr class="Black-Header-Border-Bottom"> 
        <th class="RightBorder">Data Type</th>
        <th class="RightBorder">Last Done</th>
        <th class="RightBorder">Missed Date</th>
        <th class="RightBorder">Next Date</th>   
        <th>Description</th> 
      </tr>       
        <%
			Dim bAltRow As Boolean = true
			Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReaderSP("_Dashboard_EnterData","GetData",nUserID,nPatientUserID,sDataTypeCode)
			If rs.hasRows() Then 
				While rs.Read()
		%>
         <% bAltRow = Not bAltRow %>
  	 	<tr id="tr_<%=rs("Id")%>" <%If bAltRow Then%> class="altRow"<%End If%>>       	
            <td class="RightBorder"><%=rs("DataType")%></td>   
            <td class="RightBorder"><%=rs("LastDone")%></td>
            <td class="RightBorder"><%=rs("MissedDate")%></td>
            <td class="RightBorder"><%=rs("NextDate")%></td>
            <td><%=rs("Description")%></td>                     
        </tr>
		 <%
         		 End While
         	   rs.Close()
			 Else
		 %>
         <tr class="altRow"><td colspan="4"><b>No records found</b><td></td>
         <%
			 End If
		 %>
    </table>   
  </div>	<!--Close DataContent Div--> 
 <%End If%>
</div> <!--Close Main Div--> 


<link rel="stylesheet" href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/jquery-1.10.2.js"></script>
<script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
<script>

  $(function() {
    $( "#LastDone" ).datepicker();
	$( "#MissedDate" ).datepicker();
	$( "#NextDate" ).datepicker();
  });

function ReloadSettings(pid){	
	document.getElementById("PIDHidden").value = pid;
	document.getElementById("DTCodeHidden").value = document.getElementById("DataType").options[document.getElementById("DataType").selectedIndex].value;
	location.href="../Dashboard/Dashboard_EnterData.aspx?PID="+pid+"&DataType="+
	document.getElementById("DataType").options[document.getElementById("DataType").selectedIndex].value;
}
function validate(){
	document.getElementById("DTCodeHidden").value = document.getElementById("DataType").options[document.getElementById("DataType").selectedIndex].value;
	if(document.getElementById("PID").options[document.getElementById("PID").selectedIndex].value == "")
	{
		alert("please select a user");
		return false;
	}
	else if(document.getElementById("LastDone").value == "" && 
			document.getElementById("MissedDate").value == "" && 
			document.getElementById("NextDate").value == "" && 
			document.getElementById("Description").value == "" )
	{
		alert("please enter atleast one of Last Done, Missed Date, Next Date, Description");
		return false;
	}
	else
		document.EnterDataForm.submit();
}
</script>
<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->
