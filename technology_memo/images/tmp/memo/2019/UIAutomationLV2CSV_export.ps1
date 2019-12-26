###########################################################################
#
#  �V�X�e����      �F  
#  �T�u�V�X�e����  �F  
#  �X�N���v�g��    �F  UIAutomationLV2CSV_export.ps1
#  �@�\��          �F  LV2CSV��GUI���삵CSV��export
#  �@�\�T�v�@      �F  ListView to CSV(LV2CSV.exe�j��GUI����^�C�v���J�E���^�[��CSV��export����B
#  CALLED BY       �F  
#  CALL TO         �F  NONE
#  ARGUMENT        �F  1.����
#                      2.����  
#  RETURNS         �F  0      ���� 
#                      0�ȊO  �ُ� 
#-------------------------------------------------------------------------
#  �쐬��          �F  �V�K
#  �쐬���@        �F 2018/09/10    �쐬�ҁ@�F�@D.SAKAMOTO(legit whiz)
#  �C�������@      �F
#
###########################################################################
$exePath = "D:\SakaTmp\tool\lvcs2.25.05_x64\LV2CSV.EXE"
$LogDir = "D:\SakaTmp\logs\type_count\"

# [ Import-Module ]�R�}���h���b�g��UIAutomation.dll���C���|�[�g����B
Import-Module D:\SakaTmp\tool\UiAutomation\UIAutomation.dll

# [ Start-Process ]�R�}���h���b�g��LV2CSV.ex���N������B
$process = Start-Process $exePath -PassThru | Get-UiaWindow;

$start_time_today = [system.datetime]
$start_time_today = get-date -hour "0" -minute "0" -second "0"
$targetFile = $start_time_today.tostring("yyyyMMdd") + "_type.csv"

$target_full_path = $LogDir + $targetFile;

# $target_full_path ������΍폜
if(Test-Path $target_full_path){
    Remove-Item $target_full_path -Force
}

# ListView to CSV��ʂ�type���J�E���^�[��I��
$process.Keyboard.KeyDown([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt �L�[������
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::VK_C) | Out-Null; # C �L�[������
$process.Keyboard.KeyUp([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt �L�[�����
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::DOWN) | Out-Null; # �� �L�[������
# 0.1 �b��~
Start-Sleep -m 500
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::UP) | Out-Null; # �� �L�[������
# 0.1 �b��~
Start-Sleep -m 500

# Alt + v �� Enter �̏��ŃL�[�������ƁC[���O��t���ĕۑ�]��ʂ��o��
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt �L�[������
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::VK_V) | Out-Null; # v �L�[������
$process.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::RETURN) | Out-Null; # Enter �L�[������
Start-Sleep -m 500

# ���X�g���ɂ���A�C�e����I�����ĊJ��
$openWnd = Get-UiaWindow -Name '���O���w�肵�ĕۑ�';
$selectItem = $openWnd | Get-UiaEdit -Name '�t�@�C����:';
$selectItem.Value = $LogDir + $targetFile;
$selectItem.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::RETURN) | Out-Null;

# 0.7 �b��~
Start-Sleep -m 700

# [OK]�{�^��������
$window = Get-UiaWindow -Name 'ListView to CSV'
$window | Get-UiaButton -Name 'OK' | Invoke-UiaButtonClick | Out-Null

# 0.3 �b��~
Start-Sleep -m 500

# ����
$window.Keyboard.KeyDown([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt �L�[������
$window.Keyboard.KeyPress([WindowsInput.Native.VirtualKeyCode]::F4) | Out-Null; # F4 �L�[������
$window.Keyboard.KeyUp([WindowsInput.Native.VirtualKeyCode]::MENU) | Out-Null; # Alt �L�[������

# 0.3 �b��~
Start-Sleep -m 500

if(!(Test-Path $target_full_path)){
        echo File Create Eroor
        exit 1
}

# shutdown -h now
Stop-Computer -Force
