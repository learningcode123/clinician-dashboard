{% extends "dashboard.twig" %}

{% block adminbody %}
<p><a href="/dashboard/discussiongroups/{{ discussiongroupid }}"><b><< Back</b></a></p>
  <form name="dcForm" action="/dashboard/discussiongroups/{{ discussiongroupid }}/{{ discussionpostid }}">
  <div>
  	<h2>Post: </h2>
	<div class="OutLine altRow" style="width:75%;">
		<input type="hidden" name="dgid" value="{{ discussiongroupid }}">
		<input type="hidden" name="dpid" value="{{ discussionpostid }}">
		<div style="margin-left:5px;">
			<b>{{ discussionpost.title }}</b></br>
			<p>{{ discussionpost.text }}</p>
		</div>
	</div>
  </div><br/>
 <h2>Comments: </h2>  
 <a href="#" onClick="document.getElementById('PostComment').style.display='block';FocusText(); return false;" class="btn" {%if nGroupID == -1%}style="display:none;"{%endif%}>Post a comment</a></br>	
  <div id="PostComment" style="display:none;">
	  <p class="LeftMargin_15px">		
		<textarea name="CommentText" id="CommentText" style="width:50%;" wrap="soft"></textarea>
	  </p>
	  <p>
	  <input type="button" class="Blue-Button LeftMargin_15px" id="cancel" value="Cancel" style="float:left" onclick="document.getElementById('CommentText').value='';document.getElementById('PostComment').style.display='none';" style="display: block;">
	  <input type="button" class="Blue-Button LeftMargin_15px" id="post" value="Post" onclick="Validate({{ discussionpostid }}, {{ discussiongroupid }});return false;" style="display: block;margin-left:530px">
	  <span id="LoadingText" style="display:none;margin-left:250px">Loading...</span>
	  </p>
  </div>
  <p>
 {% if discussionpostcomments|length > 0 %}  	
	{% set count = 0 %}
	<table class="Diff-Row-Border-Table" cellpadding="0" cellspacing="0">
  	{% for discussionpostcomment in discussionpostcomments %}		
		<tr {% if count % 2 == 0 %}class="altRow"{% endif %}>
		{% set count = count + 1 %}	
		 <td
		 <span>
			<b>{{ discussionpostcomment.username }}</b>
			<span style="float:right"><font color="#A0A0A0">{{ discussionpostcomment.posted|date("m/d/Y") }}</font></span> 
		  </span>   
     	  <p>{{ discussionpostcomment.text }}</p>
		 </td>
		</tr>
	{% endfor %}
	</table>
 {% else %}
   <table class="Diff-Row-Border-Table" cellpadding="0" cellspacing="0">
    <tr class="altRow">
     <td>
 	  <p class="alert">There are no comments for this post.</p> 
	 </td> 
	</tr>
   </table>
 {% endif %}
 </p>
{% endblock %}


{% block adminscript %}
<script type="text/javascript">
function Validate(dpid,dgid) {    
   var oCommentText = document.getElementById("CommentText");
   oCommentText.value = trimString(oCommentText.value+"");
   if (oCommentText.value=="") {
		alert("\nPlease enter comment that you want to share!");
		document.getElementById("CommentText").focus();
   } 
   else {
		document.getElementById("post").style.display="none";
		document.getElementById("LoadingText").style.display="block";		
		var data = new Object();
		data['discussionpostid'] = dpid;
		data['discussiongroupid'] = dgid;
		data['commenttext'] = oCommentText.value;
		$.post('/dashboard/discussionpostcommentsave', data, function(jqXHR, textStatus, errorThrown) {
			if(textStatus == "success")
			{									
				document.dcForm.submit();
			}						
		});	        
	}
}

function trimString(str) {
    return str.replace(/^\s+/g, "").replace(/\s+$/g, ""); 
}

function FocusText(){
	try {
        document.getElementById("CommentText").focus();
	} catch(e) {}
}
</script>
{% endblock %}
