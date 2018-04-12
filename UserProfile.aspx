<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->
<!--#INCLUDE FILE="DashboardFunctions.aspx"-->

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


Dim sCellPhone As String = ExecuteScalar("SELECT MobilePhone FROM MobileUsers WHERE UserID=@nPatientID", nPatientID)
Dim nCounselorID As Integer = ExecuteScalar("SELECT Counselor FROM MobileUsers WHERE UserID=@nPatientID", nPatientID)

rs = ExecuteReaderSP("_MyPhotosNew", nPatientID, 0, "MyTeamProfile")
Dim sTeamName, sActivities, sInterests, sMusic, sTV, sMovies, sBooks, sQuotes, sAboutMe,sSobrietyDate As String
If rs.Read() Then
    sTeamName = HttpUtility.HtmlEncode(rs("TeamName"))
    sActivities = HttpUtility.HtmlEncode(rs("Activities"))
    sInterests = HttpUtility.HtmlEncode(rs("Interests"))
    sMusic = HttpUtility.HtmlEncode(rs("Music"))
    sTV = HttpUtility.HtmlEncode(rs("TV"))
    sMovies = HttpUtility.HtmlEncode(rs("Movies"))
    sBooks = HttpUtility.HtmlEncode(rs("Books"))
    sQuotes = HttpUtility.HtmlEncode(rs("Quotes"))
    sAboutMe = HttpUtility.HtmlEncode(rs("AboutMe"))
Else
    sTeamName = ""
    sActivities = ""
    sInterests = ""
    sMusic = ""
    sTV = ""
    sMovies = ""
    sBooks = ""
    sQuotes = ""
    sAboutMe = ""
End If
rs.Close()

Dim ShareWithTeam As Boolean = False

rs = ExecuteReader("SELECT SobrietyDate,ShareWithTeam FROM SobrietyCounter WHERE UserID=@nPatientID", nPatientID)
If rs.Read() Then
    ShareWithTeam = rs("ShareWithTeam")
    If ShareWithTeam Then
        sSobrietyDate = CType(rs("SobrietyDate"),DateTime).ToString("MMMM d, yyyy")
    End If
End If
rs.Close()

' Check if this is an agency that allows sharing of emergency mode and the patient is in said mode.
Dim IsEmergencyMode As Boolean = ExecuteScalarSP("_EmergencyMode", "ShowEmergencyToTeam", nPatientID)

If sTeamname = "" Then
    sTeamName = sCodeName
End If
%>
<div>
<h1><%=sCodeName%>'s Profile </h1>	
<%If nPhotoID = 0 Then%>
    <img src="../Images/Users/no-img-vert.gif" border="0" title="No Photo" alt="No Photo" />
    <div style="position:relative;">
    <%If IsEmergencyMode%>
        <div class="flag flag-profile"><img src="../Images/Icons/flag.png" /></div>
    <%End If%>
    </div>
<%Else%>        
    <div style="position:relative;">
    <%If IsEmergencyMode%>
        <div class="flag flag-profile"><img src="../Images/Icons/flag.png" /></div>
    <%End If%>
        <img src="../MyPhotos/LoadImage.aspx?GUID=<%=PageHelper.EncodeIntegerToString(nPatientID)%>&thn=1&IID=<%=PageHelper.EncodeIntegerToString(nPhotoID)%>" border="0" title="<%=sCodeName%>"
         alt="<%=sCodeName%>" />
    </div>
<%End If%>
<br/>
<div class="OutLine" style="width: 80%;">


<% Dim DarkDiv As Boolean = False %>

<%If ShareWithTeam Then%>
        <!-- Share sobriety date with team if it's populated and the user has consented to share it -->
  <div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
    <strong>Sober Since:</strong>
      <%=sSobrietyDate%>
  </div>
  <% DarkDiv = Not DarkDiv %>
<%End If%>

<%If sAboutMe <> ""%>
  <div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
    <strong>About <%=Server.HTMLDecode(sTeamName)%>:</strong> 
    <%=Server.HTMLDecode(sAboutMe)%>
  </div>
  <% DarkDiv = Not DarkDiv %>
<%End If%>

<div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
    <strong>Activities:</strong>
    <%=Server.HTMLDecode(sActivities)%>
</div>
<% DarkDiv = Not DarkDiv %>
<div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
    <strong>Interests:</strong>
    <%=Server.HTMLDecode(sInterests)%>
</div>
<% DarkDiv = Not DarkDiv %>
<div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
    <strong>Music:</strong>
    <%=Server.HTMLDecode(sMusic)%>
</div>
<% DarkDiv = Not DarkDiv %>
<div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
        <strong>TV Shows:</strong>
    <%=Server.HTMLDecode(sTV)%>
</div>
<% DarkDiv = Not DarkDiv %>
<div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
        <strong>Movies:</strong>
    <%=Server.HTMLDecode(sMovies)%>
</div>
<% DarkDiv = Not DarkDiv %>
<div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
        <strong>Books:</strong>
    <%=Server.HTMLDecode(sBooks)%>
</div>
<% DarkDiv = Not DarkDiv %>
<div class="<%If DarkDiv Then%>RowDk<%Else%>RowLt<%End If%>" >
        <strong>Quotes:</strong>
    <%=Server.HTMLDecode(sQuotes)%>
</div>

<h3>Recent Activity</h3>

<table cellspacing="0" cellpadding="0" width="100%" class="NoOutLine">
<%
Dim bShowAll As Boolean = True
Dim nMilestone As Integer
Dim sFeedType, sScreenName,sSobrietyMsg,sPlural As String
Dim nNewCount As Integer = CountNewFeeds(nPatientID)
oDataTable = GetCurrentFeed(nPatientID, False, "TopFeed")
Dim dv As System.Data.DataView = oDataTable.DefaultView
dv.RowFilter = ("UserID = '" & nPatientID.toString() & "'")

