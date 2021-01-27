classdef delayN < handle
% n���ӳ�,����һ����,���n��֮ǰ����
    
    properties
        buff
        len  %����������
        ptr
        cnt
    end
    
    methods
        function obj = delayN(m, n)
            % m:�ӳٵ���
            % n:����ά��
            obj.buff = zeros(m,n);
            obj.len = m;
            obj.ptr = 1;
            obj.cnt = 0;
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
            % ��ʼ����������������ԭֵ
            if obj.cnt<obj.len
                obj.cnt = obj.cnt + 1;
                out = in;
            end
        end
        
    end
    
end