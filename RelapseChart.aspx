<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>

<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="DashboardFunctions.aspx"-->

<%
Server.ScriptTimeout = 60*5

Dim dTotal, dDrank, dAverage As Decimal
Dim RelapseData As New Dictionary(Of Long, Decimal)
Dim RelapseFractions As New Dictionary(Of String, String)
Dim nPatientID As Integer
Dim nSiteID As Integer

Dim CurDate, LastDate, StartDate, EndDate, Epoch As DateTime

Dim nWeeks As Integer
If Int32.TryParse(Request("Weeks"), nWeeks) = False Then
	nWeeks = 1
End If
nWeeks = 1	'Let us hard-code it to Every Week for now

Dim nAddDays As Integer = 7 * nWeeks
Dim lKey As Long
Dim sKey As String
Dim sAverage As String = "[["

nPatientID = PageHelper.DecodeStringToInteger(Request("PID"), -1)
nSiteID = Request("SiteID") & ""

Epoch = New DateTime(1970, 1, 1)

Dim siteUserIDs As String = "(SELECT UserID FROM MobileUsers WHERE UserTypeFlag < 3 AND SiteID=" & nSiteID & ")"
If nPatientID > 0 Then
	dt = ExecuteDataTable("SELECT PostedOn, DidRelapse FROM ProbabilityOfRelapse WHERE (DidRelapse IS NOT NULL) AND UserID=@userID",nPatientID)
Else
	dt = ExecuteDataTable("SELECT PostedOn, DidRelapse FROM ProbabilityOfRelapse WHERE (DidRelapse IS NOT NULL) AND (UserID IN "+siteUserIDs+")")
End If
dv = dt.DefaultView()

If dv.Count = 0 Then
	Response.Write("NO DATA")
	Response.End()
End If

' Get the start and end date that were passed in. If
' no date was passed, find the earliest/latest date for which
' there is data.
If Not String.IsNullOrEmpty(Request("StartDate")) Then
    StartDate = DateTime.Parse(Request("StartDate"))
Else
    StartDate = CDate(dv(0)("PostedOn")).ToString("MM/dd/yyyy")
End If

If Not String.IsNullOrEmpty(Request("EndDate")) Then
    EndDate = DateTime.Parse(Request("EndDate")).AddDays(1)
Else
    EndDate = CDate(dv(dv.Count-1)("PostedOn")).AddDays(1).ToString("MM/dd/yyyy")
End If

LastDate = StartDate
CurDate = StartDate.AddDays(nAddDays)

dv.RowFilter = "PostedOn >= '" & StartDate.ToString() & "' AND PostedOn < '" & EndDate.ToString() & "'"
dTotal = dv.Count

dv.RowFilter &= " AND DidRelapse=1"
dDrank = dv.Count

If dv.Count > 0 Then
	dAverage = dDrank / dTotal
Else
	dAverage = dDrank / 1
End If

' Construct coordinates to graph the average relapse rate over
' the entire time period.
sAverage &= StartDate.Subtract(Epoch).TotalMilliseconds & "," & dAverage & "],[" _

' Get the percent of patients who relapsed each nAddDays within the time period
Do While CurDate.CompareTo(EndDate) <= 0 
    dv.RowFilter = "PostedOn >= '" & LastDate.ToString() & "' AND PostedOn < '" & CurDate.ToString() & "'"
    dTotal = dv.Count

    dv.RowFilter &= " AND DidRelapse=1"
    dDrank = dv.Count

    If dTotal > 0 Then
        RelapseData.Add(LastDate.Subtract(Epoch).TotalMilliseconds, dDrank / dTotal)
        RelapseFractions.Add(LastDate.ToString("M/d/yy"), dDrank & "/" & dTotal)
    End If
    
    LastDate = CurDate
    CurDate = CurDate.AddDays(nAddDays)
Loop

If RelapseData.Count = 0 Then
	Response.Write("NO DATA")
	Response.End()
End If

sAverage &= LastDate.AddDays(-nAddDays).Subtract(Epoch).TotalMilliseconds & "," & dAverage & "]]"

Dim sb As StringBuilder = New StringBuilder(1024*4)
For Each lKey In RelapseData.Keys
    sb.Append("[").Append(lKey).Append(",").Append(Math.Round(RelapseData(lKey),3)).Append("],")
Next lKey

Dim sb2 As StringBuilder = New StringBuilder(1024*2)
sb2.Append("<br /><table border='1' cellpadding='1' cellspacing='0'><tr align='center'><th scope='row'>Date</th>")

' Don't show more than (approximately) eight entries, because we don't want this to take too
' much space.
Dim nStep As Integer = Math.Max(RelapseFractions.Count / 15, 1)
For i = 0 To RelapseFractions.Count - 1 Step nStep
	sb2.Append("<td>").Append(RelapseFractions.Keys(i)).Append("</td>")
Next i

sb2.Append("</tr><tr align='center'><th scope='row'>Relapsed</th>")
For i = 0 To RelapseFractions.Count - 1 Step nStep
	sb2.Append("<td>").Append(RelapseFractions.Values(i)).Append("</td>")
Next i
sb2.Append("</tr></table>")
%>

document.getElementById("relapseFractions").innerHTML = "<%=sb2.ToString()%>";

relapseChart = new Highcharts.Chart({
	chart: {
		renderTo: 'relapse'
		,defaultSeriesType: 'spline' <%' options: bar area, areaspline, line, spline, column, pie, scatter %>
	},
	credits: {enabled: false},
	title: {
		text: 'Probability of Of Relapse'
	},
	xAxis: {
		minorTickInterval:'auto',
		type: 'datetime'
		,dateTimeLabelFormat:'%e %b'
		//,categories:
	},
	yAxis: {
		minorTickInterval:'auto',
		min: 0,
		title: {text: 'Probability of Relapse'},
		showFirstLabel: true,
		labels: {
			formatter: function() {
				return (this.value *100)+'%'
			}
		}
	},
	series: [
			{marker: {enabled:false}, name:'Probability of Relapse ', data:<%="["+sb.ToString().Trim(",")+"]"%>}, 
			{marker: {enabled:false}, name:'Linear Regression',
			data:calculateLinearRegression([<%= sb.ToString().Trim(",")%>])}
			]
});