<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<!--#include File="../Globals/Globals.aspx" --> 
<!--#INCLUDE FILE="Dashboard_Header.aspx"-->

<% sServiceTitle = "Dashboard Home" %>
<%
	Dim rs As System.Data.SqlClient.SqlDataReader = ExecuteReaderSP("","List")
	Dim NumUsers As Integer = 0
	Dim StartDate As String
%>

<div class="RightContentDiv">
<form id="Patients" name="Patients" action="Dashboard_Patients.aspx" method="post">  
<div id="PatientsMain" class="DivOuter"> 
	<div id="PatientMainInner" class="DivInner" > 
      <h2><%=UserData.FirstName%> <%=UserData.LastName%>'s patients</h2>
      <div>
      Sort by: <a id="firstlastname" href="#" onClick="loadPatients('firstlastname');return false;" color="#8F0099">name</a> | 
               <a id="redpin" href="#" onClick="loadPatients('redpin');return false;">red pin</a> | 
               <a id="activesince" href="#" onClick="loadPatients('activesince');return false;">active since</a>
      </div>
      <div id="PatientList">
        <em>Loading Patients...</em>
      </div>
 	</div>
</div>
</form>
</div>

<script type='text/javascript' src='jsInclude/jquery-1.7.2.min.js'></script>
<script type='text/javascript' src='jsInclude/SimpleModal/simplemodal.1.4.2.min.js'></script>
<link rel="stylesheet" href="jsInclude/SimpleModal/simplemodal.css" />

<script type="text/javascript" src="../AJAX/ajax.js"></script>
<script type="text/javascript">
/*
** Desc:   Calls LoadPatients.aspx to load a list of patients from the DB
** Params: orderBy - column name to sort workshops by
*/
function loadPatients(orderBy) {		
	var firstlastname = document.getElementById("firstlastname");
	var redpin = document.getElementById("redpin");
	var activesince = document.getElementById("activesince");
	
	if(orderBy == "redpin")
	{
		firstlastname.style.color = "#006699";
		redpin.style.color = "#8F0099";
		activesince.style.color = "#006699";
	}
	else if(orderBy == "activesince")
	{
		firstlastname.style.color = "#006699";
		redpin.style.color = "#006699";
		activesince.style.color = "#8F0099";
	}
	else//(orderBy == "name") or orderBy = ""=>default
	{
		firstlastname.style.color = "#8F0099";
		redpin.style.color = "#006699";
		activesince.style.color = "#006699";
	}
		
var  s="";
    var ajax = AJAXRequest("post","../Dashboard/LoadPatients.aspx?orderBy="+orderBy,s,updateContent,null,"PatientList");
}


loadPatients("");
</script>
<!--#INCLUDE FILE="../Include/Footer-Admin.aspx"-->