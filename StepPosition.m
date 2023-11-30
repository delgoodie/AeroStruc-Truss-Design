function r = StepPosition(r0, step)
    node0 = PositionToNode(r0);
    nstep = StepToNode(step);


    bounds = [ 0 0   36 36     % 1
               0 36   0 36      % 2
               0 36   0 36      % 3
               0 36   0 36      % 4
               0 36   0 36      % 5
               0 36   0 36      % 6
               0 0   0 0        % 7
               0 36   0 36      % 8
               0 36   0 36      % 9
               36 36   0 0      % 10
             ];




    % Proximity Limit
    MIN_DST = .1;
    for i = 1:length(node0) % could iterate this to prevent order blocking (but prob computationally unoptimal)
        for k = 1:length(node0)
            prevPos = node0(i,:);
            newPos = prevPos + nstep(i,:);
            delta = node0(k,:) - newPos;
            dist = norm(delta);
            if dist == 0 % if nodes on top of each other, pull toward center
                dist = MIN_DST / 10;
                delta = ([36/2, 36/2] - prevPos) / norm([36/2, 36/2] - prevPos) * dist;
            end
            if dist < MIN_DST
                tri_height = sqrt(MIN_DST^2 - (dist/2)^2);
                height_dir = [-delta(2), delta(1)] / dist;
                p1 = prevPos + delta / 2 + height_dir * tri_height;
                p2 = prevPos + delta / 2 - height_dir * tri_height;
                if dot(p1 - prevPos, nstep(i,:)) > dot(p2 - prevPos, nstep(i,:))
                    nstep(i,:) = p1 - prevPos;
                else
                    nstep(i,:) = p2 - prevPos;
                end
            end
        end
    end

    % Boundary Limit
    for i = 1:length(node0)
        for c = 1:2
            if node0(i, c) + nstep(i, c) < bounds(i, 2*c-1)
                nstep(i, c) = bounds(i, 2*c-1) - node0(i, c);
            elseif node0(i, c) + nstep(i, c) > bounds(i, 2*c)
                nstep(i, c) = bounds(i, 2*c) - node0(i, c);
            else
            end
        end
    end


    node1 = node0 + nstep;
    r = NodeToPosition(node1);
end