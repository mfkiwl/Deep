function trajFun_check(trajFun, name)
% ���켣�����Ƿ���ȷ

[N, M] = size(trajFun); %�켣����ά��
if M~=2 %��������Ϊ2
    error([name, ': Dimension error!'])
end

%----���һ��ʱ��ά��������1
if length(trajFun{end,1})~=1
    error([name, ': The last time must be a scalar!'])
end

%----��ʼʱ�������0
if trajFun{1,1}(1)~=0
    error([name, ': The initial time must be 0!'])
end

%----ʱ���������
for k=1:N-1
    if trajFun{k,1}(2)~=trajFun{k+1,1}(1)
        error([name, ': Time is discontinuous! k=', num2str(k)])
    end
end

%----��ֵ��������
for k=1:N-1
    % �ϸ���ֵ
    if isnumeric(trajFun{k,2}) %����
        x0 = trajFun{k,2};
    else %����
        fun = matlabFunction(trajFun{k,2}); %�����ź���ת������������
        x0 = fun(trajFun{k,1}(2));
    end
    % ��ǰ��ֵ
    if isnumeric(trajFun{k+1,2}) %����
        x1 = trajFun{k+1,2};
    else %����
        fun = matlabFunction(trajFun{k+1,2}); %�����ź���ת������������
        x1 = fun(trajFun{k+1,1}(1));
    end
    if abs(x0-x1)>1e-10
        error([name, ': Value is discontinuous! k=', num2str(k)])
    end
end

end