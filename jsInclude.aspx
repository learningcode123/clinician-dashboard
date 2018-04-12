
<script type='text/javascript' src='jsInclude/jquery-1.7.2.min.js'></script>
<script type='text/javascript' src='jsInclude/highcharts.js'></script>
<script type='text/javascript' src='jsInclude/exporting.js'></script>
<script type='text/javascript' src='jsInclude/Utils.js'></script>

<script type="text/javascript">
var booleanController = false;
var checkBooleanVar = false;
var wschart=null, relapseChart=null;
$.ajaxSetup({ cache: false });

$(document).ready(function(){
	loadWeeklySurvey();
	loadUserMsgs();	
	loadUserMerit();
});

function loadWeeklySurvey() {
	var sData = "StartDate=" + document.getElementById("StartDate").value+
				"&EndDate=" + document.getElementById("EndDate").value+				
				"&PID="+ document.getElementById("User").options[document.getElementById("User").selectedIndex].value+
				"&SiteID=<%=nSiteID%>";
			
	var surveyQuestion = new Array();
	var count = 0;

	$('input[type=checkbox][id^=chkSurveyQuestion_]:checked').each(function(){
		if($(this).attr("id") == 'chkSurveyQuestion_OA')
			surveyQuestion[count++] = '';
		else 
			surveyQuestion[count++] = ($(this).attr("id")).replace("chkSurveyQuestion_", "");	
	});
		
	if(document.getElementById("MouseOption").value != '')
	{		
		if(document.getElementById("MouseOption").value == 'OA')
			surveyQuestion[count] = '';
		else
			surveyQuestion[count] = document.getElementById("MouseOption").value;
		document.getElementById("MouseOption").value = '';
	}
			
	sData = sData + "&Question[]="+surveyQuestion.toString()	
	
	if (wschart !== null) {wschart.destroy(); wschart=null;}
    $("#wschart").html("<p style='margin-top:80px;' align='center'>Loading, please wait...<br /><br /><img src='images/Wait.gif' /></p>");
	$.ajax({
		url: "WSChart.aspx",
		data: sData,
		cache: false,
		success: function(result) {			
			if (result.indexOf("NO DATA") > -1) {
				$("#wschart").html("<h3 style='margin-top:80px;'>No Data Found For Date Range</h3>");
			}else {
				eval(result);
				booleanController = false;
			}
		}
	});
}

function loadUserMsgs() {
	var pid_var = document.getElementById("User").options[document.getElementById("User").selectedIndex].value;
	var sData = "PID="+ pid_var;
	if(pid_var == 0)
	{
		HideControl('WriteToSpan');
	}
	else
	{
		ShowControl('WriteToSpan');
	}
    $("#UserCounselor_Msgs_Div").html("<p style='margin-top:80px;' align='center'>Loading, please wait...<br /><br /><img src='images/Wait.gif' /></p>");
	$.ajax({
		url: "UserReports_Msgs.aspx",
		data: sData,
		cache: false,
		success: function(result) {			
				$("#UserCounselor_Msgs_Div").html(result);
		}
	});
}

function reloadDivs() {
	loadWeeklySurvey();
	loadUserMsgs();
	loadUserMerit();
}

function MouseOverEvent(MouseOverOption){	
	if(!document.getElementById("chkSurveyQuestion_"+MouseOverOption).checked && !booleanController)
	{
		booleanController = true;	 
		checkBooleanVar = true;
	}
	else
		checkBooleanVar = false;
	if(checkBooleanVar)
	{				
		document.getElementById("MouseOption").value = MouseOverOption;
		loadWeeklySurvey();
	}
}

function ShowControl(showControl){		
	document.getElementById(showControl).style.display='block';	
}

function HideControl(hideControl){
	document.getElementById(hideControl).style.display='none';	
}

function submitMeritItems(){	
	var sData = "SelectedUserID="+ document.getElementById("User").options[document.getElementById("User").selectedIndex].value;
	var merit_chkboxes = [];
	merit_chkboxes = $('input:checkbox[name^=Merit_Item_]');
	
	var categoryIDs = new Array();
	var count = 0;
	for(var i=0; i < merit_chkboxes.length - 1; i++){
		if(merit_chkboxes[i].checked){
			categoryIDs[count++] = merit_chkboxes[i].id.split('Merit_Item_')[1];
		}
	}
	sData = sData + "&categoryIDs[]="+categoryIDs.toString()	
	if(count > 0)
	{		
		$.ajax({
			url: "User_Merit_Save.aspx",
			data: sData,
			cache: false,
			success: function() {	
				$("#merit-save-status").html("User's ToDo items saved successfully");
				setTimeout(function () { $("#merit-save-status").html(""); }, 3000);				
			}
		});
	}
	else
	{
		$("#merit-save-status").html("Nothing to save");
	}
}

function loadUserMerit() {	
	var pid_var = document.getElementById("User").options[document.getElementById("User").selectedIndex].value;
	var sData = "PID="+ pid_var;
	if(pid_var == 0)
	{
		HideControl('Merit_Main_Div');
	}
	else
	{
		ShowControl('Merit_Main_Div');
	}
    $("#UserCounselor_Merit_Div").html("<p style='margin-top:80px;' align='center'>Loading, please wait...<br /><br /><img src='images/Wait.gif' /></p>");
	$.ajax({
		url: "UserReports_Merit.aspx",
		data: sData,
		cache: false,
		success: function(result) {	
				$("#UserCounselor_Merit_Div").html(result);
		}
	});
}

</script>