# Google�J�����_�[�ɓo�^�����\���O���Ƀ��}�C���_�[���b�Z�[�W��Line�ɑ����Ă����RPA���V�s

**�yRPA�z**�Ƃ́A�yRobotics Process Automation�z�̗��̂ŌJ��Ԃ����s�����A�N�V���������{�b�g�������Ŏ��s���邱�Ƃ������B

���Ɋ��p����Ă���̂���ƂŁA���X�J��Ԃ��s����Ɩ������{�b�g���ς��ɍs���Ă����Ƃ������̂ł��B���������v�̈�Ƃ��Ă����ڂ���Ă���Z�p�ł��B

�ł����A�Ɩ������łȂ����퐶���ł����Ă����{�b�g�Ŏ��������邱�Ƃ��\�Ȃ�ł���B

��Ƃ��g�p���Ă���**�yRPA�z**�c�[���́A���G�Ȃ��Ƃ��ł��܂����c�[���̂��l�i������Ȃ�ɂ��܂��B�ł����A�t���[�̃c�[��������܂����A�X�}�z�A�v���ł������ł��B

�܂��A�v���O���~���O��K�v�Ƃ���c�[��������΁AGUI�ŊȒP�ɍ��郂�m������悤�ł��B

## ���Ⴀ�A�Ȃɂ�������������֗��H

Google�J�����_�[�ɗ\���o�^���Ă����Ă��A�߁X�̗\��Ȃ炢����ł����A��̗\�肾�Ɛ܊p�J�����_�[�ɗ\�������Ă����Ă����邱�Ƃ�Y�ꂽ�Ȃ�Čo������܂��񂩁H

�Ȃ̂ŁA�J�����_�[�ɓo�^�����\���O���Ƀ��}�C���_�[�Ƃ���LINE�ʒm����**�yRPA�z**������Ă݂悤�Ǝv���܂��B

### �y�ޗ��z

1. Google�J�����_�[��Google Apps Script���g�����߂̃A�J�E���g

2. �ʒm�����Ƃ���LINE�A�J�E���g

3. LINE ���b�Z�[�W�𔭍s����Line

��́A�������΁cw

### �y�����z

#### �O��

�܂��́A�O�؂Ɏ�����Google�A�J�E���g���g���āwGoogle�J�����_�[�x�ɃX�P�W���[��������Ă݂����Ǝv���܂��B

##### 1�D PC�ł��X�}�z�ł��ȒP�ɂł��܂��̂Ŏ菇�͏ȗ����܂��B

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/google_calender_TEST_Schedule.png" width="420">



#### �`��

����LINE�Ƀ��b�Z�[�W�𔭍s���邽�߂�LINE Notify�ƌĂ΂��API�g�[�N�������܂��B
�u���E�U�ňȉ���URL�ɃA�N�Z�X���܂��B���̎菇��PC�����{���邱�ƁB

[LINE Notify](https://notify-bot.line.me/doc/ja/)

##### 1. �E��́u���O�C���v�{�^���������A

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_01.png" width="420">

##### 2. �A�J�E���g�̃��[���A�h���X�ƃp�X���[�h����͂��u���O�C���v�{�^���������܂��B

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_02.png" width="420">

3. �u�o�^�T�[�r�X�Ǘ��v�������B

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_03.png" width="420">


##### 4. �u�T�[�r�X��o�^����v�������B
<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_04.png" width="420">



##### 5. �K�v��������͂��u�o�^�v�{�^���������B

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_06.png" width="420">

##### 6. LINE Notify�̃g�b�v��ʂɖ߂�u�g�[�N���𔭍s����v�{�^���������B

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/line_notify_07.png" width="420">



##### 7. �o�͂��ꂽ��������T�����API�g�[�N���̏o���オ��ł��B



#### ��H

���C���f�B�b�V���́AGoogle Apps Script(GAS)�Œ���I��Google�J�����_�[�����Ė����̗\�肪����΁ALINE���b�Z�[�W�𑗂�X�N���v�g������Ă݂����Ǝv���܂��B



##### 1. Google�h���C�u�ɃA�N�Z�X���A[MyDrive]���E�N���b�N���āA[More] ��[Connect more apps]���N���b�N

������[Google Apps Acript]��o�^�ς݂̏ꍇ�́A�菇5.�ɐi��

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_01.png" width="420">





##### 2. [Google Apps Acript]���N���b�N

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_02.png" width="420">



##### 3. [connect]���N���b�N

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_03.png" width="420">

##### 4. �����m�F��ʂ�[OK]���N���b�N

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_04.png" width="420">



##### 5. [My Drive]���E�N���b�N���āA[Google Apps Acript]���N���b�N

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_05.png" width="420">



##### 6. �X�N���v�g�����

���X�N���v�g�̓��e�́A[�yLINE Notify + GoogleAppsScript + Google�J�����_�[�Ŗ����̗\����ΖY��Ȃ��z](https://qiita.com/imajoriri/items/e211547438967827661f)���Q�l�ɂ����Ă��������܂����B

�������A�\�肪�Ȃ����Ɂu�\�肪����܂���v��LINE���b�Z�[�W������͎̂₵���̂ŉ������b�Z�[�W���o���Ȃ��悤�ɂ��Ă��܂��E�E�Ewww



<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_06.png" width="420">



##### 7. [File]�� [Save]���N���b�N

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_07.png" width="420">



##### 8. �g���K�[��ʂ�[�g���K�[��ǉ�]���N���b�N

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_08.png" width="420">



##### 9. �g���K�[�ǉ���ʂ�[���s����֐���I��]�ŁumyFunction��1�v��I���B

������A���͂����X�N���v�g�̃��C���֐����umyFunction�v�ƂȂ��Ă��邽�߁B

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_09.png" width="420">



##### 10. [���ԃx�[�X�̃g���K�[�̃^�C�v��I��]�Łu���t�x�[�X�̃^�C�}�[�v��I�����A[������I��]��[�ߑO8���`9��]��I����[�ۑ�]���N���b�N�B���Ԃ͂��D�݂ŁB

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_10.png" width="420">



##### 11. �g���K�[���o�^���ꂽ���Ƃ��m�F���A�I���ł��B

<img src="https://raw.githubusercontent.com/legitwhiz/legitwhiz.github.io/master/technology_memo/images/linenotify/GAS_11.png" width="420">


#### �Ō��

����́AGoogle�J�����_�[�̗\���ʒm������̂����܂������A�F�X��API���g�p����LINE���ɒʒm���邱�Ƃ��ł������Ȃ̂�������܂����B
���ꂱ���A���܂ň��~�������̂���T�C�g���{�����Ă����Ƃ����{���ɕK�v�ȏ�񂾂����s�b�N�A�b�v���邱�Ƃ��\�ɂȂ肻���ł��̂ŁA�]�v�Ȏ��ԒZ�k��ڕW�ɐF�X�Ǝ����Ă݂����Ǝv���܂��B


