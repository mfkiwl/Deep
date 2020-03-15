classdef mean_rec < handle
% �̶����ڵ��Ƽ����ֵ
    
    properties (GetAccess = public, SetAccess = private)
        flag    %������־
        buff    %���ݻ���
        size    %�����С
        index   %��������,��0��ʼ
        E       %��ǰ����ľ�ֵ
    end
    
    methods
        % ���캯��
        function obj = mean_rec(n)
            % n:����ռ��С
            obj.flag = 0;
            obj.buff = zeros(1,n);
            obj.size = n;
            obj.index = 0;
            obj.E = 0;
        end
        
        % ���º���
        function update(obj, x1)
            % x1:��ǰ����
            if obj.flag
                n = obj.size;
                k = obj.index + 1;
                x0 = obj.buff(k);
                %------------------------------------
                obj.E = obj.E + (x1-x0)/n; %�����ֵ
                %------------------------------------
                obj.buff(k) = x1;
                if k==n %��������
                    obj.index = 0;
                else
                    obj.index = k;
                end
            else
                obj.flag = 1;
                obj.buff(:) = x1; %������ȫ����x1
                obj.E = x1;
                obj.index = 1;
            end
        end
        
        % ��������
        function restart(obj, n)
            obj.flag = 0;
            obj.buff = zeros(1,n);
            obj.size = n;
            obj.index = 0;
            obj.E = 0;
        end
        
    end %end methods
    
end %end classdef