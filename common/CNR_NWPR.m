classdef CNR_NWPR < handle
% ʹ��խ��������ʱ�ֵ�����������

    properties
        NWmean     %NBP/WBP�ľ�ֵ
        Nd         %һ�����ݶεĵ���
    end
    
    methods
        function obj = CNR_NWPR(N, M)
            % N:һ�����ݶεĵ���
            % M:ƽ�����ݶ���
            obj.Nd = N;
            obj.NWmean = mean_rec(M);
        end
        
        function CN0 = cal(obj, Is, Qs)
            WBP = sum(Is.^2 + Qs.^2); %�������,���е�Ĺ������
            NBP = sum(Is)^2 + sum(Qs)^2; %խ������,���е���������㹦��
            obj.NWmean.update(NBP/WBP);
            Z = obj.NWmean.E;
            S = (Z-1) / (obj.Nd-Z) * 1000; %����ʱ��̶�Ϊ1ms
            if S>10
                CN0 = 10*log10(S);
            else
                CN0 = 10;
            end
        end
        
    end
    
end %end classdef