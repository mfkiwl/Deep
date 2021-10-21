classdef accJumpDetector < handle
% ���ٶ�ͻ����
% ���ٶ�ͻ��״̬Ҫά��һ��,��Ϊ���ٶ�ͻ����Ƕ�ʱ�������źŲ��ȶ�

    properties
        state   %ͻ��״̬
        flag    %�״����б�־
        acc0    %�ϴμ��ٶ�ֵ
        amThr   %���ٶ�ģ����ֵ
        cnt     %������
        N       %����ֵ
    end
    
    methods
        % ���캯��
        function obj = accJumpDetector(dt)
            % dt:����ʱ����,s
            obj.state = 0;
            obj.flag = 0;
            obj.acc0 = [0,0,0];
            obj.amThr = 1000*dt; %100g/s
            obj.cnt = 0;
            obj.N = 0.1/dt; %100ms
        end
        
        % ���к���
        function run(obj, acc)
            if obj.flag==0
                obj.flag = 1;
                obj.acc0 = acc;
            end
            if obj.state==0 %ûͻ��
                if norm(obj.acc0-acc)>obj.amThr
                    obj.state = 1;
                    obj.cnt = 0;
                end
            else %��ͻ��
                if norm(obj.acc0-acc)>obj.amThr
                    obj.cnt = 0;
                else
                    obj.cnt = obj.cnt + 1;
                end
                if obj.cnt==obj.N
                    obj.state = 0;
                end
            end
            obj.acc0 = acc; %�����ϴμ��ٶ�
        end
        
    end %end methods
    
end %end classdef