classdef var_rec < handle
% �̶����ڵ��Ƽ��㷽��
    
    properties (GetAccess = public, SetAccess = private)
        flag    %������־
        buff    %���ݻ���
        size    %�����С
        index   %��������,��0��ʼ
        E       %��ǰ����ľ�ֵ
        D       %��ǰ����ķ���
    end
    
    methods
        % ���캯��
        function obj = var_rec(n)
            obj.flag = 0;
            obj.buff = zeros(1,n);
            obj.size = n;
            obj.index = 0;
            obj.E = 0;
            obj.D = 0;
        end
        
        % ���º���
        function update(obj, x1)
            if obj.flag
                n = obj.size;
                k = obj.index + 1;
                x0 = obj.buff(k);
                E0 = obj.E; %�ϴεľ�ֵ
                D0 = obj.D; %�ϴεķ���
                %------------------------------------
                E1 = E0 + (x1-x0)/n; %�����ֵ
                D1 = D0 + ((x1-E1)^2 - (x0-E0)^2 - 2*(E1-E0)*(E0*n-x0) + (n-1)*(E1^2-E0^2))/n;
                %------------------------------------
                obj.E = E1; %���¾�ֵ
                obj.D = D1; %���·���
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
            obj.D = 0;
        end
        
    end
    
end %end classdef