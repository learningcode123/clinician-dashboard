<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="../Globals/Globals.aspx" --> 
<%
Dim sCodeName As String = ""
Dim sPhoneNum As String = ""
Dim sScreenName As String = ""
Dim sDeviceType As String = ""
Dim sPhoneNetwork As String = ""
Dim nPatientID As Integer
Dim sGCMRegId As String

sCodeName = Request("CodeName")
sScreenName = Request("ScreenName")
sPhoneNum = Request("MobilePhone")
sDeviceType = (Request("DeviceType") & "").ToLower()
sPhoneNetwork = Request("PhoneNetwork") & ""
nPatientID =	PageHelper.DecodeStringToInteger(Request("PID"), -1)
sGCMRegId = Request("GCMRegId") & ""

%>

<p><div id="ResultMsg" class="alert"></div></p>
  Full Name: <strong><%=FullNameByName(sCodeName)%></strong></br>
  Username: <strong><%=sCodeName%></strong>
  <br />
  <% If sScreenName <> "" Then %>
    Screen Name: <strong><%=sScreenName%></strong><br />
  <% End If %>  
  Cell Phone #: <strong><%=sPhoneNum%></strong><br />
  <%If sDeviceType="android"%>
      Text or Notification?: 
      <select id="TextNotification" name="TextNotification" onChange="ShowURL();">
        <option value="1">Text</option>
        <option value="0">Notification</option>
      </select>
  <%End If%>
</p>
<form name="SMS" action="" onSubmit="return false;" method="get">
	<input type="hidden" name="MsgType" id="MsgType" value="<%If sDeviceType="android"%>1<%Else%>0<%End If%>" />  
    <input type="hidden" name="GCMRegId" id="GCMRegId" value="<%=sGCMRegId %>" />  
  <div id="Message">
   <div class="form-item" id="NotificationDiv" style="display:none;">
    	<label for="NotificationURL">URL:</label>
        <select id="NotificationURL" name="NotificationURL">
            <option value="">Send to..</option>
            <option value="WS/WS.aspx">Weekly Survey</option>
            <option value="WS/WS.aspx">Check In</option>
            <option value="DR/ListGroups.aspx">Discussion Group</option>
            <option value="CM/ListMsgs.aspx">My Messages</option>
        </select>     
      <label for="NotificationTitle">Title:</label>
      <input type="text" name="NotificationTitle" id="NotificationTitle"  style="width:50%;" maxlength="25" />
    </div>
    <div class="form-item" id="TextMsgDiv">
    <label for="TextMsg">Text Message (<span id="TextCharsLeft">155</span> characters left):</label>
    <textarea name="TextMsg" style="font-size:1.5em;width:98%" rows="3" wrap="soft" id="TextMsg" onKeyUp="document.getElementById('TextCharsLeft').innerHTML = (155 - this.value.trim().length);"></textarea>
    </div>
    <div><input type="button" value="Send as Text" onClick="Validate();" /></div>   
  </div>
</form>

<script type="text/javascript">
var f = document.SMS;
function Validate() {	
	var dataStr='';
	if (document.getElementById("MsgType").value == "1" && document.getElementById("TextNotification").value == "0"){
		var TextNotification = document.getElementById("TextNotification");
		var NotificationURLBox = document.getElementById("NotificationURL");
		f.NotificationTitle.value=trimString(f.NotificationTitle.value);		
		if (NotificationURLBox[NotificationURLBox.selectedIndex].value == "" || f.NotificationTitle.value.length == 0){
			confirm("Please enter all the fields");
		} 
		else
		{
			dataStr = 'TextNotification='+  TextNotification[TextNotification.selectedIndex].value + '&NotificationTitle='+ f.NotificationTitle.value +'&NotificationURL='
			+ NotificationURLBox[NotificationURLBox.selectedIndex].value +'&GCMRegId=<%=sGCMRegId%>';
			
			$.ajax({
				url: 'Dashboard_SendTextMsg.aspx',
				data: dataStr,
				success: function(result,status,xhr) {					
					$('#ResultMsg').html(result);
					setTimeout("$('#ResultMsg').html('');", 3000);
				},
				error: function(xhr,status) {
					alert ('ERROR loading page\n'+status+' '+xhr.statusText);
				}
			});		
		}
	} else {
		f.TextMsg.value=trimString(f.TextMsg.value);
		var msg = f.TextMsg.value;
		if (msg.length == 0){
			confirm("Your message is empty.");
		}
		 else if (msg.length > 155){
			confirm("Your message is too long - must be no more than 155 characters");
			f.TextMsg.value = trimString(msg.substring(0, 155));
		}
		else
		{
			var TextNotification = document.getElementById("TextNotification");
			dataStr = 'TextNotification='+ TextNotification[TextNotification.selectedIndex].value + '&TextMsg='+ msg+'&PhoneNetwork=<%=sPhoneNetwork%>&PhoneNum=<%=sPhoneNum%>';
			$.ajax({
				url: 'Dashboard_SendTextMsg.aspx',
				data: dataStr,
				success: function(result,status,xhr) {					
					$('#ResultMsg').html(result);
					setTimeout("$('#ResultMsg').html('');", 3000);
				},
				error: function(xhr,status) {
					alert ('ERROR loading page\n'+status+' '+xhr.statusText);
				}
			});		
		}
	}
}
function trimString(str) {
	return str.replace(/^\s+/g, '').replace(/\s+$/g, ''); 
}
function ShowURL(){
	if(document.getElementById("TextNotification").value == "0"){
		document.getElementById("NotificationDiv").style["display"]= 'block';
		document.getElementById("TextMsgDiv").style["display"]= 'none';
	}
	else{
		document.getElementById("NotificationDiv").style["display"]= 'none';
		document.getElementById("TextMsgDiv").style["display"]= 'block';
	}
}
</script>