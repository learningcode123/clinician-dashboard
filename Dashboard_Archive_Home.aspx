<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->

<% sServiceTitle = "Dashboard Archive Home" %>
<%
	Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReaderSP("","List")
	Dim NumUsers As Integer = 0
	Dim StartDate As String
%>

<div class="RightContentDiv">
<form id="RedFlagUsers" name="RedFlagUsers" action="Dashboard_Home_Save.aspx" method="post">  
  <div>
 	 <h1>Manage Clinicain Dashboard - Archived Users</h1>
      <div id="MsgDiv" class="alert">
      <%If Request("MsgSent")&"" <> "" Then%><%=Request("MsgSent")%>
       <script>
            setTimeout("document.getElementById('MsgDiv').innerHTML='';", 3000);
        </script>
       <%End If%>
      </div>  
  </div>
  <br/>
  <div id="UserList">
    <em>Loading Users...</em>
  </div> 
   <a href="Dashboard_Home.aspx">Back to Home</a>
</form>
</div>

<script type='text/javascript' src='jsInclude/jquery-1.7.2.min.js'></script>
<script type='text/javascript' src='jsInclude/SimpleModal/simplemodal.1.4.2.min.js'></script>
<link rel="stylesheet" href="jsInclude/SimpleModal/simplemodal.css" />

<script type="text/javascript" src="../AJAX/ajax.js"></script>
<script type="text/javascript">
function SendTextMsg(ToUserID, CodeName, ScreenName, FirstName, MobilePhone, DeviceType, PhoneNetwork, GCMRegId){
	$('#modal-content').modal({overlayClose:true});
		$.ajax({
			url: 'Dashboard_TextMsg.aspx',
			data: 'PID='+ ToUserID +'&CodeName='+ CodeName+'&ScreenName='+ ScreenName+'&FirstName='+ FirstName
			+'&MobilePhone='+ MobilePhone +'&DeviceType='+ DeviceType +'&PhoneNetwork='+ PhoneNetwork+ '&GCMRegId='+GCMRegId,
			success: function(result,status,xhr) {
				$('#modal-content').html (result);
			},
			error: function(xhr,status) {
				alert ('ERROR loading page\n'+status+' '+xhr.statusText);
			}
		});		
		return false;
}

/*
** Desc:   Calls LoadRedFlagUsers.aspx to load a list of user from the DB
*/
function loadRedFlagUsers(orderBy) {    
var  s="";
    var ajax = AJAXRequest("post","../Dashboard/ArchivedRedFlagUsers.aspx",s,updateContent,null,"UserList");
}


loadRedFlagUsers("");

var txtContent  = document.getElementById("MsgAllPatients");
// Set our default text
var defaultText = "Write to all of your patients here...";
// Set default state of input
txtContent.value = defaultText;
//txtContent.style.color = "#CCC";

txtContent.onfocus = function() {
  // If the current value is our default value
  if (this.value == defaultText) {
    // clear it and set the text color to black
    this.value = "";
    this.style.color = "#000";
  }
}
// Apply onblur logic
txtContent.onblur = function() {
  // If the current value is empty
  if (this.value == "") {
    // set it to our default value and lighten the color
    this.value = defaultText;
    //this.style.color = "#CCC";
  }
}


function Validate() {
    var f = document.RedFlagUsers;   
    MsgAllPatients.value=trimString(MsgAllPatients.value+"");
    if (MsgAllPatients.value == "" ||  (MsgAllPatients.value == defaultText) ) {
        alert("\nPlease type a message.\n");
        MsgAllPatients.focus();
    } else {  
		f.action += '?PageName=Dashboard_Home&Action=MsgAllPatients';           
		f.submit();
	}
}

function trimString(str) {
    return str.replace(/^\s+/g, '').replace(/\s+$/g, ''); 
}
function ShowWeeklySurveySummaryPopUp(userid){
var data = new Object();
data['PID'] = userid;
$.get('WSList.aspx', data, function(msg) {
		$('#modal-content').html (msg);
		$('#modal-content').modal({overlayClose:true,
		onClose: function() {
           $.modal.close();
		   $('#modal-content').html (''); 
       }
	  });
	});					
	return false;
}
</script>
<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->