classdef motionDetector_gyro_vel < handle
% ʹ��������������ٶ����˶�״̬���  
    
    properties
        state0  %�ϴε��˶�״̬
        state   %�˶�״̬,0��ʾ��ֹ,1��ʾ�˶�
        gyro0   %��ʼ��������ƫ,deg/s
        wmThr   %���ٶ�ģ����ֵ,deg/s
        vmThr   %�ٶ�ģ����ֵ,m/s
        wCnt    %���ٶȼ�����
        vCnt    %�ٶȼ�����
        wN0     %���ٶȼ���ֵ,�˶�״̬0->1
        wN1     %���ٶȼ���ֵ,�˶�״̬1->0
        vN0     %�ٶȼ���ֵ,�˶�״̬0->1
        vN1     %�ٶȼ���ֵ,�˶�״̬1->0
    end
    
    methods
        % ���캯��
        function obj = motionDetector_gyro_vel(gyro0, dt, wmThr)
            % dt:����ʱ����,s
            obj.state0 = 0;
            obj.state = 0;
            obj.gyro0 = gyro0;
            obj.wmThr = wmThr;
            obj.vmThr = 0.25;
            obj.wCnt = 0;
            obj.vCnt = 0;
            obj.wN0 = 3;
            obj.wN1 = 2/dt; %2s�ڵĵ���
            obj.vN0 = 3;
            obj.vN1 = 2/dt; %2s�ڵĵ���
        end
        
        % ���к���
        function run(obj, gyro, vel)
            obj.state0 = obj.state; %��¼�ϴ��˶�״̬
            wm = norm(gyro-obj.gyro0); %���ٶ�ģ��
            vm = norm(vel); %�ٶ�ģ��
            if obj.state==0 %��ֹ״̬
                if wm<obj.wmThr
                    obj.wCnt = 0;
                else
                    obj.wCnt = obj.wCnt + 1;
                end
                if vm<obj.vmThr
                    obj.vCnt = 0;
                else
                    obj.vCnt = obj.vCnt + 1;
                end
                if obj.wCnt>=obj.wN0 || obj.vCnt>=obj.vN0
                    obj.wCnt = 0;
                    obj.vCnt = 0;
                    obj.state = 1;
                end
            else %�˶�״̬
                if wm>obj.wmThr
                    obj.wCnt = 0;
                else
                    obj.wCnt = obj.wCnt + 1;
                end
                if vm>obj.vmThr
                    obj.vCnt = 0;
                else
                    obj.vCnt = obj.vCnt + 1;
                end
                if obj.wCnt>=obj.wN1 && obj.vCnt>=obj.vN1
                    obj.wCnt = 0;
                    obj.vCnt = 0;
                    obj.state = 0;
                end
            end
        end
        
    end %end methods
    
end %end classdef