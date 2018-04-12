<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>

<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="DashboardFunctions.aspx"-->

<%
Server.ScriptTimeout = 60*5

' This file loads a patient's survey data from the DB and returns javascript to draw a graph of the data.
' The javascript is intended to be processed by an AJAX call.

Dim bDidUse As Boolean = False
Dim bNotify As Boolean = False
Dim bShareInfo As Boolean = False
Dim nPatientID As Integer
Dim nSiteID As Integer = 1
Dim Ques_no As Integer = 0
Dim nMax_Y As Integer = 3.5
Dim nMin_Y As Integer = -3.5

Dim QuestionTypes As String() = Split(Request("Question[]")+"", ",")
Dim SeriesData As StringBuilder = New StringBuilder(1024*4)

For Each QuestionType As String In QuestionTypes

	Dim x1, y1, xTxt, xGap As Integer
	
	Dim dDataAverage As Double
	
	Dim nDataItems As Integer = 0
	Dim nDataItems1 As Integer = 0
	Dim nSum As Double
	Dim s As Object
	Dim rise As Double = 0.0
	Dim run As Double = 0.0
	Dim prevVal As Double = 0.0
	
	Dim CurDate, LastDate, StartDate, EndDate, Epoch As DateTime
	
	Dim dateSql As String = ""
	
	Int32.TryParse(Request("PID"), nPatientID)
	
	If (Not String.IsNullOrEmpty(Request("EndDate"))) AndAlso (Not String.IsNullOrEmpty(Request("StartDate"))) Then
		If IsDate(Request("EndDate")) AndAlso IsDate(Request("StartDate")) Then
			StartDate = DateTime.Parse(Request("StartDate"))
			EndDate = DateTime.Parse(Request("EndDate")).AddDays(1)
			dateSql = "(u.DateColumn > '" & StartDate.ToString() & "') AND (u.DateColumn < '" & EndDate.ToString() & "')"
		End If
	End If
	
	Dim sql As String
	' Filter out unshared surveys unless the viewer is an admin or the patient themselves
	'Let us not filter them for now	
	If nPatientID > 0 Then		
		dt = ExecuteDataTableSP("_DashboardReports", "AllRedPins_Filter", nPatientID, StartDate, EndDate)	
	Else
		dt = ExecuteDataTableSP("_DashboardReports", "AllRedPins_No_Filter", nPatientID, StartDate, EndDate)		
	End If
		
	'Apply settings and Filter unwanted data
	dt = ApplySettings_UserReports(dt, nUserID)	
	
	dv = dt.DefaultView	
	nDataItems = dv.Count-1	
	
	If dv.Count <= 1 Then
		Response.Write("document.getElementById(""wschart"").innerHTML = ""<h3 style='margin-top:80px'>Not Enough Data Available to Show Weekly Survey Graph.</h3>"";")
		Response.End()
	End If
	
	Dim threshold As Double = -5
	
	' Load all questions if we weren't passed a specific one
	If QuestionType.Length = 0 Then
		dt2 = ExecuteDataTable("SELECT ItemID,FieldName FROM WeeklySurveyList")
		dv2 = dt2.Defaultview
	End If
	
	Dim nData As New List(Of Double)
	Dim nDays As New List(Of Long)
	Dim sType_Data As New List(Of String)	
	Dim sRedPin As New List(Of Boolean)
	Dim sStartDate, sEndDate As String
	Dim LastRedPinType As String
	Epoch = New DateTime(1970, 1, 1)	
			
	' Either average all the positive and negative factors, or load the specific factor we were asked about
	Dim m = nDataItems + 1 'nDataItems1 + 2
	Dim noYCoord_Index_List As New List(Of Integer)
	Dim dates_List As New List(Of DateTime)
	Dim k = 0, l = 0
	i = 0
	j = 0	
	
	'Begin Main Logic 	
	Dim n = 0
	Dim n1=0
	For i=0 To nDataItems		
			If dv(i)("redpin_type").Contains("WSD") OrElse dv(i)("redpin_type").Contains("ADR") Then			
					Select Case QuestionType
						Case "" ' Average all factors
							nSum = 0
							For quesNo=0 To 4
								nSum += -dv(i)( dv2(quesNo)(1) )  ' Risks
							Next
							
							For quesNo=5 To 9
								nSum += dv(i)( dv2(quesNo)(1) )   ' Protection
							Next
									
							dDataAverage = nSum / 10					
							
						Case "Sleep", "Depression", "Urges", "Risks", "Relationships" ' The negative factors
							dDataAverage = -dv(i)(QuestionType) + 3.5				
									
						Case "Confidence", "Meetings", "Religion", "Activities", "SupportivePeople" ' The positive factors
							dDataAverage = dv(i)(QuestionType) - 3.5					
									
					End Select
															
					CurDate = DateTime.Parse(dv(i)("redpin_date"))
					If LastDate.ToString("MM/dd/YYYY").CompareTo(CurDate.ToString("MM/dd/YYYY")) <> 0 OrElse LastRedPinType <> dv(i)("redpin_type") Then
						n1 = n1 + 1
						LastDate = CurDate
						nData.Add(dDataAverage)		
						nDays.Add(LastDate.Subtract(Epoch).TotalMilliseconds)
						sType_Data.Add(dv(i)("redpin_type"))
						If dv(i)("arp_redpin") = 1 And dv(i)("RedFlagsColumn") = 1 Then
							sRedPin.Add(true)
						Else
							sRedPin.Add(false)
						End If						
						dates_List.Add(LastDate)
						
						If i = 0 Then
							sStartDate = LastDate.ToString("MM/dd/yy")
						ElseIf i = nDataItems Then
							sEndDate = LastDate.ToString("MM/dd/yy")
						End If
					End If
					LastRedPinType = dv(i)("redpin_type")
						
			Else	
				CurDate = DateTime.Parse(dv(i)("redpin_date"))
				If LastDate.ToString("MM/dd/YYYY").CompareTo(CurDate.ToString("MM/dd/YYYY")) <> 0 OrElse LastRedPinType <> dv(i)("redpin_type") Then					
					LastDate = CurDate
					nData.Add(-999)	
					noYCoord_Index_List.Add(i)	
					nDays.Add(LastDate.Subtract(Epoch).TotalMilliseconds)
					sType_Data.Add(dv(i)("redpin_type"))
					If dv(i)("RedFlagsColumn") = 1 Then
						sRedPin.Add(true)	
					Else
						sRedPin.Add(false)					
					End If
					dates_List.Add(LastDate)
					
					If i = 0 Then
						sStartDate = LastDate.ToString("MM/dd/yy")
					ElseIf i = nDataItems Then
						sEndDate = LastDate.ToString("MM/dd/yy")
					End If								
				End If
				LastRedPinType = dv(i)("redpin_type")
			End If			
	Next i			
	
		Dim tempTCoord As Integer
		Dim left_Score As Integer
		Dim right_Score As Integer
		Dim left_Date As DateTime
		Dim right_Date As DateTime
		Dim missed_Score As Integer	
		Dim missed_Date As DateTime		
				
	For i = 0 To noYCoord_Index_List.Count - 1	
		left_Score = 0
		right_Score = 0
		left_Date = Nothing
		right_Date = Nothing
		
		tempTCoord = noYCoord_Index_List(i)
		missed_Date = dates_List(tempTCoord)
		For j = tempTCoord To 0 step -1
			If noYCoord_Index_List.Contains(j) AndAlso j-1 >=0 Then
				Continue For
			Else If noYCoord_Index_List.Contains(j) AndAlso (j-1 < 0) Then
				left_score = 0
				left_Date = dates_List(tempTCoord)
				Exit For
			Else
				left_score = nData(j)
				left_Date = dates_List(j)
				Exit For
			End If
		Next
		
		For j = tempTCoord To m-1
			If noYCoord_Index_List.Contains(j) AndAlso j+1 <= m-1 Then
				Continue For
			Else If noYCoord_Index_List.Contains(j) AndAlso j+1 > m-1 Then
				right_Score = 0
				right_Date = dates_List(tempTCoord)
				Exit For
			Else If j <= nData.Count-1
				right_Score = nData(j)
				right_Date = dates_List(j)
				Exit For
			End If
		Next
		
		If left_Date <> right_Date Then			
		
			missed_Score = (left_Score) + ((((left_Date.Subtract(missed_Date).TotalMilliSeconds)/(left_Date.Subtract(right_Date).TotalMilliSeconds))) * (left_Score-right_Score))
		Else
			missed_Score = 0
		End If
		nData(tempTCoord) = missed_Score
	Next i
				
	If QuestionType.Length = 0 Then
		' We don't need the list table any more - we may need the data table for the date data
		dt2.Dispose()
	End If
	
	Dim sb As StringBuilder = New StringBuilder(1024*4)
	
	sb.Length = 0	
	For i = 0 To nData.Count - 1				
		s = nData.Item(i)
		If s < nMin_Y Then
			nMin_Y = s
		End If	
		If s > nMax_Y Then
			nMax_Y = s
		End If
			
		If s = "-999" Then
			Dim sName_Exp As String = ""
			If sType_Data(i).Contains("ADR") Then
				sName_Exp = "Used Drugs or Alcohol" + "<br/>on "
			Else If sType_Data(i) = "NI" Then
				sName_Exp = "Missed Naltroxone Injection" + "<br/>on "
			Else If sType_Data(i) = "ERV" Then
				sName_Exp = "Missed ERVisit" + "<br/>on "
			Else If sType_Data(i) = "ARR" Then
				sName_Exp = "Arrest occurred" + "<br/>on "
			Else If sType_Data(i) = "DA" Then
				sName_Exp = "Missed Detox Admission" + "<br/>on "
			Else If sType_Data(i) = "ACHESSIA" Then
				sName_Exp = "Has been InActive" + "<br/>since "
			Else If sType_Data(i) = "MS" Then
				sName_Exp = "Missed taking meds" + "<br/>on "
			Else
				sName_Exp = "Missed Medication" + "<br/>on "
			End If
				
			sb.Append("{name: '" & sName_Exp & "', x: ").Append(nDays(i)).Append(",y: 0")
			If sRedPin(i) AndAlso Ques_no = 0 Then
				sb.Append(",marker: {symbol: 'url(images/redpin.png)', radius: 0, showInLegend: false}")
			End If
			sb.Append("},")
				
		Else 
			If NOT String.IsNullOrEmpty(s) Then 'If s is Not NULL or Empty
				If sType_Data(i) = "WSD" Then
					sb.Append("{name: 'Weekly Survey score:" & Math.Round(s,3).ToString() & "<br/>on ', x: ").Append(nDays(i)).Append(",y: ").Append(Math.Round(s,3))
					If sRedPin(i) AndAlso Ques_no = 0 Then
						sb.Append(",marker: {symbol: 'url(images/redpin.png)', radius: 0, showInLegend: false}")
					End If
					sb.Append("},")
				Else 
					Dim sName_Exp As String = ""
					If sType_Data(i).Contains("ADR") Then
						sName_Exp = "Used Drugs or Alcohol: " & Math.Round(s,3).ToString() + "<br/>on "
					Else If sType_Data(i) = "NI" Then
						sName_Exp = "Missed Naltroxone Injection" + "<br/>on "
					Else If sType_Data(i) = "ERV" Then
						sName_Exp = "Missed ERVisit" + "<br/>on "
					Else If sType_Data(i) = "ARR" Then
						sName_Exp = "Arrest occurred" + "<br/>on "
					Else If sType_Data(i) = "DA" Then
						sName_Exp = "Missed Detox Admission" + "<br/>on "
					Else If sType_Data(i) = "ACHESSIA" Then
						sName_Exp = "Has been InActive" + "<br/>since "
					Else If sType_Data(i) = "MS" Then
						sName_Exp = "Missed taking meds" + "<br/>on "
					Else
						sName_Exp = "Missed Medication" + "<br/>on "
					End If
											
					sb.Append("{name: '" & sName_Exp & "', x: ").Append(nDays(i)).Append(",y: ").Append(Math.Round(s,3))
					If sRedPin(i) AndAlso Ques_no = 0 Then
						sb.Append(",marker: {symbol: 'url(images/redpin.png)', radius: 0, showInLegend: false}")
					End If
					sb.Append("},")
				End If				
			End If 'If s is Not NULL or Empty
		End If 's is not -999
						
	Next i
	
	If nDays.Count <= 1 Then   
		Response.Write("document.getElementById(""wschart"").innerHTML = ""<h3 style='margin-top:80px'>Not Enough Data Available to Show Weekly Survey Graph.</h3>"";")
		Response.End()	
	Else

		If QuestionType = "" Then
			QuestionType = "OverAll BAM Score"
		End If
		
		SeriesData.Append("{ name:' "+ QuestionType +" ', data: ["+ sb.ToString().Trim(",") +"]},")
	End If	
	
	Ques_no = Ques_no + 1					
