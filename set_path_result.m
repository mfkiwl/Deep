% ���ļ���ѡ��Ի���,ѡ�����н���洢���ļ���
% ÿ�δ򿪹���ʱ����,��·��д��.\temp\path_result.txt
% �����޸�,�ٴ����д˽ű�
% ���˽ű����ÿ�ݼ�

while 1
    selpath = uigetdir('.', 'ѡ�����洢·��');
    if selpath~=0 %���δѡ·��,����ѭ��
        break
    end
end

fileID = fopen('.\temp\path_result.txt', 'w');
fprintf(fileID, '%s', selpath);
fclose(fileID);

clearvars ans fileID selpath