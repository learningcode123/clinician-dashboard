<script language="vb" runat="server">
Dim dt,dt2 As System.Data.DataTable
Dim dv,dv2 As System.Data.DataView

Dim nPatientID As Integer
Dim nCounselorID As Integer = 0
Dim sCounselorCode As String

Function cmMyPatientList(nCounselorID As Integer, sParam As String, useReader As Boolean)
    If useReader Then
        Return ExecuteReaderSP("_MobileUsers", "MyPatients", nCounselorID, sParam)
    Else
        Return ExecuteDataTableSP("_MobileUsers", "MyPatients", nCounselorID, sParam)
    End If
End Function

Function cmCounselorCode(nUserID)
    Return ExecuteScalar("SELECT CodeName FROM MobileUsers WHERE UserID=@UserID;", nUserID.ToString())
End Function

Function cmGetCounselorsList()
    Return ExecuteReader("SELECT * FROM MobileUsers WHERE UserTypeFlag& @Flag > 0", UTF_COUNSELOR)
End Function

Function cmCountMessages(sType As String, sFrom As String, sTo As String)
    Dim sql As String = "SELECT COUNT(*) FROM PrivateMessages WHERE MsgFrom=@sFrom AND MsgTo=@sTo"
    If sType.ToUpper() = "NEW" Then
        sql += " AND Received=0"
    End If
    Return ExecuteScalar(sql, sFrom, sTo)
End Function

Function GetAllPatientsList(useReader As Boolean)
    Dim sql As String = "SELECT * FROM MobileUsers WHERE Deleted=0 AND UserID <> @UserID"

    ' Only let Agency Admins message their own patients
    If UserIsSiteAdmin Then
        sql &= " AND SiteID = " & UserData.SiteID
    End If
    
    If useReader Then
        Return ExecuteReader(sql, nUserID)
    Else
        Return ExecuteDataTable(sql, nUserID)
    End If
End Function

Function GetMessageList(sType As String, sFrom As String, sTo As String)
    Dim sql As String = "SELECT MsgID,MsgFrom,MsgTo,MsgDate,Title FROM PrivateMessages WHERE MsgFrom=@sFrom AND MsgTo=@sTo"
    
    If sType.ToUpper() = "NEW" Then
        sql += " AND Received=0"
    End If
    
    Return ExecuteReader(sql+" ORDER By MsgDate DESC", sFrom, sTo)
End Function

Function GetMessageDetails(msgID As Integer)
    Dim sql As String = "SELECT MsgFrom,MsgTo,MsgDate,Title,Message FROM PrivateMessages WHERE MsgID = @msgID"
    Return ExecuteReader(sql, msgID)
End Function
</script>

<%
If UserIsPatient Then
    Response.Redirect("../Home/MainMenu.aspx?GUID="+B64UserID, True)
End If

If (Request("CounselorID")+"").Length > 0 Then
    nCounselorID = Request("CounselorID")
End If

If (Request("PTID")+"").Length > 0 Then
    nPatientID = PageHelper.DecodeStringToInteger(Request("PTID"), -1)
End If
%>