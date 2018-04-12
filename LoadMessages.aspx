<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage"%>
<!--#include File="../Globals/Globals.aspx" --> 
<!-- Called ajaxically to load a list of messages for counselor's patient -->
        
<% If Request("Msg") IsNot Nothing AndAlso Request("Msg") <> "" Then %>
    <p id="AlertMsg" class="Alert"><%=Server.HtmlDecode(Request("Msg"))%></p>
    <script type="text/javascript">
      setTimeout("document.getElementById('AlertMsg').innerHTML='';", 5000);
    </script>
<% End If %>
<%
Dim nSubUserID =""
If Request("UserID")+"" <> "" Then
	nSubUserID = Request("UserID")
End If
%>
    <table class="tableRight BlueOutLine" cellspacing="0" cellpadding="0">
    <tr>
      <td colspan="2" style="text-align:left;">
        <span id="WriteToSpan<%=nSubUserID%>" style="cursor:pointer;color:#006699;" onclick="ShowWriteTextArea('WriteToUserDiv<%=nSubUserID%>');">Write New Message</span>
         <div style="display:none;width:500px;" id="WriteToUserDiv<%=nSubUserID%>">
             <h3>New Message:</h3>
             <b>Subject: </b><input type="Text" id="SubjectWriteToUser<%=nSubUserID%>" /></br>
             <b> Message: </b></br>
             <textarea id="WriteToUser<%=nSubUserID%>" rows="4" cols="50"></textarea>
             <p>
             <input type="button" id="btnSendWrite" class="Blue-Button" value="Send" onclick="ValidateNewMsg(<%=nSubUserID%>,'<%=MyCodeName(nSubUserID)%>');return false;" />			 
             <input type="button" id="btnCancelWrite" class="Blue-Button" value="Cancel" onclick="document.getElementById('SubjectWriteToUser<%=nSubUserID%>').value='';document.getElementById('WriteToUser<%=nSubUserID%>').value='';document.getElementById('WriteToUserDiv<%=nSubUserID%>').style.display='none';" style="margin-left:150px;"/>
             </p>			 
         </div>	
      </td>
     </tr>
     </table>
     <table class="tableRight BlueOutLine" style="border-left:1px solid #006699 !important;" cellspacing="0" cellpadding="0">
    <%
    Dim nImageID As Integer= 0
    'If Request("ImageID")+"" <> "" Then
    '	nImageID = Request("ImageID")
    'End If
    
    oDataTable = ExecuteDataTableSP("_DashboardData", "MsgListToMe", nUserID, nSubUserID)
    Dim dv As System.Data.DataView = oDataTable.DefaultView
    
    n = 0
    Dim fromScreenName As String
    Dim bNewMsg As Boolean = False
    
    For i=0 To dv.Count-1%>
      <%
      bNewMsg = Not dv(i)("Received")
      nImageID = dv(i)("ImageID")
      fromScreenName = FullNameByName( dv(i)("MsgFrom") )
	  
      n += 1
      %>
    
      <tr class="Row">    
        <td width="10%">    
         <%If nImageID > 0 Then%> 
          <a href="UserReports.aspx?PID=<%=PageHelper.EncodeIntegerToString(nUserID)%>">      
             <img src="../MyPhotos/LoadImage.aspx?GUID=<%=B64UserID%>&thn=1&IID=<%=PageHelper.EncodeIntegerToString(nImageID)%>" 
             alt="UserImage" />
          </a><br />
          <%Else%>
           <a href="UserReports.aspx?PID=<%=PageHelper.EncodeIntegerToString(nUserID)%>">           
             <img width="60" height="80" src="../Images/Users/no-img-vert.gif" alt="No Photo" />
           </a><br />
          <%End If%>
        </td>
        <td style="text-align:left;">
         <span>
          <b>From: <%=fromScreenName%></b>
		  <%If bNewMsg And Server.HtmlDecode(dv(i)("MsgFrom")) = MyCodeName(nUserID) Then%>(Not seen by client yet)<%End If%>
		  <%If bNewMsg And Server.HtmlDecode(dv(i)("MsgFrom")) <> MyCodeName(nUserID) Then%><span id="markAsNew_<%=dv(i)("MsgFrom")%>_<%=i+1%>">(NEW)</span><%End If%>
          <span style="float:right"><font color="#A0A0A0"><%=Format(dv(i)("MsgDate"),"dd MMM yy, hh:mmtt ")%></font></span> 
         </span>
         <p>Subject: <%=Server.HtmlDecode(dv(i)("Title"))%></p>
         <p>Message: <%=Server.HtmlEncode(dv(i)("Message"))%></p>
		 <p><%If bNewMsg And Server.HtmlDecode(dv(i)("MsgFrom")) <> MyCodeName(nUserID) Then%><a href="#" style="text-decoration:none;" onclick="document.getElementById('markAsNew_<%=dv(i)("MsgFrom")%>_<%=i+1%>').style.display='none'; this.style.display='none'; AJAXRequest('post','Dashboard_Message_MarkAsRead.aspx?MsgID=<%=dv(i)("MsgID")%>', null,null,null,''); document.getElementById('nnpm_<%=nSubUserID%>').innerHTML = parseInt(document.getElementById('nnpm_<%=nSubUserID%>').innerHTML, '10') - 1; if (parseInt(document.getElementById('nnpm_<%=nSubUserID%>').innerHTML, '10') <= 0) { document.getElementById('nnpmd_<%=nSubUserID%>').style.display='none'; } return false;">Mark as Read</a><%End If%></p>
          <% If Server.HtmlDecode(dv(i)("MsgFrom")) = MyCodeName(nSubUserID) Then %>
          
          <div id="ReplyDiv">
              <p>
              <span id="replyToSpan<%=dv(i)("MsgFrom")%>_<%=i+1%>" style="cursor:pointer;color:#006699;" onclick="ShowReplyTextArea('replyToUserDiv<%=dv(i)("MsgFrom")%>_<%=i+1%>'); this.style.display = 'none';">Reply</span>
			  </p>
              
              <div style="display:none;" id="replyToUserDiv<%=dv(i)("MsgFrom")%>_<%=i+1%>">
                 <b>Subject: </b><input type="Text" id="replyToUserTitle<%=dv(i)("MsgFrom")%>_<%=i+1%>" value="<%=Server.HtmlDecode(dv(i)("Title"))%>"/></br>
                 <b> Message: </b></br>
                 <textarea id="replyToUser<%=dv(i)("MsgFrom")%>_<%=i+1%>" rows="4" cols="50"></textarea>
                 <p>
                 <input type="button" id="btnSend" class="Blue-Button" value="Send" onclick="Validate(<%=dv(i)("MsgID")%>,'<%=dv(i)("CodeName")%>','<%=dv(i)("MsgFrom")%>_<%=i+1%>');return false;" />
                 <input type="button" id="btnCancel" class="Blue-Button" value="Cancel" onclick="document.getElementById('replyToSpan<%=dv(i)("MsgFrom")%>_<%=i+1%>').style.display='inline-block'; document.getElementById('replyToUserTitle<%=dv(i)("MsgFrom")%>_<%=i+1%>').value='<%=Server.HtmlDecode(dv(i)("Title"))%>';document.getElementById('replyToUser<%=dv(i)("MsgFrom")%>_<%=i+1%>').value='';document.getElementById('replyToUserDiv<%=dv(i)("MsgFrom")%>_<%=i+1%>').style.display='none';" style="margin-left:150px;" /> 
                 </p>
              </div>	
          </div>
          
          <% End If %>  
        </td>
      </tr>
    <%Next%>
    <%oDataTable.Dispose()%>
    <%If n = 0 Then%>
        <tr><td colspan="3" style="text-align:left;"><h2>No messages from <%=FullNameByID(nSubUserID).Trim()%>.</h2></td></tr>
    <%End If%>
    <div id="msg-content"></div>
    </table>
<%
' Mark all messages to Counselor as read

%>
<!-- **************** End Content **************** -->
