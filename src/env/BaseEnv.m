classdef BaseEnv
    methods (Abstract)
        % 状態から行動を決定
        step(obj, actions)
        reset(obj)
    end
end