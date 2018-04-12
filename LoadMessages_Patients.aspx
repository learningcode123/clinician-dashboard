<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage"%>
<!--#include File="../Globals/Globals.aspx" --> 
<!-- Called ajaxically to load a list of patients of the counselor-->

<%
	Dim nSubUserID = 0
	If Request("UserID")+"" <> "" Then
		nSubUserID = Request("UserID")
	End If
	
	Dim nImageID As Integer = 0
	Dim sCommandName As String = "PatientsByLatestMsg"
	Dim dt As System.Data.DataTable
	If UserIsCounselor() Then
		dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "counselor")
	Else
		dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "admin")
	End If
	Dim dv As System.Data.DataView = dt.DefaultView		
%>

<div id="PatientList2" class="left">
<input type="hidden" id="UserID" />
<input type="hidden" id="NoOfUsers" />

<%
    Dim sScreenName As String
    
    'If we want to exclude SELF, uncomment this:
    dv.RowFilter = "UserID <> " & nUserID
    
    n = dv.Count - 1
%>
<% If n+1 > 0 Then %>	<% 'Check if patients are there %>
<table class="tableLeft BlueOutLine" cellpadding="0" cellspacing="0" width="100%">
<%For i=0 To n%>
<%If i=0 Then%>
    <script>
    if(<%=nSubUserID%> != 0)
        document.getElementById("UserID").value='<%=nSubUserID%>';
    else
        document.getElementById("UserID").value='<%=dv(i)("UserID")%>';			     
    </script>
<%End If%>
<%
  nImageID = dv(i)("ImageID")
  If nImageID > 0 Then
  	nImageID = VerifyImageID(nImageID)
  End If

  sScreenName = dv(i)("ScreenName")
  
  If sScreenName.Length = 0 Then
	sScreenName = dv(i)("CodeName")
  End If 
  
  Dim numberNewPrivateMessages As String = dv(i)("NumberNewPrivateMessages").ToString()
%>
  <tr>
      <td style="cursor:pointer" id="td_<%=dv(i)("UserID")%>" onClick="ChangeHiddenValues('<%=dv(i)("UserID")%>', this);return false;">
        <div id="left">         
          <%If nImageID > 0 Then%>                        
             <img src="../MyPhotos/LoadImage.aspx?GUID=<%=B64UserID%>&thn=1&IID=<%=PageHelper.EncodeIntegerToString(nImageID)%>" 
             alt="<%=sScreenName%>" /><br />
          <%Else%>
             <img width="60" height="80" src="../Images/Users/no-img-vert.gif" alt="No Photo" /><br />
          <%End If%>
        </div>
        <div id="right">
        <strong>
         <%=Server.HTMLDecode(dv(i)("FirstName"))%> <%=Server.HTMLDecode(dv(i)("LastName"))%>
        </strong>   
        <% If dv(i)("RedFlag") Then %>               
         <div class="flag"><img src="images/redpin.png" /></div>                           
        <% End If %>
        </div>
		
		<span id="nnpm_<%=dv(i)("UserID")%>" style="display:none;"><%=numberNewPrivateMessages%></span>
		<%
		If numberNewPrivateMessages <> "0" Then
		%>
		<span id="nnpmd_<%=dv(i)("UserID")%>">
			New Message(s)
		</span>
		<%
		End If
		%>
      </td>
</tr>
    <%Next%>
    <%dt.Dispose()%>  
</table>
<% End If %>	<% 'Check if patients are there %>
</div><!-- End of PatientList2 -->

<script>    
	document.getElementById("NoOfUsers").value=<%=n+1%>;  	     
</script>

<% If (n+1) = 0 Then %>
    <tr><td colspan="3" style="text-align:left;"><h2>No users found.</h2></td></tr>
<% Else %> 
<div id="MessageList" class="right"> 
	<em style="float:left;"> &nbsp; &nbsp; Loading Messages...</em>
</div>
<% End If %> 

