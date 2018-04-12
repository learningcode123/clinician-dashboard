<%@ Page Language="vb" Inherits="chess.wisc.edu.AnonymousPage" trace="false" %>
<style>
.blue a.ui-state-default {
    background-color: blue;
    background-image: none;
}
.red  a.ui-state-default{
    background-color: red;
    background-image: none;
}
.green  a.ui-state-default{
    background-color: green;
    background-image: none;
}
</style>

<div id="depart">
</div>


 <link rel="stylesheet" href="http://code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
  <script src="http://code.jquery.com/jquery-1.9.1.js"></script>
  <script src="http://code.jquery.com/ui/1.10.4/jquery-ui.js"></script>
<script type="text/javascript">
var blueDates = ['12-30-2013', '1-04-2014', '1-29-2014'];
var greenDates = ['12-29-2013', '1-22-2014'];
var redDates = ['1-5-2014', '1-13-2014'];

$('#depart').datepicker({ 
	beforeShowDay: highlightDays
});

function highlightDays(date) {
    mdy = (date.getMonth() + 1) + '-' + date.getDate() + '-' + date.getFullYear();
    console.log(mdy);
    if ($.inArray(mdy, blueDates) > -1) {
        return [true, "blue"];
    } else if ($.inArray(mdy, greenDates) > -1) {
        return [true, "green"];
    } else if ($.inArray(mdy, redDates) > -1) {
        return [true, "red"];
    } else {
        return [true, ""];
    }
}
</script>