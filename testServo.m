function testServo()
    % Create an arduino object
    a = arduino();

    % Create a servo object
    s = servo(a, 'D4');
    %    s = servo(a, 'D4', 'MinPulseDuration', 700*10^-6, 'MaxPulseDuration', 2300*10^-6);


    %       for angle = 0:0.05:1
    %            writePosition(s, angle);
    %            current_pos = readPosition(s);
    %            current_pos = current_pos*180;
    %            fprintf('Current motor position is %d degrees\n', current_pos);
    %            pause(0.2);
    %       end

    step = 0.02;
    low = 0;
    high = 0.12;

    angles = [low:step:high];
    for k = angles
        writePosition(s, k);
        pause(1);
    end


    angles = [high-step:-step:low];
    for k = angles
        writePosition(s, k);
        pause(1);
    end
end
