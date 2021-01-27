classdef motionDetector_gyro < handle
% ʹ��������������˶�״̬���
    
    properties
        state0  %�ϴε��˶�״̬
        state   %�˶�״̬,0��ʾ��ֹ,1��ʾ�˶�
        gyro0   %��ʼ��������ƫ,deg/s
        wmt     %���ٶ�ģ����ֵ,deg/s
        cnt     %������
        N0      %��⵽�������Ϊ�˶�
        N1      %��⵽�������Ϊ��ֹ
    end
    
    methods
        % ���캯��
        function obj = motionDetector_gyro(gyro0, dt, wmt)
            % dt:���ٶȲ���ʱ����,s
            obj.state0 = 0;
            obj.state = 0;
            obj.gyro0 = gyro0;
            obj.wmt = wmt;
            obj.cnt = 0;
            obj.N0 = 3; %�̶�3����
            obj.N1 = 2/dt; %2s�ڵĵ���
        end
        
        % ���к���
        function run(obj, gyro)
            obj.state0 = obj.state; %��¼�ϴ��˶�״̬
            wm = norm(gyro-obj.gyro0); %���ٶ�ģ��
            if obj.state==0 %��ֹ״̬
                if wm<obj.wmt
                    obj.cnt = 0;
                else
                    obj.cnt = obj.cnt+1;
                end
                if obj.cnt==obj.N0 %����N0������ٶȴ�����ֵ,��Ϊ�˶�
                    obj.cnt = 0;
                    obj.state = 1;
                end
            else %�˶�״̬
                if wm>obj.wmt
                    obj.cnt = 0;
                else
                    obj.cnt = obj.cnt+1;
                end
                if obj.cnt==obj.N1 %����N1������ٶ�С����ֵ,��Ϊ��ֹ
                    obj.cnt = 0;
                    obj.state = 0;
                end
            end
        end
        
    end %end methods
    
end %end classdef