% とりあえずエージェント2体を想定
function dv = qLearningDynamics(payoffMatrixes, populations, alpha, tau)
    populationsSize = size(populations);
    dv = zeros(populationsSize);
    strategyAveragePayoffs(:,1) = payoffMatrixes(:,:,1) * populations(:,2);
    strategyAveragePayoffs(:,2) = payoffMatrixes(:,:,2) * populations(:,1);

    populationAveragePayoffs(1) =  populations(:,1).' * strategyAveragePayoffs(:,1);
    populationAveragePayoffs(2) =  populations(:,2).' * strategyAveragePayoffs(:,2);

    dv(:,1) = populations(:,1)*alpha*tau.*(strategyAveragePayoffs(:,1) - populationAveragePayoffs(1)) ...
        + populations(:,1)*alpha.*sum(populations(:,1).*log(populations(:,1)*(populations(:,1).').^-1)).';
    
    dv(:,2) = populations(:,2)*alpha*tau.*(strategyAveragePayoffs(:,2) - populationAveragePayoffs(2)) ...
        + populations(:,2)*alpha.*sum(populations(:,2).*log(populations(:,2)*(populations(:,2).').^-1)).';
    