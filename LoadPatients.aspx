<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!-- Called ajaxically to load a list of users for Users.aspx -->

<%
Dim orderBy As String = Request("orderBy")+""
Dim nImageID As Integer = 0
Dim sCommandName As String = "PatientsInfo"
Dim bIsMyTeam As Boolean = True
Dim dt As System.Data.DataTable 

If UserIsCounselor() Then
	dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "counselor")
Else
	dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "admin")
End If
Dim dv As System.Data.DataView = dt.DefaultView

Dim nPointsEarned As Integer = 0

Dim nSiteID As Integer = 0
If Not UserIsSuperAdmin Then
    nSiteID = UserIntegerValue("SiteID")
End If

Dim bCanApprovePhotos As Boolean = (Not UserIsPatient) AndAlso (ExecuteScalarSP("_MyPhotosNew", 0, nSiteID, "NotApprovedCount") > 0)

%>

  <table class="Patientstable PatientsInner" style="width:100%;">
  <%
  Dim sScreenName As String

  'If we want to exclude SELF, uncomment this:
  dv.RowFilter = "UserID <> " & nUserID
  If orderBy = "redpin" Then
	dv.Sort = "RedFlag Desc" 
  Else If orderBy = "activesince" Then
	dv.Sort = "StartDate ASC"
  Else 'If orderBy = "name" or orderBy = "" => default
	dv.Sort = "FirstName ASC, LastName ASC"
  End If

  n = dv.Count - 1
  %>
  <%For i=0 To n%>
    <%
      nImageID = dv(i)("ImageID")
      If nImageID > 0 Then
        nImageID = VerifyImageID(nImageID)
      End If
      nPointsEarned = MyRewardPoints(dv(i)("UserID"))
      sScreenName = dv(i)("ScreenName")
      If sScreenName.Length = 0 Then
        sScreenName = dv(i)("CodeName")
      End If
   
    %>
      <%If ((i+1) Mod 3) = 1 Then%> <tr> <%End If%>
      
      
      
      
      
      <td width="33%" valign="top" align="left" onClick="window.location.href='UserReports.aspx?PID=<%=PageHelper.EncodeIntegerToString( dv(i)("UserID"))%>';">
       
        <div style="padding:4px 2px 5px 2px; vertical-align:top;">
        
         <h4 align="left">
       	 <%=Server.HTMLDecode(dv(i)("FirstName"))%> <%=Server.HTMLDecode(dv(i)("LastName"))%>     
        </h4> 
        
         <p>
         <div class="image_flag">
			  <%If nImageID > 0 Then%>
                <a href="UserReports.aspx?PID=<%=PageHelper.EncodeIntegerToString( dv(i)("UserID"))%>">
                 <img src="../MyPhotos/LoadImage.aspx?GUID=<%=B64UserID%>&thn=1&IID=<%=PageHelper.EncodeIntegerToString(nImageID)%>" alt="<%=sScreenName%>" align="left" style="margin-right:5px;" />
                </a>
              <%Else%>
                <a href="UserReports.aspx?PID=<%=PageHelper.EncodeIntegerToString( dv(i)("UserID"))%>">
                 <img width="80" height="60" src="../Images/Users/no-img-vert.gif" alt="No Photo" align="left" style="margin-right:5px;" />
                </a>
              <%End If%>
               <% If dv(i)("RedFlag") Then %>
             	 <image src="images/redpin.png" class="redpin">
              <% End If %>
         </div>

      	<span style="float:right;margin-right:60px;">active since <%=Format(dv(i)("StartDate"), "MMM yyyy")%></span>
       
        </p>

        
        </div><!-- /wrap -->
        
      </td>
      
      
      
      <%If ((i+1) Mod 3) = 0 Then%> </tr> <%End If%>
  <%Next%>
  <%dt.Dispose()%>
  <%If (dv.Count Mod 3) <> 0 Then%>
      <%For j=1 To (3-(dv.Count Mod 3))%><td width="33%" class="NoCell">&nbsp;</td><%Next%>
    </tr>
  <%End If%>
  
  <% If (n+1) = 0 Then %>
    <tr><td colspan="3" style="text-align:left;"><h2>No users found.</h2></td></tr>
  <% End If %>
  </table>

<script language="vb" runat="server">
'Checks if a value is DBNull or Nothing and returns "" if it is, else returns value as string
Function CheckDBNull(DataString As Object, Optional UseNBSP As Boolean = False) As String
	If DataString Is Nothing OrElse DataString Is DBNull.Value OrElse DataString.ToString().Length = 0 Then
		Return IIF(UseNBSP,"&nbsp;","")
	Else
		Return DataString.ToString()
	End If
End Function
</script>