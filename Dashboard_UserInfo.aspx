<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->
<!--#INCLUDE FILE="DashboardFunctions.aspx"-->
<style>
.Row .Date, .RowDk .Date {
	margin: 0 0 3px 0;
	padding: 0 2px 0 2px;
	}
	
.Row label, .Row strong {
	color: #000066;
	font-weight: bold;
	}
	
.Row p, .RowDk p {
	margin: 0 0 3px 0;
	padding: 6px 2px 0 2px;
	}
	
.RowLt {
	padding: 6px 6px 6px 6px;
	}
	
.RowDk {
	padding: 6px 6px 6px 6px;
	background: #C8E3EC;
	width: 80%;
	}
	
.RowDk label, .RowDk strong {
	color: #000066;
	font-weight: bold;
	}
table {
	border-style: solid;
	border-color: #999;
	border-width: 0 0 0px 0px;
	margin-bottom: 1em;
	}
td {
	border-style: solid;
	border-color: #999;
	border-color: #cde;
	border-width: 0px 0px 0 0;
	padding: 2px 5px;
	}	
</style>

<%
Dim nPatientID As Integer= PageHelper.DecodeStringToInteger(Request("PID"), -1)

Dim sCodeName As String = ""
Dim nPhotoID As Integer = 0
rs = ExecuteReaderSP("_MyPhotosNew", nPatientID, 0, "GetUserPhotoID")
If rs.Read() Then 
    sCodeName = rs("CodeName")
    nPhotoID = rs("ImageID")
End If
rs.Close()

' Check if this is an agency that allows sharing of emergency mode and the patient is in said mode.
Dim IsEmergencyMode As Boolean = ExecuteScalarSP("_EmergencyMode", "ShowEmergencyToTeam", nPatientID)

%>

<div>
<table cellpadding="0" cellspacing="0" width="100%">   
	<tr>
	<%If nPhotoID = 0 Then%>
        <td class="Profile-Photo"><img src="../Images/Users/no-img-vert.gif" border="0" title="No Photo" alt="No Photo" />
        <div style="position:relative;">
        <%If IsEmergencyMode%>
            <div class="flag flag-profile"><img src="../Images/Icons/flag.png" /></div>
        <%End If%>
        </div>
        </td>
	<%Else%>
        <td class="Profile-Photo">
          <div style="position:relative;">
        <%If IsEmergencyMode%>
            <div class="flag flag-profile"><img src="../Images/Icons/flag.png" /></div>
        <%End If%>
        	<img src="../MyPhotos/LoadImage.aspx?GUID=<%=PageHelper.EncodeIntegerToString(nPatientID)%>&thn=1&IID=<%=PageHelper.EncodeIntegerToString(nPhotoID)%>" border="0" title="<%=sCodeName%>"
             alt="<%=sCodeName%>" />
          </div>
        </td>
	<%End If%>
        <td>
        	<div id="wschart" style="width:720px; height:320px;"></div>	
   		</td>
         <td>
        	<input type="button" value="graph options" onClick="ShowGraphOptions();"/>
   		</td>
  </tr>
</table>

<div id="GraphOptions" style="display:none;">
 <%rs = ExecuteReader("SELECT FieldName,ShortName FROM WeeklySurveyList")%>      
	<%While rs.Read()%>
        <input type="checkbox" id="chk_<%=rs("ShortName")%>" value="<%=rs("FieldName")%>">&nbsp; <%=rs("ShortName")%> &nbsp;</input>
    <%End While%>
    &nbsp;
    <input type="button" onClick="loadWeeklySurvey();" value="Reload Chart"/>
 <%rs.Close()%>
</div>
</div>

<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->

<script type='text/javascript' src='jsInclude/jquery-1.7.2.min.js'></script>
<script type='text/javascript' src='jsInclude/SimpleModal/simplemodal.1.4.2.min.js'></script>
<link rel="stylesheet" href="jsInclude/SimpleModal/simplemodal.css" />

<script type="text/javascript">
var wschart=null, relapseChart=null;
function loadWeeklySurvey() {
	//alert(getUserId())
	var selBox = document.getElementById("SurveyQuestions")
	//var sData = "StartDate=" + document.getElementById("StartDate").value+
//				"&EndDate=" + document.getElementById("EndDate").value+
//				"&Question=" + selBox[selBox.selectedIndex].value +
//				"&PID="+getUserId() + "&SiteID="+getSiteId() + "&GUID=[%=B64UserID%>";
	var checkedIdValues = $(":checkbox:checked").map(function() {
        return document.getElementById(this.id).value;
    }).get();
	
	var today = new Date();
	var sData = "From=DashboardUserInfo"+
				"&StartDate=1/1/2010"+
				"&EndDate=" + today+
				"&Question=" + checkedIdValues +
				"&PID="+getUserId() + "&SiteID="+getSiteId() + "&GUID=[%=B64UserID%>";

	//var ajax = AJAXRequest("post","../WS/WSShowChartContent.aspx",s,null,null);
	if (wschart !== null) {wschart.destroy(); wschart=null;}
    $("#wschart").html("<p style='margin-top:80px;' align='center'>Loading, please wait...<br /><br /><img src='images/Wait.gif' /><p>");
	$.ajax({
		url: "WSChart.aspx",
		data: sData,
		cache: false,
		success: function(result) {
			if (result.indexOf("NO DATA") > -1) {
				$("#wschart").html("<h3 style='margin-top:80px;'>No Data Found For Date Range</h3>");
			}else {
				eval(result);
			}
		}
	});
}

loadWeeklySurvey();

function ShowGraphOptions(){
	$('#GraphOptions').modal({overlayClose:true});	
	return false;
}
</script>