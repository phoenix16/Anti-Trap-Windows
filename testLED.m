%
%  Developer : Prakriti Chintalapoodi - c.prakriti@gmail.com 
%

function testLED(touchFlag)
    % create an arduino object
    a = arduino();

    if touchFlag == true
        % start the loop to blink led for 10 seconds
        for i = 1:10
            writeDigitalPin(a, 'D11', 1);
            pause(0.5);
            writeDigitalPin(a, 'D11', 0);
            pause(0.5);
        end
        % end communication with arduino
        clear a
    end
end
