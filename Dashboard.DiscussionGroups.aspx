<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->

<% sServiceTitle = "Dashboard Home" %>
<h2>{{ loggedinuser }}'s Discussion Groups</h2>
<%
Dim nGroupID As Integer = PageHelper.DecodeStringToInteger(Request("GroupID"), -1, False)
Dim sGender As String = ""
If UserData.IsMale Then
        sGender = "M"
Else
        sGender = "F"
End If

If nGroupID = -1 Then
	' Get all Groups that the user has access to
	rs = GetGroups(UserData.DiscussionList.toString(), sGender, True, True, True)
	
	If rs.HasRows() Then
			Dim sSiteID As String = "-100000000000" ' To avoid nulls
			Dim sTypeID As String = "-100000000000"
			' Output the Groups
			While rs.Read()
					' Check if the site id has changed
					If sSiteID <> rs("SiteID").toString() Then
							If sSiteID <> "-100000000000" Or sTypeID <> "-100000000000" Then
%>
  </table>
<%
							End If
							sSiteID = rs("SiteID").toString()
							sTypeID = rs("TypeID").toString()
							' Show the Site Name, if there is a name
%>
<div class="DateHeader">
<%
							If sSiteID.toString() = "0" Then
									Response.write("Public Groups")
							Else
									Response.write(rs("SiteName").toString() & " Only")
							End If
%>
</div>
<% ' Start a new table %>
<table class="Data" cellpadding="0" cellspacing="0">
<%
					End If
%>
	<tr<% If rs("NumNewMessages") > 0 Then %> class="Highlight"<% End If %>>
		<td class="Row" onClick="window.location.href='../Dashboard/Dashboard_DiscussionGroupComments.aspx?GUID=<%=B64UserID%>&GroupID=<%=PageHelper.EncodeIntegerToString(rs("GroupID"))%>';" style="cursor:pointer;">
			<div class="Title"><%=HttpUtility.HtmlEncode(rs("Title"))%> (<%=rs("MessageCount")%><% If rs("NumNewMessages") > 0 Then %>, <%=rs("NumNewMessages")%> new<% End If %>)</div>
				<div class="Date">
				<% If rs("MessageCount") > 0 Then %>
					Last post: <%=FormatDateString(rs("MessagePostedOn").toString(), System.DateTime.Now.toString())%>
				<% End If %>
				</div>
		</td>
	</tr>
<%
			End While
%>
	</table>
	<% Else %>
	<p>Please enter discussion Groups</p>
	<% End If 
	rs.Close()

Else
        Dim bIsPublic As Boolean = False
        Dim sSiteName As String = ""
        Dim dt As System.Data.DataTable = GetGroups(UserData.DiscussionList.toString(), sGender, True, True, False)
        
        ' Create a select box of counts but have the current discussion selected
%>
  <form action="ListGroups.aspx" name="dgForm">
  <div id="CategorySelect">
    <select name="GroupID" onChange="document.dgForm.submit();">
      <option value="-1">All</option>
      <%
                         For Each Row in dt.Rows
                  %>
                        <option value="<%=Row("GroupID")%>"<%
                                If Row("GroupID") = nGroupID Then
                                        ' Save the Group's publicity
                                        bIsPublic = (Row("SiteID").toString() = "0")
                                        sSiteName = Row("SiteName").toString()
                                %> selected="selected"<%
                                End if
                        %>><%=HttpUtility.HtmlEncode(Row("Title"))%> (<%=Row("MessageCount")%>)</option>
                <%
                        Next
                %>
    </select>
  </div>
  <input type="hidden" name="GUID" value="<%=B64UserID%>" />
  </form>
  <div class="Notice">This is a
  <% If bIsPublic Then %>
        Public
        <% Else If sSiteName <> "" Then %>
        <%=sSiteName%> Only
  <% Else %>
        Private
  <% End If %>
  group
  </div>
  
  
  
  
  
