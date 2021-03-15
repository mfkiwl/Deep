function almanac = read(filename)
% ��GPS YUMA�����ļ�

% ���ļ�
fileID = fopen(filename);
if(fileID == -1)
    almanac = [];
    disp('Can''t open the file!')
    return
end

% ������
temp = zeros(32,12);
line = 1; %�ļ��ĵڼ���
while ~feof(fileID)
    tline = fgetl(fileID);
    n = mod(line,15); %ÿ�����ǵĵڼ�������,ÿ�����ǵ�����ռ15��
    if n==2 %��2��ΪID��
        [~, remain] = strtok(tline, ':'); %��ȡ:�Ժ���ַ�,����:
        C = textscan(remain, '%s %f');
        ID = C{2};
    elseif 3<=n && n<=14 %��3~14��Ϊ����
        [~, remain] = strtok(tline, ':');
        C = textscan(remain, '%s %f');
        temp(ID,n-2) = C{2}; %������
    end
    line = line+1;
end

% �ر��ļ�
fclose(fileID);

% ��������
% almanac = [ID, health, week, af0, af1, toe, sqa, e, M0, omega, Omega0, Omega_dot, i];
almanac = zeros(32,13);
almanac(:,1)  = 1:32;        %ID
almanac(:,2)  = temp(:,1);   %health
almanac(:,3)  = temp(:,10);  %af0,s
almanac(:,4)  = temp(:,11);  %af1,s/s
almanac(:,5)  = temp(:,12);  %week
almanac(:,6)  = temp(:,3);   %toe,s
almanac(:,7)  = temp(:,6);   %sqa,sqrt(m)
almanac(:,8)  = temp(:,2);   %e
almanac(:,9)  = temp(:,9);   %M0,rad,ƽ�����
almanac(:,10) = temp(:,8);   %omega,rad,���ص����
almanac(:,11) = temp(:,7);   %Omega0,rad,������ྭ
almanac(:,12) = temp(:,5);   %Omega_dot,rad/s
almanac(:,13) = temp(:,4);   %i,rad
almanac(almanac(:,7)==0,:) = []; %ɾ�������ݵ���

end