Next
	SeriesData.ToString().Trim(",")
%>



wschart = new Highcharts.Chart({
	chart: {
		animation: false,
		renderTo: 'wschart'
		,plotBackgroundImage: 'images/chart-gradient.jpg'
		,defaultSeriesType: 'line' <%' options: bar area, areaspline, line, spline, column, pie, scatter %>
	},
      legend: {
       
    },
	credits: {enabled: false},
	title: {text: ''}, <%'No need for title%>
	xAxis: {
		type: 'datetime'
		,dateTimeLabelFormats: {
                day: '%b %e',
                week: '%b %e'
            }
		,showFirstLabel: true
		,showLastLabel: true
	},
	yAxis: {
		min: <%=nMin_Y%>, max: <%=nMax_Y%>,
		title: {text: 'BAM Range'},
		showFirstLabel: true,
		showLastLabel: true	
	},
    tooltip: {
            formatter: function() {                    
                return '<b>'+ this.point.name + '</b>' +
                    Highcharts.dateFormat('%b %e', this.x);
            }
        },
	series: [ <%=SeriesData%> ]   
});

$('.highcharts-legend-item').each( function (i) {										 
		($(this).children(1)[1]).remove();
	});
 
$('.highcharts-markers image').each( function (i) {	
		var image_Top = $(this).position().top - 10;
        var image_Left = $(this).position().left;     
        $(this).attr("x", parseInt($(this).attr("x"), 10) + 3);
        $(this).attr("y", $(this).attr("y") - 13);
	});