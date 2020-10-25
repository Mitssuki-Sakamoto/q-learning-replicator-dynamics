% とりあえずエージェント2体を想定
function dv = mutationReplicatorDynamics2(payoffMatrixes, populations, mutationRates)
    populationsSize = size(populations);
    strategyAveragePayoffs(:,1) = payoffMatrixes(:,:,1) * populations(:,2);
    strategyAveragePayoffs(:,2) = payoffMatrixes(:,:,2) * populations(:,1);
    
    newPopulations(:,1) = populations(:,1).*strategyAveragePayoffs(:,1) ...
        + sum(mutationRates(:,:,1) .* (repmat(populations(:,1),1,length(populations(:,1)))-repmat(populations(:,1).',length(populations(:,1)), 1))).';
    
    newPopulations(:,2) = populations(:,2).*strategyAveragePayoffs(:,2)...
        + sum(mutationRates(:,:,2) .* (repmat(populations(:,2),1,length(populations(:,2)))-repmat(populations(:,2).',length(populations(:,2)), 1))).';
    
    dv = newPopulations./sum(newPopulations) - populations;