function [strategyAveragePayoffs,PopulationAveragePayoff] = avaragePayoff(payoffMatrix, strategies, strategiesRate)
    strategyAveragePayoffs =  strategies.' * payoffMatrix * strategies * strategiesRate;
    PopulationAveragePayoff = strategiesRate.' * strategyAveragePayoffs;
end

