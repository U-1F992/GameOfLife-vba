Attribute VB_Name = "Module1"
'@Folder("VBAProject")
Option Explicit
Public Const px As Long = 10
Public Const Height As Long = 100
Public Const Width As Long = 100
Public OnColor As Byte
Public Const OffColor As Byte = &H0

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
        If Cell.Interior.Color = HEX2RGB(OnColor) Then
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
    Dim seed As Long: seed = 0: OnColor = GenerateRainbow(seed)
    Dim PrevOnColor As Byte: PrevOnColor = OnColor

    'fps�����肳������
    Dim t As New Timer
    Dim f As Double: f = 0.05
    
    '�V�[�g��������
    Initialize False
    Range(Cells(1, 1), Cells(Height, Width)).Interior.Color = HEX2RGB(OffColor)
    Stop
    Cells(1, 1).Select
    LockActiveSheet
    
    Dim Buffer() As Byte: ReDim Buffer(1 To Height, 1 To Width)
    Dim Previous() As Byte: ReDim Previous(1 To Height, 1 To Width)
    Dim GameSpace As Range: Set GameSpace = Range(Cells(LBound(Buffer, 1), LBound(Buffer, 1)), Cells(UBound(Buffer, 1), UBound(Buffer, 2)))
    
    Dim Cell As Range
    
    '����Previous��p��
    For Each Cell In GameSpace
        If Cell.Interior.Color = HEX2RGB(OnColor) Then Previous(Cell.Row, Cell.Column) = OnColor Else Previous(Cell.Row, Cell.Column) = OffColor
    Next Cell
    
    Do While True 'GameContinue(GameSpace)
        '�o�b�t�@��������
        ReDim Buffer(1 To Height, 1 To Width)
        
        t.StartTimer
        For i = LBound(Previous, 1) To UBound(Previous, 1)
            For j = LBound(Previous, 2) To UBound(Previous, 2)
                
                If Previous(i, j) = PrevOnColor Then '�����Ă���ꍇ
                    Select Case Vicinity(Previous, i, j, PrevOnColor)
                        Case 2, 3
                            Buffer(i, j) = OnColor
                        Case Else
                            Buffer(i, j) = OffColor
                    End Select
    
                ElseIf Previous(i, j) = OffColor Then '����ł���ꍇ
                    Select Case Vicinity(Previous, i, j, PrevOnColor)
                        Case 3
                            Buffer(i, j) = OnColor
                        Case Else
                            Buffer(i, j) = OffColor
                    End Select
                End If
        
            Next j
        Next i
        
        Do While t.TakeLap < f
            DoEvents
        Loop
        t.StopTimer
        
        'Debug.Print t.StopTimer
        '�`��̍X�V
        
        UpdateScreen Buffer
        
        Previous = Buffer
        
        PrevOnColor = OnColor
        seed = seed + 1
        OnColor = GenerateRainbow(seed)
        
        DoEvents
    Loop
End Sub

'�����_���ȏ����l��^����ꍇ��True
Public Sub Initialize(ByVal flag As Boolean)
    UnlockActiveSheet
    SetCellsSizeSquare ActiveSheet.Cells, px
    LockActiveSheet
    
    If Not flag Then GoTo Dispose
    
    Dim arr() As Byte
    ReDim arr(1 To Height, 1 To Width)
    Dim t As New Timer

    Dim i As Long, j As Long
    For i = 1 To Height
        For j = 1 To Width
            Randomize
            If Rnd > 0.9 Then arr(i, j) = OnColor Else arr(i, j) = OffColor
            'Debug.Print i & ", " & j
        Next j
    Next i
    
    UpdateScreen arr
    
    DoEvents
    
Dispose:
    UnlockActiveSheet
End Sub

