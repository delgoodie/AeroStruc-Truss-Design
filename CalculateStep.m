function step = CalculateStep(r0, f0, h, gh)

    grad = zeros(length(r0),1);

    for i = 1:length(r0)
        r_step = r0;
        grad_step = h * gh;
        r_step(i) = r_step(i) + grad_step;
        f_step = CalculateMaxForce(PositionToNode(r_step));
        grad(i) = (f_step - f0) / grad_step;
    end
    
    step = -grad * h;

    % Clamp
    step(step>1) = 1;
    step(step<-1) = -1;
end