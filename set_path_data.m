% ���ļ���ѡ��Ի���,ѡ���������ڵ��ļ���
% ÿ�δ򿪹���ʱ����,��·��д��.\temp\path_data.txt
% �����޸�,�ٴ����д˽ű�
% ���˽ű����ÿ�ݼ�

while 1
    selpath = uigetdir('.', 'ѡ�������ļ�·��');
    if selpath~=0 %���δѡ·��,����ѭ��
        break
    end
end

fileID = fopen('.\temp\path_data.txt', 'w');
fprintf(fileID, '%s', selpath);
fclose(fileID);

clearvars ans fileID selpath