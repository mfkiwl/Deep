classdef CNR_threshold < handle
% �������ֵ

    properties
        strong
        middle
        recovery
        loss
    end
    
    methods
        function obj = CNR_threshold(para)
            obj.strong = para(1);
            obj.middle = para(2);
            obj.recovery = para(3);
            obj.loss = para(4);
        end
    end
    
end