If dv.Count < 1 Then
        oDataTable.Dispose()
        oDataTable = GetArchivedFeed(nPatientID, False, "Archives")
        dv = oDataTable.DefaultView
        bShowAll = False
Else
        'I will have to go over each item to see how many items there are to display.
        'Photos may not be approved ...  If 0 after the count, then show all and then count again
        For i=0 To dv.Count-1
                If i < 10 Then
                        sFeedType = dv(i)("FeedType").ToLower()
                        If sFeedType="photo" AndAlso IsPhotoApproved( dv(i)("TargetID") ) Then
                                n += 1
                        ElseIF sFeedType="profile" Then
                                n += 1
                        ElseIF sFeedType="wall" Then
                                n += 1
                        ElseIF sFeedType="forum" Then
                                n += 1
                        ElseIF sFeedType="forumcom" Then
                                n += 1
                        ElseIf sFeedType="milestone" Then
                                n += 1
                        End If
                End If
        Next
        If n = 0 Then
                oDataTable.Dispose()
                oDataTable = GetArchivedFeed(nPatientID, False, "Archives")
                dv = oDataTable.DefaultView
                bShowAll = False
        End If
End If

n = 0
For i=0 To dv.Count-1
        If i < 10 Then
                sScreenName = dv(i)("ScreenName")
                If sScreenName.Length = 0 Then
                        sScreenName = dv(i)("CodeName")
                End If
        
                sFeedType = dv(i)("FeedType").ToLower()
        %>
        
                <%If sFeedType = "photo" Then %>
                        <%If IsPhotoApproved( dv(i)("TargetID") ) Then%>
                                <% n += 1%>
                                        <tr>
                                                <td class="Row">
                                                <div><%=Format(dv(i)("PostedOn"),"MM-dd-yy")%></div>
                                                <div><%=Server.HTMLDecode(sScreenName)%> posted a new photo.</div>
                                                </td>
                                        </tr>
                        <%End If%>
                                

                <%ElseIf sFeedType = "profile" Then %>
                                <% n += 1%>
                                        <tr>
                                                <td class="Row">
                                                        <div><%=Format(dv(i)("PostedOn"),"MM-dd-yy")%></div>
                                                        <div><%=Server.HTMLDecode(sScreenName)%> updated <%=MyGender(dv(i)("UserID"),"my")%> profile.</div>
                                                </td>
                                        </tr>
                                 
                <%ElseIf sFeedType = "wall" Then %>
                                <% n += 1%>
                                        <tr>
                                                <td class="Row">
                                                        <div><%=Format(dv(i)("PostedOn"),"MM-dd-yy")%></div>
                                                        <div><%=Server.HTMLDecode(sScreenName)%> wrote on <%=MyWallWriter(dv(i)("TargetID"))%>'s wall.
                                                        </div>
                                                </td>
                                        </tr>
                                
                <%ElseIf sFeedType = "forum" Then %>
                                <% n += 1%>
                                        <tr>
                                                <td class="Row">
                                                        <div><%=Format(dv(i)("PostedOn"),"MM-dd-yy")%></div>
                                                        <div><%=Server.HTMLDecode(sScreenName)%> started a new discussion topic.</div>
                                                </td>
                                        </tr>
                <%ElseIf sFeedType = "forumcom" Then %>
                                <% n += 1%>
                                <tr>
                                        <td class="Row">
                                                <div><%=Format(dv(i)("PostedOn"),"MM-dd-yy")%></div>
                                                <div><%=Server.HTMLDecode(sScreenName)%> wrote a discussion group message.</div>
                                        </td>
                                </tr>
                                
                <%ElseIf sFeedType = "milestone" Then%>
                        <% n += 1%>
                        <tr>
                                <td class="Row">
                                        <div><%=Format(dv(i)("PostedOn"),"MM-dd-yy")%></div>
                                        <%
                                                nMilestone = dv(i)("TargetID")
                                                Select Case nMilestone
                                                        Case 0 '1 Day
                                                                sSobrietyMsg = " has been sober for a day!"
                                                
                                                        Case 1 '1 week
                                                                sSobrietyMsg = " has been sober for a week!"
                                                                
                                                        Case 2 To 12 'Subtract 1 from nMilestone to get the number of months for the current milestone
                                                                If nMilestone-1 > 1 Then
                                                                        sPlural = "s"
                                                                End If
                                                                sSobrietyMsg = " has been sober for " & (nMilestone-1).ToString() & " month" & sPlural & "!"
                                                                
                                                        Case Else 'Subtract 12 from nMilestone to get the number of years for the current milestone
                                                                If nMilestone-12 > 1 Then
                                                                        sPlural = "s"
                                                                End If
                                                                sSobrietyMsg = " has been sober for " & (nMilestone-12).ToString() & " year" & sPlural & "!"
                                                                
                                                End Select
                                        %>
                                        <div><%=Server.HTMLDecode(sScreenName) & sSobrietyMsg%></div>
                                </td>
                        </tr>
                        
                <%End If%>

<%
        End If
Next%>
<%oDataTable.Dispose()%>
</table>
</div>

<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->

<script type='text/javascript' src='jsInclude/jquery-1.7.2.min.js'></script>
<script type='text/javascript' src='jsInclude/SimpleModal/simplemodal.1.4.2.min.js'></script>
<link rel="stylesheet" href="jsInclude/SimpleModal/simplemodal.css" />

<script type="text/javascript">
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
</script>