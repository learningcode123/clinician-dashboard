<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>

<div id="wschart" style="width:720px; height:320px;"></div>

<script type="text/javascript" src="jsInclude/jquery-1.7.2.min.js"></script>
<script type="text/javascript">
loadWeeklySurvey();
function loadWeeklySurvey() {
	//alert(getUserId())
	var selBox = document.getElementById("SurveyQuestions")
	var sData = "StartDate=" + document.getElementById("StartDate").value+
				"&EndDate=" + document.getElementById("EndDate").value+
				"&Question=" + selBox[selBox.selectedIndex].value +
				"&PID="+getUserId() + "&SiteID="+getSiteId() + "&GUID=<%=B64UserID%>";

	//var ajax = AJAXRequest("post","../WS/WSShowChartContent.aspx",s,null,null);
	if (wschart !== null) {wschart.destroy(); wschart=null;}
    $("#wschart").html("<p style='margin-top:80px;' align='center'>Loading, please wait...<br /><br /><img src='images/Wait.gif' /><p>");
	$.ajax({
		url: "../Reports/WSChart.aspx",
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
</script>