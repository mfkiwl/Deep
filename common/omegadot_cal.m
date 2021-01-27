classdef omegadot_cal < handle
% �Ǽ��ٶȼ���

    properties
        dt    %��������
        K1    %K1ϵ��
        K2    %K2ϵ��
        V     %�Ǽ��ٶ�
        X     %���ٶ�
    end
    
    methods
        % ���캯��
        function obj = omegadot_cal(dt, n)
            % dt:��������,s
            % n:����ά��
            obj.dt = dt;
            [obj.K1, obj.K2] = order2LoopCoefD(8, 0.707, dt);
            obj.V = zeros(1,n);
            obj.X = zeros(1,n);
        end
        
        % ���к���
        function wdot = run(obj, w)
            E = w - obj.X;
            obj.V = obj.V + obj.K2*E;
            obj.X = obj.X + (obj.V+obj.K1*E)*obj.dt;
            wdot = obj.V;
        end
        
    end %end methods
    
end %end classdef