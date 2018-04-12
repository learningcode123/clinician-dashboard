<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->

<% sServiceTitle = "Dashboard Home" %>
<%
Dim nSubUserID = 0
If Request("UserID")+"" <> "" Then
	nSubUserID = Request("UserID")
End If
%>
<%
	'Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReaderSP("","List")
	Dim NumUsers As Integer = 0
	Dim StartDate As String
	Dim MaxMsgID = ExecuteScalarSP("_DashboardData", "GetMaxMsgID", 0)
%>

<div class="RightContentDiv">
<form id="DocPatientMessages" name="Patients" action="Dashboard_Patients.aspx" method="post">  
<div id="PatientMessages" class="DivOuter"> 
	<input type="hidden" id="UserID1" value="<%=nSubUserID%>" />
    <input type="hidden" id="MaxMsgID" value="<%=MaxMsgID%>" />
  
	<div id="PatientList1" class="DivInner"> 
      <h2>Messages with all of <%=UserData.FirstName%> <%=UserData.LastName%>'s patients</h2><br/>     
          
        <div id="Patients_Messages"> 
       	 	<em>Loading...</em>           
        </div>
  	</div><!-- End of PatientList1 -->    
  </div><!-- End of PatientMessages -->
</form>
</div>

<script type="text/javascript" src="../AJAX/ajax.js"></script>
<script type="text/javascript" src="../Dashboard/jsInclude/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="../Dashboard/jsInclude/SimpleModal/simplemodal.1.4.2.min.js"></script>
<link rel="stylesheet" href="../Dashboard/jsInclude/SimpleModal/simplemodal.css" />
<script type="text/javascript">
/*
** Desc:   Calls LoadMessages.aspx to load a list of patients from the DB
** Params: orderBy - column name to sort workshops by
*/

loadPatients();

function loadPatients() {	
	var s = "";
	var userID = document.getElementById("UserID1").value;
	
	$.ajax({
	  type:'get',
	  url:"../Dashboard/LoadMessages_Patients.aspx",
	  data:{data:userID},
	  success:function(r){		  
		  $('#Patients_Messages').html(r);
		  if(document.getElementById("UserID1").value == "0")
			  document.getElementById("UserID1").value = document.getElementById("UserID").value;
		  if(document.getElementById("NoOfUsers").value != "0")			  
		  	  loadMessages();
	  }
  });
}

function loadMessages() { 
	var  s="";
	var UserID=document.getElementById("UserID1").value;		
	if(UserID.length)
	{
		$("#td_"+UserID).addClass('highlighted');	
	
		var ajax = AJAXRequest("post","../Dashboard/LoadMessages.aspx?UserID="+UserID,s,updateContent,null,"MessageList");
	}
}

function ChangeHiddenValues(UserID, ele){	
	var prev_highlighted_ele = document.getElementsByClassName('highlighted');
	$(prev_highlighted_ele[0]).removeClass('highlighted');
	document.getElementById('UserID').value=UserID;
	document.getElementById('UserID1').value=UserID;
	document.getElementById('MessageList').innerHTML = "<em style=\"float:left;\"> &nbsp; &nbsp; Loading Messages...</em>";
	loadMessages();		
	$("html, body").animate({ scrollTop: 0 }, "slow");

}

/*loadmessages.aspx functions*/

function ShowReplyTextArea(replyDivID){		
	document.getElementById(replyDivID).style.display='block';	
}

function ShowWriteTextArea(writeDivID){
	document.getElementById(writeDivID).style.display='block';	
}

function Validate(threadid, tousercodename, suffix) {
	var divID = 'replyToUserDiv'+suffix;
	var msgSentDiv = 'msg-sent-status'+suffix;
	var replyTitle = document.getElementById('replyToUserTitle'+suffix).value;
	var replyText = document.getElementById('replyToUser'+suffix).value;
	replyText = trimString(replyText);
	replyTitle = trimString(replyTitle);
	if(replyTitle == ""){
		alert("\nPlease type a title.\n");
		document.getElementById('replyToUserTitle'+suffix).focus();
	}
	else
	{
		if (replyText == "") {
			alert("\nPlease type a message.\n");
			document.getElementById('replyToUser'+suffix).focus();
		} else { 	
			window.location.href="../Dashboard/Dashboard_Messages_Save.aspx?MsgTo="+tousercodename+"&Title="+replyTitle+"&Msg="+replyText;			        
		}
	}
}

function ValidateNewMsg(touserid, tousercodename){
	var divID = 'WriteToUserDiv'+touserid;
	var msgSentDiv = 'msg-sent-status'+touserid;
	var NewSubject = document.getElementById('SubjectWriteToUser'+touserid).value;
	var NewText = document.getElementById('WriteToUser'+touserid).value;
	NewText = trimString(NewText);
	NewSubject = trimString(NewSubject);
	if(NewSubject == ""){
			alert("\nPlease type a subject.\n");
			document.getElementById('SubjectWriteToUser'+touserid).focus();
		}
	 else { 
		if (NewText == "") {
			alert("\nPlease type a message.\n");
			document.getElementById('WriteToUser'+touserid).focus();
		}
		else
		{			
			window.location.href="../Dashboard/Dashboard_Messages_Save.aspx?MsgTo="+tousercodename+"&Title="+NewSubject+"&Msg="+NewText;		
		} 		        
	}
}

function trimString(str) {
    return str.replace(/^\s+/g, '').replace(/\s+$/g, ''); 
}
/*end loadmessages.aspx functions*/
 
var autoload = setInterval(function () {	
	$.ajax({
		type: "GET"	   ,
		url: "Dasshboard_Functions.aspx",
		data: 'requestString=GetMaxMsgID' ,
		contentType: "application/json; charset=utf-8",
		dataType: "text",		
		success: function(data){			
			if(data != document.getElementById('MaxMsgID').value)
			{
				document.getElementById('MaxMsgID').value = data;
				loadPatients();		
			}
		}
	});	
}, 30000);
 
</script>
<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->