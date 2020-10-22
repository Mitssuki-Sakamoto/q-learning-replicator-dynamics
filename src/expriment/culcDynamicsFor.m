function populationsHistories = culcDynamicsFor(replicatorDynamics, populations, N, DX_THRESHOLD, dt)
    populationsHistories = [reshape(populations,1,[])];
    count = 0;
    while 1
        count = count + dt;
        dv = replicatorDynamics(populations);
        populations = populations + (dv * dt);
        populationsHistories = [populationsHistories; reshape(populations,1,[])];
        if max(reshape(dv,1,[])) < DX_THRESHOLD || count >= N
            break;
        end
    end
end

