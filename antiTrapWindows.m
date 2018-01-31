%
%  Developer : Prakriti Chintalapoodi - c.prakriti@gmail.com 
%

function antiTrapWindows()
    useAttn = false;
    try
        q.close();
    catch
    end

    q = TouchComm.make('useAttn', useAttn);

    idPacket = q.identify();
    q.makeConfigPackets();

    s = q.getStaticConfig();
    gain = s('gain');
    gain(13) = 2;
    s('gain') = gain;
    q.setStaticConfig(s);

    appInfo = q.getAppInfo();
    COLS = appInfo.numCols;

    % Initialize touch plot variables
    hFig = figure();
    setappdata(hFig, 'stopFlag', false);
    keyPressHandle = @(hObj, evt) setappdata(hFig,'key',evt.Key);
    set(hFig, 'keyPressFcn', keyPressHandle);
    subplot(211);
    hDeltaPlot = plot(nan(1, COLS));
    hDeltaPlot.LineWidth = 2;
    hDeltaPlot.Marker = 'o';
    hDeltaPlot.MarkerFaceColor = 'b';
    axis([0 COLS-1 -20 300]);
    hTitle = title('xx.xx frames/sec');
    subplot(212);
    hRawPlot = plot(nan(1, COLS));
    hRawPlot.LineWidth = 2;
    hRawPlot.Marker = 'o';
    hRawPlot.MarkerFaceColor = 'b';
    axis([0 COLS-1 0 4095]);
end

function sensorInit()
    % Initialize touch variables
    frameCounter = 0;
    baseline = [];
    touchThreshold = 200;
    touchFlag = false;
    % Initialize arduino variables
    a = arduino();
    clear s;
    % Create servo object
    s = servo(a, 'D4');
    angleStep = 0.03;
    angleLowLimit = 0;
    angleHighlimit = 0.33; % 60 deg
    angle = 0;
end

function getSensorData()
    tic

    % Infinite loop gathering touch data
    while ishandle(hFig)
        key = getappdata(hFig, 'key');
        if ~isempty(key)
            switch key
                case 'escape'
                    break;
                case 'space'
                    baseline = [];
            end
            setappdata(hFig, 'key', []);
        end
        % Get touch report
        [t, r] = q.getReport();
        if ~strcmp(t, 'raw')
            continue;
        end
        frameCounter = frameCounter + 1;
        if isempty(baseline)
            baseline = r.image(1:COLS);
        end
        raw = r.image(1:COLS);
        delta = raw - baseline;
        if max(delta) > touchThreshold
            touchFlag = true;
        end
        disp(touchFlag)

        % Write window position
        writePosition(s, angle);
        pause(1);
        angle = angle + angleStep;
        if angle >= angleHighlimit
            angleStep = -angleStep;
        end
        if angle <= angleLowlimit
            angleStep = -angleStep;
        end

    %     if touchFlag == true && windowActive == true
    %         current_pos = readPosition(s);
    %         current_pos = current_pos*180;
    %            fprintf('Current motor position is %d degrees\n', current_pos);
    %
    % %         for k = angles
    % %             writePosition(s, k);
    % %             pause(1);
    % %         end
    %     end


        set(hDeltaPlot, 'YData', delta);
        set(hRawPlot, 'YData', raw);
        if (toc > 1)
            set(hTitle, 'String', sprintf('%.2f frames/sec', frameCounter/toc));
            tic;
            frameCounter = 0;
        end
        drawnow;
    end
    q.close();


    % end communication with arduino
    clear a
end
