VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Timer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

''' �����x�^�C�}�[���W���[��
''' <example>
'''
''' �錾��
''' <code>
''' Dim clsTimer As New Timer
''' </code>
'''
''' ���鏈���ɂ����鎞�Ԃ��v�������
''' <code>
''' clsTimer.StartTimer
''' ' �v���Ώۂ̏���
''' Debug.Print clsTimer.StopTimer
''' </code>
'''
''' ������Ԃ̌o�ߎ��Ԃ��v�������
''' <code>
''' clsTimer.StartTimer
''' ' �v���Ώۂ̏���_1
''' Debug.Print clsTimer.TakeLap
''' ' �v���Ώۂ̏���_2
''' Debug.Print clsTimer.StopTimer
''' </code>
'''
''' ������Ԃ̌v�����ʂ�For���[�v�ŕ\�������
''' <code>
''' Dim i As Long
''' For i = 0 To clsTimer.Length - 1
'''     Debug.Print clsTimer.Laps(i)
''' Next i
''' </code>
''' </example>

Private Declare PtrSafe Function QueryPerformanceFrequency Lib "kernel32" (ByRef freq As LongPtr) As Long
Private Declare PtrSafe Function QueryPerformanceCounter Lib "kernel32" (ByRef procTime As LongPtr) As Long
Private freq As LongPtr

''' <summary>
''' �^�C�}�[�{��
''' </summary>
Private t As Double

''' <summary>
''' ���b�v�ꗗ���i�[����z��
''' </summary>
Private arrLap() As Double

''' <summary>
''' �^�C�}�[�����s�������肷��
''' </summary>
Private flag As Boolean

''' <summary>
''' �^�C�}�[�̏�
''' </summary>
Public Property Get Running() As Boolean
    Running = flag
End Property

''' <summary>
''' Laps�v���p�e�B�̗v�f��
''' </summary>
Public Property Get Length()

    If flag = False Then
    
        If UBound(arrLap) = 0 Then
            Err.Raise 1026, "Timer.Length", "�^�C�}�[���s�O�͖����̃v���p�e�B�ł��B"
        Else
            Length = UBound(arrLap) + 1
        End If
        
    Else
        Err.Raise 1024, "Timer.Length", "�^�C�}�[���s���͖����̃v���p�e�B�ł��B"
    End If
    
End Property

''' <summary>
''' �^�C�}�[���J�n����
''' </summary>
''' <return>�L�^�����J�n���� = 0</return>
Public Function StartTimer()
    
    If flag = False Then
        
        flag = True
    
        ' t, arrLap()�����Z�b�g
        t = 0
        ReDim arrLap(0)
        
        t = GetSecond
        arrLap(0) = 0 ' �J�n���_�̃��b�v = 0
        StartTimer = 0
    
    Else
        Err.Raise 1024, "Timer.StartTimer", "�^�C�}�[���s���͖����̃��\�b�h�ł��B"
    End If
    
End Function

''' <summary>
''' �^�C�}�[���I������
''' </summary>
''' <return>�L�^�����I������</return>
Public Function StopTimer() As Double

    If flag = True Then
        StopTimer = GetSecond - t
        
        ' �Ō�̃��b�v�ɋL�^����
        ReDim Preserve arrLap(UBound(arrLap) + 1)
        arrLap(UBound(arrLap)) = StopTimer
    
        flag = False
    
    Else
        Err.Raise 1025, "Timer.StopTimer", "�^�C�}�[��~���͖����̃��\�b�h�ł��B"
    End If
    
End Function

''' <summary>
''' ���b�v���L�^����
''' </summary>
''' <return>�L�^�������b�v</return>
Public Function TakeLap() As Double
    
    If flag = True Then
        TakeLap = GetSecond - t
        
        ReDim Preserve arrLap(UBound(arrLap) + 1)
        arrLap(UBound(arrLap)) = TakeLap
    
    Else
        Err.Raise 1025, "Timer.TakeLap", "�^�C�}�[��~���͖����̃��\�b�h�ł��B"
    End If
    
End Function

''' <summary>
''' ���b�v���擾����
''' </summary>
''' <param name="index">�v�f 0~(Length - 1)</param>
Public Property Get Laps(ByVal index As Long)

    If flag = False Then
        If UBound(arrLap) = 0 Then
            Err.Raise 1026, "Timer.Laps", "�^�C�}�[���s�O�͖����̃v���p�e�B�ł��B"
        ElseIf index < LBound(arrLap) Or UBound(arrLap) < index Then
            Err.Raise 1027, "Timer.Laps", "�C���f�b�N�X���L���͈͂ɂ���܂���B"
        End If
        
        Laps = arrLap(index)
    
    Else
        Err.Raise 1024, "Timer.Laps", "�^�C�}�[���s���͖����̃v���p�e�B�ł��B"
    End If
    
End Property

''' <summary>
''' �w��b���ҋ@����(DoEvents)
''' </summary>
''' <param name="ms">�~���b</param>
Public Sub Sleep(ByVal ms As Long)
    Dim temp As Double: temp = GetMilliSecond
    Do While GetMilliSecond - temp < ms
        DoEvents
    Loop
End Sub

Private Sub Class_Initialize()
    QueryPerformanceFrequency freq
    
    flag = False
    t = 0
    ReDim arrLap(0)
End Sub

''' <summary>
''' ���݂̕b�����擾����
''' </summary>
Private Function GetSecond() As Double
    
    Dim procTime As LongPtr
    
    '�J�E���g�����u1�}�C�N���b�Ԃɑ�����J�E���g���v�Ŋ��邱�Ƃŕb���擾�ł���
    QueryPerformanceCounter procTime
    GetSecond = procTime / freq
    
End Function

''' <summary>
''' ���݂̕b�����擾����(�~���b)
''' </summary>
Private Function GetMilliSecond() As Double
    GetMilliSecond = GetSecond * 1000
End Function