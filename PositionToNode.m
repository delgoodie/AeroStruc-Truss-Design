function Node = PositionToNode(position)
    position(3:16) = position(2:15);
    position(2) = 36;
    position(15:18) = position(13:16);
    position(13:14) = [0 ; 0];
    position(19:20) = [36 ; 0];

    Node = zeros(10, 2);
    for i = 1:10
        Node(i,:) = position(i*2-1:i*2)';
    end
end