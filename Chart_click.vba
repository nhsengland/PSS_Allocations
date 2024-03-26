Option Explicit

Private Sub Chart_Activate()

End Sub

Private Sub Chart_MouseUp(ByVal Button As Long, ByVal Shift As Long, _
        ByVal x As Long, ByVal y As Long)
 
    Dim ElementID As Long, Arg1 As Long, Arg2 As Long
    Dim myX As Variant, myY As Double
 
    With ActiveChart
        ' Pass x & y, return ElementID and Args
        .GetChartElement x, y, ElementID, Arg1, Arg2
               
        ' Did we click over a point or data label?
        If ElementID = xlSeries Or ElementID = xlDataLabel Then
            If Arg2 > 0 Then
                ' Extract x value from array of x values
                myX = WorksheetFunction.Index _
                    (.SeriesCollection(Arg1).XValues, Arg2)
                ' Extract y value from array of y values
                myY = WorksheetFunction.Index _
                    (.SeriesCollection(Arg1).Values, Arg2)
 
                ' Display message box with point information
                If Arg1 = 1 Then
                MsgBox Sheet98.Range("T3").Value & vbCrLf _
                    & vbCrLf _
                    & Sheet98.Range("R3").Value & vbCrLf _
                    & Sheet98.Range("S3").Value & vbCrLf _
                    & vbCrLf _
                    & "Cancer spend per head of population = " & Format(Sheet98.Range("U3").Value, "£#,##") & vbCrLf _
                    & "Cancer patients per 100k pop = " & Format(myX, "#,##0") & vbCrLf _
                    & "Cancer spend per patient = " & Format(myY, "£#,##"), vbInformation, "Chart Information"
                ElseIf Arg1 = 2 Then
                MsgBox Sheet98.Range("R4:U13").Cells(Arg2, 3).Value & vbCrLf _
                    & vbCrLf _
                    & Sheet98.Range("R4:U13").Cells(Arg2, 1).Value & vbCrLf _
                    & Sheet98.Range("R4:U13").Cells(Arg2, 2).Value & vbCrLf _
                    & vbCrLf _
                    & "Cancer spend per head of population = " & Format(Sheet98.Range("R4:U13").Cells(Arg2, 4).Value, "£#,##0") & vbCrLf _
                    & "Cancer patients per 100k pop = " & Format(myX, "#,##0") & vbCrLf _
                    & "Cancer spend per patient = " & Format(myY, "£#,##"), vbInformation, "Chart Information"
                End If
            End If
        End If
    End With

End Sub
