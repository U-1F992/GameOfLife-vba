Attribute VB_Name = "Module1"
'@Folder("VBAProject")
Option Explicit
Public Const px As Long = 10
Public Const Height As Long = 100
Public Const Width As Long = 100
Public Const OnColor As Long = 65280 'RGB(0,255,0)
Public Const OffColor As Long = 0

Sub SetCellsSizeSquare(ByVal Target As Range, ByVal px As Long)
    'Target.Cells(1, 1).Select
    Target.Clear
    
    Dim RatioHeight As Double: RatioHeight = 0.75
    Dim RatioWidth As Double: RatioWidth = 0.118
    
    Target.Cells(1, 1).RowHeight = px * RatioHeight
    Target.Cells(1, 1).ColumnWidth = px * RatioWidth
    
    '������x�ȉ��̏����Ȑ����`����낤�Ƃ����RowHeight��Row / ColumnWidth��Column�̒l���ꗂ�������悤�ɂȂ邽�߁A�L�����u���[�V����
    Do While Target.Cells(1, 1).Width > Target.Cells(1, 1).Height
        RatioWidth = RatioWidth - 0.001
    
        Target.Cells(1, 1).RowHeight = px * RatioHeight
        Target.Cells(1, 1).ColumnWidth = px * RatioWidth
        
        DoEvents
    Loop
    '�␳�����䗦��I��͈͂ɓK�p
    Target.RowHeight = px * RatioHeight
    Target.ColumnWidth = px * RatioWidth
    
End Sub

Sub SetCellsSizeDefault(ByVal ws As Worksheet)
    ws.Cells(1, 1).Select
    ws.Cells.Clear
    ws.Cells.RowHeight = 18.75
    ws.Cells.ColumnWidth = 8.38
End Sub

Sub Default()
    SetCellsSizeDefault ActiveSheet
End Sub
Sub Square()
    UnlockActiveSheet
    SetCellsSizeSquare ActiveSheet.Cells, 10
End Sub

'�Q�[�����p�������邩���肷��
'�S�ẴZ�������āA�����Z�������݂���ꍇ��True
Private Function GameContinue(ByVal Target As Range) As Boolean
    Dim Cell As Range
    For Each Cell In Target
        If Cell.Interior.Color = OnColor Then
            GameContinue = True
            Exit Function
        End If
    Next Cell
    GameContinue = False
End Function

'���C�t�Q�[��
    '�a�� - ����ł���Z���ɗאڂ��鐶�����Z�������傤��3����Τ���̐��オ�a������
    '���� - �����Ă���Z���ɗאڂ��鐶�����Z����2��3�Ȃ�Τ���̐���ł���������
    '�ߑa - �����Ă���Z���ɗאڂ��鐶�����Z����1�ȉ��Ȃ�Τ�ߑa�ɂ�莀�ł���
    '�ߖ� - �����Ă���Z���ɗאڂ��鐶�����Z����4�ȏ�Ȃ�Τ�ߖ��ɂ�莀�ł���
Sub Main()

    Dim i As Long, j As Long

    Dim t As New Timer
    '�V�[�g��������
    Initialize False
    Stop
    Cells(1, 1).Select
    LockActiveSheet
    
    Dim Buffer() As Byte: ReDim Buffer(1 To Height, 1 To Width)
    Dim Previous() As Byte: ReDim Previous(1 To Height, 1 To Width)
    Dim GameSpace As Range: Set GameSpace = Range(Cells(LBound(Buffer, 1), LBound(Buffer, 1)), Cells(UBound(Buffer, 1), UBound(Buffer, 2)))
    
    Dim Cell As Range
    
    '����Previous��p��
    For Each Cell In GameSpace
        If Cell.Interior.Color = OnColor Then Previous(Cell.Row, Cell.Column) = &HFF Else Previous(Cell.Row, Cell.Column) = &H0
    Next Cell
    
    Do While GameContinue(GameSpace)
        '�o�b�t�@��������
        ReDim Buffer(1 To Height, 1 To Width)
        
        't.StartTimer
        For i = LBound(Previous, 1) To UBound(Previous, 1)
            For j = LBound(Previous, 2) To UBound(Previous, 2)
                
                If Previous(i, j) = &HFF Then '�����Ă���ꍇ
                    Select Case Vicinity(Previous, i, j)
                        Case 2, 3
                            Buffer(i, j) = &HFF
                        Case Else
                            Buffer(i, j) = &H0
                    End Select
    
                ElseIf Previous(i, j) = &H0 Then '����ł���ꍇ
                    Select Case Vicinity(Previous, i, j)
                        Case 3
                            Buffer(i, j) = &HFF
                        Case Else
                            Buffer(i, j) = &H0
                    End Select
                End If
        
            Next j
        Next i
        
        'Debug.Print t.StopTimer
        '�`��̍X�V
        Application.ScreenUpdating = False
        UnlockActiveSheet
        UpdateScreen Buffer
        'LockActiveSheet
        Application.ScreenUpdating = True
        
        Previous = Buffer
        
        DoEvents
    Loop
End Sub

'�����_���ȏ����l��^����ꍇ��True
Public Sub Initialize(ByVal flag As Boolean)
    UnlockActiveSheet
    SetCellsSizeSquare ActiveSheet.Cells, px
    Range(Cells(1, 1), Cells(Height, Width)).Interior.Color = OffColor
    LockActiveSheet
    
    If Not flag Then GoTo Dispose
    
    Dim arr() As Byte
    ReDim arr(1 To Height, 1 To Width)
    Dim t As New Timer

    Dim i As Long, j As Long
    For i = 1 To Height
        For j = 1 To Width
            Randomize
            If Rnd > 0.9 Then arr(i, j) = &HFF Else arr(i, j) = &H0
            'Debug.Print i & ", " & j
        Next j
    Next i
    
    
    Application.ScreenUpdating = False
    UnlockActiveSheet
    UpdateScreen arr
    LockActiveSheet
    Application.ScreenUpdating = True
    
    DoEvents
    
