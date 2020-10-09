classdef QLearningAgent < BaseAgent
    properties
        alpha
        gamma
        states
        actions
        actionSelect
        policyMap
        qTableMap
    end
    
    methods
        function obj = QLearningAgent(alpha, gamma, actions, actionSelect)
            obj.alpha = alpha;
            obj.gamma = gamma;
            obj.actions = actions;
            obj.states = [];
            obj.actionSelect = actionSelect;
            obj.policyMap = containers.Map;
            obj.qTableMap = containers.Map;
        end
        
        function action = act(obj, state)
            %randomSeed = RandStream('mlfg6331_64');
            if ~obj.hasState(state)
                obj.policyMap(state) = obj.actionSelect(obj.qTableMap(state));
            end
            actionProb = obj.policyMap(state);
            action = randsample(obj.actions, 1, true, actionProb);
        end
        
        function reset(obj)
            obj;
        end
        
        function updatePolicy(obj, state, action, reward, nextState)
            obj.updateQValue(state, action, reward, nextState);
            obj.policyMap(state) = obj.actionSelect(obj.qTableMap(state));
        end
        
        function setQValue(obj, state, qValue)
            obj.qTableMap(state) = qValue;
            obj.policyMap(state) = obj.actionSelect(obj.qTableMap(state));
        end
        
        function updateQValue(obj, state, action, reward, nextState)
            obj.hasState(state);
            obj.hasState(nextState);
            nextMaxQValue = max(obj.qTableMap(nextState));
            qValue = obj.qTableMap(state);
            qValue(obj.actions==action) = (1 - obj.alpha) * qValue(obj.actions==action) + obj.alpha * (reward + obj.gamma * nextMaxQValue);
            obj.qTableMap(state) = qValue; 
        end
        
        function has = hasState(obj, state)
            if ~(obj.qTableMap.isKey(state))
                obj.qTableMap(state) = zeros(1,length(obj.actions));
                has = false;
            else
                has = true;
            end
        end
    end
end