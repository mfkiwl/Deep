classdef delayN < handle
% n���ӳ�,����һ����,���n��֮ǰ����
    
    properties
        buff      
        len %����������
        ptr    
    end
    
    methods
        function obj = delayN(m, n)
            % m����(������),�ӳ�n����
            obj.buff = zeros(n,m);
            obj.len = n;
            obj.ptr = 1;
        end
        
        function out = push(obj, in)
            % ��ȡ���
            k = obj.ptr;
            out = obj.buff(k,:);
            obj.buff(k,:) = in;
            k = k+1;
            if k>obj.len
                k = 1;
            end
            obj.ptr = k;
        end
        
    end
    
end