{% if nGroupID > 0%}
  <form name="dgForm">
  <div id="CategorySelect"> <b>Groups:</b>
  <p>
    <select name="DGGroupID" onChange="GetDiscussionPosts();">     
      {% for discussiongroup in discussiongroups %}
      <option value="{{ discussiongroup.id }}"
	  {% if discussiongroup.id == nGroupID %} selected="selected" {% endif %}>
	   {{ discussiongroup.title }} ({{ discussiongroup.MessageCount }})
	  </option>
      {% endfor %}
    </select>      
    <a href="#" onClick="document.getElementById('PostMsg').style.display='block';FocusText(); return false;" class="btn" {%if nGroupID == -1%}style="display:none;"{%endif%}>Post a message</a>
  </p>
  </form>
	<div id="PostMsg" style="display:none;width:65%;margin-left:5%;" class="OutLine">
	  <h2 class="LeftMargin_15px">Post a New Message</h2>	  				
	  <p class="LeftMargin_15px">
		<b>Title:</b>
		<input type="text" name="Title" id="Title" value="" maxlength="80" class="full" />
	  </p>
	  <p class="LeftMargin_15px">
		<b>Message:</b> <br/>
		<textarea name="Msg" id="Msg" style="width:50%;" wrap="soft"></textarea>
	  </p>
	  <p style="padding-bottom:10px;">
	  <input type="button" class="Blue-Button LeftMargin_15px" style="float:left" id="cancel" value="Cancel" onclick="document.getElementById('Title').value='';document.getElementById('Msg').value='';document.getElementById('PostMsg').style.display='none';">
	  
	  <input type="button" class="Blue-Button LeftMargin_15px" style="float:left; margin-left:225px;" id="post" value="Post" onclick="Validate();return false;">
	   <span id="LoadingText" style="display:none;float:left; margin-left:225px;">Loading...</span>
	  
	  </p>
	 <br>
	</div>
	<div id="msg-sent-status" class="alert"></div>
  </div>  
 
 {% if discussionposts|length > 0 %}
 <p>
 {% set count = 0 %}
  <table class="Diff-Row-Border-Table" cellpadding="0" cellspacing="0">
	{% for discussionpost in discussionposts %}
    <tr {% if count % 2 == 0 %}class="altRow"{% endif %}>	
	{% set count = count + 1 %}
	 <td class="td-icon" onClick="if(confirm(""Are you sure you want to delete this topic?"")) {window.location.href=""/dashboard/deletemsg/{{ GUID }}/{{ discussiongroup.MsgID }}/{{ discussiongroup.nGroupID }}"";}" style="cursor:pointer;"><img src="/images/admin/icon-delete.png" alt="Delete" /></td>	
	 <td class="Row" onClick="window.location.href='/dashboard/discussiongroups/{{ nGroupID }}/{{ discussionpost.id }}';" style="cursor:pointer;">
	  <span>
      	<b>{{ discussionpost.title }}</b>
	 	<span style="float:right"><font color="#A0A0A0">{{ discussionpost.posted|date("m/d/Y") }}</font></span> 
      </span>      
	  <p>{{ discussionpost.text }}</p>
      </td>
    </tr>
    {% endfor %}
  </table>
</p>
 {% else %}
   <p>There are no messages in this Group.</p>  
 {% endif %}
{% else %}
	<p class="alert">	There are no groups that you are subscribed to. </p>
{% endif %}
{% endblock %}


{% block adminscript %}
<script type="text/javascript">
function Validate() {    
    var oTitle = document.getElementById("Title");
    oTitle.value=trimString(oTitle.value+"");
    if (oTitle.value == "") {
        alert("\n\nPlease type a Title for your message.\n\n");
        document.getElementById("Title").focus();
    } else {
        var oMsg = document.getElementById("Msg"); 
        oMsg.value = trimString(oMsg.value+"");
        if (oMsg.value=="") {
            alert("\nPlease type in the message you want to share!");
            document.getElementById("Msg").focus();
        } else {			
            document.getElementById("post").style.display="none";
            document.getElementById("LoadingText").style.display="block";
			var dgid = document.dgForm.DGGroupID.options[document.dgForm.DGGroupID.selectedIndex].value;
			var data = new Object();
			data['discussiongroupid'] = dgid;
			data['title'] = oTitle.value;
			data['msg']= oMsg.value;
			$.post('/dashboard/discussiongroupmsgsave', data, function(jqXHR, textStatus, errorThrown) {			
				if(textStatus == "success")
				{					
					document.dgForm.action = "/dashboard/discussiongroups/" + document.dgForm.DGGroupID.options[document.dgForm.DGGroupID.selectedIndex].value;
					document.dgForm.submit();
				}
				else
				{
					document.getElementById('Title').value='';
					document.getElementById('Msg').value='';
					document.getElementById("post").style.display="block";
					document.getElementById("LoadingText").style.display="none";
					document.getElementById('PostMsg').style.display='none';
					$('#msg-sent-status').html("Message sending failed");	
					setTimeout("document.getElementById('msg-sent-status').innerHTML='';", 3000);	
				}				
			});	        
        }
    }
}
function trimString(str) {
    return str.replace(/^\s+/g, "").replace(/\s+$/g, ""); 
}

function showPostForm() {
	try {
		document.getElementById("PostMsg").style.display = "block";
	} catch(e) {}
}

function FocusText(){
	try {
        document.getElementById("Title").focus();
	} catch(e) {}
}

function GetDiscussionPosts(){
	document.dgForm.action = "/dashboard/discussiongroups/" + document.dgForm.DGGroupID.options[document.dgForm.DGGroupID.selectedIndex].value;
	document.dgForm.submit();
}
</script>
{% endblock %}
