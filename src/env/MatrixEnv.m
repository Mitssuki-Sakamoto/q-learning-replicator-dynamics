classdef MatrixEnv < BaseEnv
    properties
        state
        payoffMatrixes
        actions
    end
    properties (Constant)
       ONLY_STATE = '1'
       TERMINAL_STATE = '0'
    end
    methods
        function obj = MatrixEnv(payoffMatrixes)
            obj.payoffMatrixes = payoffMatrixes;
            sizeMatrix = size(payoffMatrixes);
            if ~(sizeMatrix(1) == sizeMatrix(2))
                msg = '不正な行列です';
                error(msg);
            end
            obj.actions = (1:sizeMatrix(1));
            obj.state = obj.ONLY_STATE;
        end
        
        function [states, rewards, dones] = step(obj, actions)
            states(1) = MatrixEnv.TERMINAL_STATE;
            states(2) = MatrixEnv.TERMINAL_STATE;
            rewards(1) = obj.payoffMatrixes(actions(1), actions(2),1);
            rewards(2) = obj.payoffMatrixes(actions(2), actions(1),2);
            dones(1) = true;
            dones(2) = true;
        end
        
        function states = reset(obj)
            obj.state = MatrixEnv.ONLY_STATE;
            states(1) = obj.state;
            states(2) = obj.state;
        end
    end
end