% とりあえずエージェント2体を想定
function dv = mutationReplicatorDynamics(payoffMatrixes, populations, mutationRates)
    populationsSize = size(populations);
    dv = zeros(populationsSize);
    strategyAveragePayoffs(:,1) = payoffMatrixes(:,:,1) * populations(:,2);
    strategyAveragePayoffs(:,2) = payoffMatrixes(:,:,2) * populations(:,1);

    populationAveragePayoffs(1) =  populations(:,1).' * strategyAveragePayoffs(:,1);
    populationAveragePayoffs(2) =  populations(:,2).' * strategyAveragePayoffs(:,2);
    
    dv(:,1) = populations(:,1).*((strategyAveragePayoffs(:,1) - populationAveragePayoffs(1))) ...
        + sum(mutationRates(:,:,1) .* (repmat(populations(:,1),1,length(populations(:,1)))-repmat(populations(:,1).',length(populations(:,1)), 1))).';
    
    dv(:,2) = populations(:,2).*((strategyAveragePayoffs(:,2) - populationAveragePayoffs(2))) ...
        + sum(mutationRates(:,:,2) .* (repmat(populations(:,2),1,length(populations(:,2)))-repmat(populations(:,2).',length(populations(:,2)), 1))).';

    