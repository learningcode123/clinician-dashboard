<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" Debug="false" %>

<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->
<!--#INCLUDE FILE="DashboardFunctions.aspx"-->

<%
Dim SelectedUserID As Integer = PageHelper.DecodeStringToInteger(Request("PID"), -1)
'Dim SelectedUserID As Integer = 0
'If (Request("SelectUserID")+"").Length > 0 Then
'	SelectedUserID = Request("SelectUserID")+""
'End If

Server.ScriptTimeout = 60*5

Dim nSiteID As Integer

Dim sStartDate, sEndDate As String
sStartDate =  DateTime.Now.AddMonths(-2).ToString("M/d/yyyy")
sEndDate = DateTime.Now.ToString("M/d/yyyy")

Dim Series1, Series2, Series3,  xAxis As String
Dim oSerializer1 As JavaScriptSerializer = new JavaScriptSerializer()
xAxis = oSerializer1.Serialize( xAxisData() )

Series1 = oSerializer1.Serialize( yAxisData(0) )
Series2 = oSerializer1.Serialize( yAxisData(1) )
Series3 = oSerializer1.Serialize( yAxisData(2) )

%>

<!--#INCLUDE FILE="./jsInclude.aspx"-->

	<h1>Patient Summary</h1>
    


	<div class="DivOuter" style="width:100%;">	<!--Begin OutLine Div-->
    
   	 <div style="float:left;width:68%;">
     	<!--Begin Left Div-->
   	 	
        <div>	<!--Begin Users DropDown Div-->
            <p>Select User: &nbsp;		 
                <select name="User" id="User" onChange="reloadDivs()">	
                    <option value="0">All users</option>				
                    <% 
						Dim sCommandName As String = "PatientsInfo"
                        Dim dt As System.Data.DataTable
						If UserIsCounselor() Then
							dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "counselor")
						Else
							dt = ExecuteDataTableSP("_DashboardData", sCommandName, nUserID, 0, "admin")
						End If
						
                        Dim dv As System.Data.DataView = dt.DefaultView
                        'If we want to exclude SELF, uncomment this:
                          dv.RowFilter = "UserID <> " & nUserID
                        
                          n = dv.Count - 1
                          For i=0 To n
                    %>
                    <option value="<%=dv(i)("UserID")%>" <% If SelectedUserID = dv(i)("UserID") Then %>selected="selected"<% End If %>><%=dv(i)("FirstName") & " " & dv(i)("LastName")%></option>
                    <% Next %>
                </select>			
            </p>
        </div>	<!--End Users DropDown Div-->

        <div>	<!--Begin Start, End Dates Div-->
        
        
            <p>
                Dates <span style="padding-left:1.1em;" >
                    <input type="text" id="StartDate" name="eStartDate" value="<%=sStartDate%>" maxlength="25" /> to
                    <input type="text" id="EndDate" name="eEndDate" value="<%=sEndDate%>"  maxlength="25" />
                    &nbsp;
                    <input type="button" onClick="loadWeeklySurvey();" value="Reload Chart"/>
                </span>
            </p>		
        </div>	<!--End Start, End Dates Div-->
    
        <div style="width:100%; display:block; padding:10px; overflow:auto">	<!--Begin BAM List, Msgs Div-->
            <div style="float:left;width:360px; margin-right:20px;">Brief Alcohol Monitor (BAM): </br>	<!--Begin BAM List on Left-->			
                <input type="hidden" id="MouseOption" value="" />
                 <ul>
                    <li style="list-style-type:none;">
                     <input type="checkbox" id="chkSurveyQuestion_OA" checked="checked" />&emsp;&emsp;&emsp;<label for="chkSurveyQuestion_OA" class="inline"> <!--onMouseOver="MouseOverEvent('OA');"-->OVER ALL</label>
                    </li>
                    <%rs = ExecuteReader("SELECT FieldName,ShortName FROM WeeklySurveyList")%>                     
                    <%While rs.Read()%>
                        <li style="list-style-type:none;">
                            <input type="checkbox" id="chkSurveyQuestion_<%=rs("FieldName")%>" />&emsp;&emsp;&emsp;<label for="chkSurveyQuestion_<%=rs("FieldName")%>" class="inline"> <!--onMouseOver="MouseOverEvent('<%=rs("FieldName")%>');"--><%=rs("ShortName")%></label>
                        </li>
                    <%End While%>
                    &nbsp;
                    <input type="button" onClick="loadWeeklySurvey();" value="Reload Chart"/>
                  	<%rs.Close()%>
                 </ul>
            </div>	<!--End BAM List on Left-->		
        </div>	<!--End BAM List, Msgs Div-->
        
        <div style="border-top:solid 1px #cde;margin-top:1em; margin-right:1px;">

			<div id="wschart"></div>		<!--Begin, End HighChart Div-->

		</div><!--End Border around chart-->

   </div>	<!--End Left Div-->


  
   <div style="float:right;width:30%;margin-right:1px; background-color:#efefef;">	

   <!--Begin Right Div-->
   


   	<div style="padding:10px; margin:10px; background-color:#fff;">	<!--Begin Correspondence-->

        <label for="UserCounselor_Msgs_Div"><strong> Correspondence </strong></label>

        <div style="height:550px; overflow: auto; padding:5px 10px; border:1px solid #efefef;">	<!--Begin Msgs Div on Right-->		
            </br>	
            <div id="UserCounselor_Msgs_Div">	<!--Begin Inner bordered Msgs Div-->		        	
        
            </div>	<!--End Inner bordered Msgs Div-->	
        </div>	<!--End Msgs Div on Right-->	
        
        <% If SelectedUserID > 0 Then %>


        <div style="padding:5px 10px; margin:0px 0px 20px 0px;">		

        <!-- Begin Write Message Div-->
				<span id="WriteToSpan" style="cursor:pointer;color:#006699;" onClick="HideControl('WriteToSpan');ShowControl('WriteToUserDiv');">Write New Message</span>

				 <div style="display:none;" id="WriteToUserDiv">

					 <h3>New Message:</h3>
                     <b>Subject: </b><input type="Text" id="SubjectWriteToUser" />
                     <br>
					 <b> Message: </b><br>

					 <textarea id="WriteToUser" rows="4" cols="30"></textarea>

					 <p>
						 <input type="button" id="btnSendWrite" class="Blue-Button" style="float:left;" value="Send" onClick="ValidateNewMsg();return false;">

						 <input type="button" id="btnCancelWrite" class="Blue-Button" style="float:left; margin-left:20px;" value="Cancel" onClick="document.getElementById('SubjectWriteToUser').value='';document.getElementById('WriteToUser').value=''; HideControl('WriteToUserDiv');ShowControl('WriteToSpan');" />	

					 </p>
 <br class="clearfix"> 
			    </div>
			   <div id="msg-sent-status" class="alert"></div>			 
			</div>	<!-- End Write Message Div-->
         <% End If %>
         
       </div>	<!--End Correspondence-->


       
       <% 
	   		Dim CheckUsertypeFlag As Integer
		    rs = GetUserRecord(SelectedUserID, True)
			If rs.Read Then
				CheckUsertypeFlag = rs("UserTypeFlag")				
			End If
			rs.Close()
	   %>
              
   </div>	<!--End Right Div-->
   
	<div style="clear:both;"></div>
    </div>	<!--End OutLine Div--> 