Public Sub UpdateScreen(ByRef Buffer() As Byte)
    
    Application.ScreenUpdating = False
    UnlockActiveSheet
    
    Dim t As New Timer
    Dim f As Double: f = 0.3
    Dim dblWait As Double: dblWait = t.StartTimer
    
    Dim i As Long
    Dim str(0 To 255) As String
    
    Dim Cell As Range
    
    For Each Cell In Range(Cells(LBound(Buffer, 1), LBound(Buffer, 1)), Cells(UBound(Buffer, 1), UBound(Buffer, 2)))
        
        For i = 0 To 255
        
            'On�ɂ���A�h���X(String)���W�߂�
            'Range��255�����܂ł����󂯕t���Ȃ��̂ŁA255�����W�܂閈��Range.Interior.Color��ύX
            'Union�ɂ��Range�̌����́A�ЂƂ��F��ς�����x��
            If Buffer(Cell.Row, Cell.Column) = i Then
                If Len(str(i) & Cell.Address) <= 255 Then
                    str(i) = str(i) & "," & Cell.Address
                Else
                    'str(i)�̐擪�̃R���}���O��
                    Range(Mid(str(i), 2)).Interior.Color = HEX2RGB(i)
                    str(i) = "," & Cell.Address
                End If
                
                Exit For
                
            End If
        Next i
        
    Next Cell
    
    '�]���Range.Interior.Color��ύX
    For i = 0 To 255
        If str(i) <> "" Then Range(Mid(str(i), 2)).Interior.Color = HEX2RGB(i)
        str(i) = ""
    Next i
    
    'fps���艻
    '�`��͈͂��L���Ȃ�Ɗ��҂�����������Ȃ�
'    Do While t.TakeLap - dblWait < f
'        DoEvents
'    Loop
    
    LockActiveSheet
    Application.ScreenUpdating = True
    
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
Public Function Vicinity(ByRef Buffer() As Byte, ByVal i As Long, ByVal j As Long, ByVal OnColor As Byte) As Long

    Vicinity = 0
    
    If i > LBound(Buffer, 1) Then
        If j > LBound(Buffer, 2) Then
            If Buffer(i - 1, j - 1) = OnColor Then Vicinity = Vicinity + 1 '����
        End If
        
        If j < UBound(Buffer, 2) Then
            If Buffer(i - 1, j + 1) = OnColor Then Vicinity = Vicinity + 1 '�E��
        End If
        
        If Buffer(i - 1, j) = OnColor Then Vicinity = Vicinity + 1 '��
    End If
    
    If i < UBound(Buffer, 1) Then
        If j > LBound(Buffer, 2) Then
            If Buffer(i + 1, j - 1) = OnColor Then Vicinity = Vicinity + 1 '����
        End If
        
        If j < UBound(Buffer, 2) Then
            If Buffer(i + 1, j + 1) = OnColor Then Vicinity = Vicinity + 1 '�E��
        End If
        
        If Buffer(i + 1, j) = OnColor Then Vicinity = Vicinity + 1 '��
    End If
    
    If j > LBound(Buffer, 2) Then
        If Buffer(i, j - 1) = OnColor Then Vicinity = Vicinity + 1 '��
    End If
    
    If j < UBound(Buffer, 2) Then
        If Buffer(i, j + 1) = OnColor Then Vicinity = Vicinity + 1 '�E
    End If
End Function

'1�o�C�g�l��RGB�ɕϊ�����
Public Function HEX2RGB(ByVal val As Byte) As Long
    '���3bit��R, 3bit��G, 2bit��B�ɕϊ�
    'And�Ń}�X�N &HE0 = 111 000 00
    '�@�@�@�@�@�@&H1C = 000 111 00
    '�@�@�@�@�@�@&H3 = 000 000 11
    '"\ (2 ^ [����])"�ŃV�t�g
    '�\���ł���ő吔(RG:7, B:3)�Ŋ����āA255��������
    Dim r As Long, g As Long, b As Long
    r = Int(CLng((val And &HE0) \ (2 ^ 5)) / 7 * 255)
    g = Int(CLng((val And &H1C) \ (2 ^ 2)) / 7 * 255)
    b = Int(CLng(val And &H3) / 3 * 255)
    HEX2RGB = RGB(r, g, b)
End Function

'���F�𐶐�����
'42��1������
'r : 0~7
'g : 0~7
'b : 0~3
Public Function GenerateRainbow(ByVal seed As Long) As Byte
    
    Dim r As Long, g As Long, b As Long
    
    Do While seed >= 42
        seed = seed - 42
    Loop
    
    If 0 <= seed And seed < 7 Then
        r = 7
        g = 0
        b = Int(seed / 2)
    ElseIf 7 <= seed And seed < 14 Then
        r = 14 - seed
        g = 0
        b = 3
    ElseIf 14 <= seed And seed < 21 Then
        r = 0
        g = seed - 14
        b = 3
    ElseIf 21 <= seed And seed < 28 Then
        r = 0
        g = 7
        b = Int((28 - seed) / 2)
    ElseIf 28 <= seed And seed < 35 Then
        r = seed - 28
        g = 7
        b = 0
    ElseIf 35 <= seed And seed < 42 Then
        r = 7
        g = 42 - seed
        b = 0
    End If
    
    GenerateRainbow = (r * (2 ^ 5)) Or (g * (2 ^ 2)) Or b
    
End Function
