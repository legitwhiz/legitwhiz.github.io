# ownCloud10.0.9�̃f�[�^�ۑ���ύX

## �T�v

Ubuntu16.04 LTS��owncloud10.0.9�ɂ�
���܂Ńf�t�H���g�ł���A[/var/www/owncloud/data/]�z����
�f�[�^���i�[���Ă܂������A�ʐ^���A�b�v���[�h���悤�Ƃ����Ƃ���A
�󂫗e�ʕs���ŃA�b�v���[�h�ł��Ȃ��ƃ��b�Z�[�W��...�B

�󂫗e�ʂ��m�F�����[/]������85%��...(�E�B�E;

�}篁A�i�[��̕ύX���������˂΁B
�������ƃO�O���ĕۑ����ύX���܂����Ƃ��������̋L���ł����ǁB

## ownCloud�̕ۑ���ύX

ownCloud�̐ݒ�t�@�C�����C��

```
vi /var/www/owncloud/config/config.php
```
�C���ӏ��͈ȉ��ƂȂ�B

'datadirectory' => '/var/www/owncloud/data',
��
'datadirectory' => '/share/owncloud/data',

'installed' => true,
��
'installed' => false,


## ownCloud�̕ۑ���f�B���N�g���̍쐬

```
mkdir -m 755 /share/owncloud/data
sudo chown www-data:www-data /share/owncloud/data
```

## �[������u���E�U�ŃA�N�Z�X�������Z�b�g�A�b�v�����{

�����Z�b�g�A�b�v���@�ɂ��ẮA�ȗ�
�������Z�b�g�A�b�v�Ȃ��ł��ۑ���ύX�Ȃ�Ăł���������
�f�[�^�ēǍ��R�}���h�����s���Ă��Â��t�H���_���Q�Ƃ��Ă��܂����߁B

## �f�[�^�ڍs

[/var/www/owncloud/data]�z���̃f�[�^��[/share/owncloud/data]�Ɉړ��B

```
sudo cp -R /var/www/owncloud/data /share/owncloud/data
sudo rm -rf /var/www/owncloud/data
sudo chown -R apache:apache /share/owncloud/data
sudo chmod -R 755 /share/owncloud/data
```

## ownCloud�ɍēǍ����蓮���s

```
sudo -u www-data php /var/www/owncloud/occ files:scan <owncloud user name>

Scanning files for 1 users
Starting scan for user 1 out of 1 (<owncloud user name>)

+---------+-------+--------------+
| Folders | Files | Elapsed time |
+---------+-------+--------------+
| 91      | 5885  | 00:00:21     |
+---------+-------+--------------+
```
���`��A�t�@�C���X�L���������̂͂�������
owncloud��̃^�C���X�^���v���X�V���ꂿ�Ⴄ�񂾂�...�B���ē�����O��w
