function Node = StepToNode(step)
    step(3:16) = step(2:15);
    step(2) = 0;
    step(15:18) = step(13:16);
    step(13:14) = [0 ; 0];
    step(19:20) = [0 ; 0];

    Node = zeros(10, 2);
    for i = 1:10
        Node(i,:) = step(i*2-1:i*2)';
    end
end