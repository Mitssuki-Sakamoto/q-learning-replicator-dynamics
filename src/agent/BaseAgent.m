classdef BaseAgent
    methods (Abstract)
        % 状態から行動を決定
        act(obj, state)
        % 方策を更新
        updatePolicy(obj, state, action, reward, nextState)
        % リセット
        reset(obj)
    end
end