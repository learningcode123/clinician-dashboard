<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>Counselor Dashboard: <%=sServiceTitle%></title>
<style type="text/css" media="screen">@import "../CSS/dashboard-styles.css";</style>
<style type="text/css" media="screen">@import "../CSS/admin-styles.css";</style>
<style type="text/css" media="print">@import "../CSS/admin-print.css";</style>

<!--<link type="text/css" href="../css/ui-lightness/jquery-ui-1.8.10.custom.css" rel="stylesheet" />-->
</head>

<%
If Not (UserIsSuperAdmin OrElse UserIsSiteAdmin OrElse UserIsCounselor) Then
        Response.Redirect("../Home/MainMenu.aspx?GUID=" & B64UserID)
End If
%>

<body>
<div id="Skiplinks">
  <a href="#MainMenu">Skip to Main Menu</a> | <a href="#MainContent">Skip to Main Content</a>
</div>

<div id="Page">
	<div id="Banner">
	<div id="BannerTitle">
		<a href="../Dashboard/Dashboard_Home.aspx?GUID=<%=B64UserID%>" title="Admin Home">Counselor Dashboard</a>
	</div>
	<div id="BannerMenu">
		<h3 id="BannerMenuTitle">Welcome, <%=UserData.FirstName%> <%=UserData.LastName%></h3>
		<span><a href="../Login/LogOut.aspx">Logout</a></span>
	</div>
</div>

<div id="Main">
	<div id="SidebarMenu" style="width:175px">   
		<h3 class="title">Menu</h3>
		<ul>
			<li><a href="Dashboard_Home.aspx">Home</a></li><br />
			<li><a href="Dashboard_Messages.aspx">Messages</a></li><br />
			<li><a href="Dashboard_Settings.aspx">Settings</a></li><br />
			<li><a href="Dashboard_Patients.aspx">Patients</a></li><br />
			<li><a href="../DR/ListGroups.aspx">Discussion Groups</a></li><br />
			<li><a href="../Home/MainMenu.aspx?GUID=<%=B64UserID%>">A-CHESS Main Menu</a></li><br />
			<% If UserIsSiteAdmin() Or UserIsSuperAdmin Then %>
			<li><a href="../Admin/Users.aspx?GUID=<%=B64UserID%>">A-CHESS Administration</a></li><br />
			<% End If %>
		</ul>      
	</div><!--Close SidebarMenu-->

	<div id="Content" style="margin-left:200px">