<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->

<link rel="stylesheet" href="//code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
<script src="//code.jquery.com/jquery-1.10.2.js"></script>
<script src="//code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
<script>

  $(function() {
    $( "#StartDate" ).datepicker();
	$( "#EndDate" ).datepicker();
  });
	
	function ValidateNewMsg(){
		var selUserID = document.getElementById("User").options[document.getElementById("User").selectedIndex].value;		
		var divID = 'WriteToUserDiv';		
		var NewSubject = document.getElementById('SubjectWriteToUser').value;
		var NewText = document.getElementById('WriteToUser').value;
		NewText = trimString(NewText);
		NewSubject = trimString(NewSubject);
		if(NewSubject == ""){
				alert("\nPlease type a subject.\n");
				document.getElementById('SubjectWriteToUser').focus();
			}
		 else { 
			if (NewText == "") {
				alert("\nPlease type a message.\n");
				document.getElementById('WriteToUser').focus();
			}
			else
			{	
				var sData = "MsgTo=&Title="+NewSubject+"&Msg="+NewText + "&ToMsgID="+selUserID+"&from_Page=user_reports";
				
				$.ajax({
					url: "../Dashboard/Dashboard_Messages_Save.aspx",
					data: sData,
					cache: false,
					success: function(result) {	
						if(result = "success")
						{
							document.getElementById('SubjectWriteToUser').value='';
							document.getElementById('WriteToUser').value='';
							HideControl('WriteToUserDiv');
							ShowControl('WriteToSpan');		
							$('#msg-sent-status').html('Messages sent successfully');
							setTimeout("$('#msg-sent-status').html('');", 3000);
							loadUserMsgs();
						}
					}
				});	
			} 		        
		}
	}	
	
	function trimString(str) {
		return str.replace(/^\s+/g, '').replace(/\s+$/g, ''); 
	}
		
</script>