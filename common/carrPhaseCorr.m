function carrPhase = carrPhaseCorr(carrPhase, corr, Fca)
% �ز���λУ��,��λ:��
% �����У����α���෴

carrPhase = carrPhase + (corr.dtsv + corr.dtrel - corr.dtsagnac - corr.TGD + corr.dtiono)*Fca;

end