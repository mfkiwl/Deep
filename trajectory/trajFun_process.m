function trajTable = trajFun_process(trajFun)
% ���㵼��,���ź���ת������������,�õ�ʱ������

trajTable = cell(1,4); %{time, N, value, diff}

N = size(trajFun,1); %����
time = zeros(1,N); %ʱ������
trajTable{3} = cell(N,1);
trajTable{4} = cell(N,1);

for k=1:N
    time(k) = trajFun{k,1}(end); %��ȡʱ��
    if isnumeric(trajFun{k,2}) %����
        trajTable{4}{k} = 0; %�����ĵ�����0
        trajTable{3}{k} = trajFun{k,2};
    else %����
        temp = diff(trajFun{k,2}); %���ź�����
        if hasSymType(temp,'variable') %�����к��Ա���
            trajTable{4}{k} = matlabFunction(temp); %���ź���ת��Ϊ��������
        else
            trajTable{4}{k} = double(temp); %������ת��Ϊ����
        end
        trajTable{3}{k} = matlabFunction(trajFun{k,2}); %���ź���ת��Ϊ��������
    end
end

trajTable{1} = [0, time(1:N-1)]; %ǰ�油��,ɾ���һ��
trajTable{2} = N;

end