Dispose:
    UnlockActiveSheet
End Sub

Public Sub UpdateScreen(ByRef Buffer() As Byte)
    
    Dim i As Long, j As Long
    
    Dim strRngOn As String, strRngOff As String
    strRngOn = "": strRngOff = ""
    Dim Cell As Range
    
    For Each Cell In Range(Cells(LBound(Buffer, 1), LBound(Buffer, 1)), Cells(UBound(Buffer, 1), UBound(Buffer, 2)))
        If Buffer(Cell.Row, Cell.Column) = &HFF Then
        
            'On�ɂ���A�h���X(String)���W�߂�
            'Range��255�����܂ł����󂯕t���Ȃ��̂ŁA255�����W�܂閈��Range.Interior.Color��ύX
            'Union�ɂ��Range�̌����́A�ЂƂ��F��ς�����x��
            If Len(strRngOn & Cell.Address) <= 255 Then
                strRngOn = strRngOn & "," & Cell.Address
            Else
                'strRngOn�̐擪�̃R���}���O��
                Range(Mid(strRngOn, 2)).Interior.Color = OnColor
                strRngOn = "," & Cell.Address
            End If
        Else
        
            If Len(strRngOff & Cell.Address) <= 255 Then
                strRngOff = strRngOff & "," & Cell.Address
            Else
                Range(Mid(strRngOff, 2)).Interior.Color = OffColor
                strRngOff = "," & Cell.Address
            End If
        End If
    Next Cell
    
    '�]���Range.Interior.Color��ύX
    If strRngOn <> "" Then Range(Mid(strRngOn, 2)).Interior.Color = OnColor
    If strRngOff <> "" Then Range(Mid(strRngOff, 2)).Interior.Color = OffColor
    
'    'fps���艻
'    '�`��͈͂��L���Ȃ�Ɗ��҂�����������Ȃ�
'    Dim t As New Timer
'    Dim dblWait As Double: dblWait = t.StartTimer
'    Dim f As Double: f = 0.3
'    Do While t.TakeLap - dblWait < f
'        DoEvents
'    Loop
    
End Sub

Public Sub LockActiveSheet()

    ActiveSheet.ScrollArea = ActiveSheet.UsedRange.Address
    ActiveSheet.Cells(1, 1).Select
    
    ActiveSheet.Cells.Locked = True
    ActiveSheet.Protect
    ActiveSheet.EnableSelection = xlUnlockedCells
End Sub

Public Sub UnlockActiveSheet()
    ActiveSheet.Unprotect
    ActiveSheet.Cells.Locked = False
    
    ActiveSheet.ScrollArea = ""
End Sub

Public Sub RCHidden()
'    Application.DisplayFullScreen = True
    ActiveWindow.DisplayGridlines = False
    Application.DisplayStatusBar = False
    ActiveWindow.DisplayWorkbookTabs = False
    ActiveWindow.DisplayHeadings = False
    Application.DisplayFormulaBar = False
    ActiveWindow.DisplayVerticalScrollBar = False
    ActiveWindow.DisplayHorizontalScrollBar = False
    If Application.CommandBars.GetPressedMso("MinimizeRibbon") = False Then Application.CommandBars.ExecuteMso "MinimizeRibbon"
'    Application.WindowState = xlMaximized
End Sub

Public Sub RCVisible()
    ActiveWindow.DisplayGridlines = True
    Application.DisplayStatusBar = True
    ActiveWindow.DisplayWorkbookTabs = True
    ActiveWindow.DisplayHeadings = True
    Application.DisplayFormulaBar = True
    ActiveWindow.DisplayVerticalScrollBar = True
    ActiveWindow.DisplayHorizontalScrollBar = True
    If Application.CommandBars.GetPressedMso("MinimizeRibbon") Then Application.CommandBars.ExecuteMso "MinimizeRibbon"
'    Application.DisplayFullScreen = False
'    Application.WindowState = xlNormal
End Sub

'�ߖT�̐����Z����
Public Function Vicinity(ByRef Buffer() As Byte, ByVal i As Long, ByVal j As Long) As Long

    Vicinity = 0
    
    If i > LBound(Buffer, 1) Then
        If j > LBound(Buffer, 2) Then
            If Buffer(i - 1, j - 1) = &HFF Then Vicinity = Vicinity + 1 '����
        End If
        
        If j < UBound(Buffer, 2) Then
            If Buffer(i - 1, j + 1) = &HFF Then Vicinity = Vicinity + 1 '�E��
        End If
        
        If Buffer(i - 1, j) = &HFF Then Vicinity = Vicinity + 1 '��
    End If
    
    If i < UBound(Buffer, 1) Then
        If j > LBound(Buffer, 2) Then
            If Buffer(i + 1, j - 1) = &HFF Then Vicinity = Vicinity + 1 '����
        End If
        
        If j < UBound(Buffer, 2) Then
            If Buffer(i + 1, j + 1) = &HFF Then Vicinity = Vicinity + 1 '�E��
        End If
        
        If Buffer(i + 1, j) = &HFF Then Vicinity = Vicinity + 1 '��
    End If
    
    If j > LBound(Buffer, 2) Then
        If Buffer(i, j - 1) = &HFF Then Vicinity = Vicinity + 1 '��
    End If
    
    If j < UBound(Buffer, 2) Then
        If Buffer(i, j + 1) = &HFF Then Vicinity = Vicinity + 1 '�E
    End If
End Function
