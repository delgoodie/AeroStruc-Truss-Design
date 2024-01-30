function result = TestTrussSolver()
    for i = 1:100
        rand_pos = rand(15,1) * 36;
        node = PositionToNode(rand_pos);
        [trueForce, trueIndex, trueDisplacementFlat] = SolveTruss_Momot(node);
        [optForce, optIndex, optDisplacement] = SolveTruss_Optimized(node);
        trueDisplacement = zeros(10,2);
        for k = 1:10
            trueDisplacement(k,:) = trueDisplacementFlat(k*2-1:k*2)';
        end
        if abs(trueForce - optForce) > 1e-3 || trueIndex ~= optIndex || norm(trueDisplacement - optDisplacement) > 1e-3
            result = 'Fail';
            return
        end
    end

    TimeTrials = zeros(1e3*10,2);
    for k=1:1e3
        TimeTrials(k*10-9:k*10,:) = PositionToNode(rand(15,1) * 36);
    end


    opt_func = @() arrayfun(@(i)SolveTruss_Optimized(TimeTrials(i*10-9:i*10,:)), 1:1e3);
    true_func = @() arrayfun(@(i)SolveTruss_Momot(TimeTrials(i*10-9:i*10,:), 1), 1:1e1);
    
    fprintf('Optimal is %.1f%% faster than Momot', (timeit(true_func)*100 / timeit(opt_func) - 1) * 100);


    result = 'Pass';
end