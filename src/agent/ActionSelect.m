classdef ActionSelect
    methods(Static)
        function actionProb = greedySelect(qValues)
            actionProb = (max(qValues) == qValues)/sum((max(qValues) == qValues));
        end

        function actionProb = boltzmannSelect(qValues, tau)
            actionProb = exp(tau * qValues)/sum(exp(tau * qValues));
        end
    end
end