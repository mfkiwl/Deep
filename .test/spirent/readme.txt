����˳��:
file_preprocess->csv_read->error_xxx_cal->result_figure

umt_gene.m
����Spirent�������õ�.umt�ļ�
��Ҫ�ȼ��ع켣����traj
.umt�ļ����켣�ļ�����һ��

csv_read.m
��ȡSpirent�����������.csv�ļ�,�����껭λ���ٶ�����
���ɱ���t0,�ǿ�ʼʱ�̵�GPS������
�켣���ݴ��ھ���motionSim��,[t,lat,lon,h,vn,ve,vd,an,ae,ad]

error_satnav_cal.m
�������ǵ������������������׼ֵ�����
�Ƚ������������һ��ͼ��,�ټ������,�ٻ��������
���ǵ�������������Ϊtime,pos,vel
��������׼ֵ����ΪmotionSim
ʹ�ò�ֵ�ķ������㶨λʱ�̵Ļ�׼ֵ

error_filter_cal.m
�����˲���������������׼ֵ�����
�Ƚ������������һ��ͼ��,�ټ������,�ٻ��������
�˲����������Ϊ:time,posF,velF,accF
��������׼ֵ����ΪmotionSim
ʹ�ò�ֵ�ķ������㶨λʱ�̵Ļ�׼ֵ

result_figure.m
��һЩ����������:
�����,����ΪCN0
�ز�Ƶ�ʱ仯��,����ΪcarrAccR
�켣���ٶȺͼ��ٶ�����,����ΪmotionSim,����д����