%
%  Developer : Prakriti Chintalapoodi - c.prakriti@gmail.com 
%

classdef antiTrapWindows < handle
    properties
        frameCounter
        baseline
        touchThreshold
        touchFlag
        angleStep
        lowlimit
        angleHighLimit
        servoAngle
        ATW_engaged % ATW = Anti-Trap Windows

        touchCommObject
        arduinoObject
        servoObject

        hFig
        hTitle
        COLS

        touchBox
        ATWBox
        directionBox
        upTriangle
        downTriangle
    end

    methods
        function obj = antiTrapWindows()
            useAttn = false;
            try
                obj.touchCommObject.close();
            catch
            end

            obj.touchCommObject = TouchComm.make('useAttn', useAttn);

%             idPacket = obj.touchCommObject.identify();
            obj.touchCommObject.makeConfigPackets();

            s = obj.touchCommObject.getStaticConfig();
            gain = s('gain');
            gain(13) = 2;
            s('gain') = gain;
            obj.touchCommObject.setStaticConfig(s);

            appInfo = obj.touchCommObject.getAppInfo();
            obj.COLS = appInfo.numCols;

            % Create info figure
            global infoFig; infoFig = figure('Color', 'w');
        end

        function initArduino(obj)
            % Initialize arduino object
            obj.arduinoObject = arduino();
            % Create servo object
            obj.servoObject = servo(obj.arduinoObject, 'D4');
        end

        function initVars(obj)
            % Initialize touch variables
            obj.frameCounter = 0;
            obj.baseline = [];
            obj.touchThreshold = 200;
            obj.touchFlag = false;

            % Initialize arduino variables
            obj.lowlimit = 0;
            obj.angleHighLimit = 0.15;
            obj.servoAngle = 0;
            obj.angleStep = 0.02;

            obj.ATW_engaged = false;

            % Initialize infoFig variables
            obj.touchBox = struct('L', 15, ...
                                  'R', 20, ...
                                  'T', 15, ...
                                  'B', 20);
            obj.ATWBox = struct('L', 23, ...
                                'R', 28, ...
                                'T', 15, ...
                                'B', 20);
            obj.upTriangle = struct('x', [19, 24, 21.5, 19], ...
                                    'y', [7, 7, 10, 7]);
            obj.downTriangle = struct('x', [19, 24, 21.5, 19], ...
                                      'y', [5, 5, 2, 5]);
        end

        function getSensorData(obj)
            tic
            clc

            % Initialize touch plot variables
            obj.hFig = figure();
            setappdata(obj.hFig, 'stopFlag', false);
            keyPressHandle = @(hObj, evt) setappdata(obj.hFig,'key',evt.Key);
            set(obj.hFig, 'keyPressFcn', keyPressHandle);
            subplot(211);
            hDeltaPlot = plot(nan(1, obj.COLS));
            hDeltaPlot.LineWidth = 2;
            hDeltaPlot.Marker = 'o';
            hDeltaPlot.MarkerFaceColor = 'b';
            axis([0 obj.COLS-1 -20 300]);
            obj.hTitle = title('xx.xx frames/sec');
            subplot(212);
            hRawPlot = plot(nan(1, obj.COLS));
            hRawPlot.LineWidth = 2;
            hRawPlot.Marker = 'o';
            hRawPlot.MarkerFaceColor = 'b';
            axis([0 obj.COLS-1 0 4095]);

            % Infinite loop gathering touch data
            while ishandle(obj.hFig)
                key = getappdata(obj.hFig, 'key');
                if ~isempty(key)
                    switch key
                        case 'escape'
                            break;
                        case 'space'
                            obj.baseline = [];
                    end
                    setappdata(obj.hFig, 'key', []);
                end
                % Get touch report
                [t, r] = obj.touchCommObject.getReport();
                if ~strcmp(t, 'raw')
                    continue;
                end
                obj.frameCounter = obj.frameCounter + 1;
                if isempty(obj.baseline)
                    obj.baseline = r.image(1:obj.COLS);
                end
                raw = r.image(1:obj.COLS);
                delta = raw - obj.baseline;

                % Check if touched
                if max(delta) > obj.touchThreshold
                    obj.touchFlag = true;
%                     disp('                     TOUCH DETECTED!');
                else
                    obj.touchFlag = false;
                end
%
%                 fprintf('touchFlag = %d\n', obj.touchFlag);
%                 fprintf('servoAngle = %.2f\n', obj.servoAngle);
%                 fprintf('angleStep = %.2f\n', obj.angleStep);

                writePosition(obj.servoObject, obj.servoAngle);

%                 if obj.angleStep < 0
%                     pause(0.5);
%                 else
                    pause(1);
%                 end

                % Bounds checking
                tempServoAngle = obj.servoAngle + obj.angleStep;
                if tempServoAngle >= obj.angleHighLimit
                    obj.angleStep = -obj.angleStep;
                end
                if obj.ATW_engaged == false && tempServoAngle < obj.lowlimit
                    obj.angleStep = -obj.angleStep;
                end

%                 disp('before ATW check');
%                 fprintf('ATW_engaged = %d\n', obj.ATW_engaged);
%                 fprintf('angleStep = %.2f\n', obj.angleStep);

                if tempServoAngle > 0 && ...
                   obj.touchFlag == true && ...
                   obj.angleStep > 0
%                     disp('                     ATW ENGAGED!');
                    obj.ATW_engaged = true;
                    obj.angleStep = -obj.angleStep;
                end

                if obj.ATW_engaged == true
%                     disp('                     ATW ENGAGED!');
                end

%                 disp('after ATW check');
%                 fprintf('ATW_engaged = %d\n', obj.ATW_engaged);
%                 fprintf('angleStep = %.2f\n', obj.angleStep);

                % Bounds checking if ATW
                if obj.ATW_engaged == true
                    tempServoAngle = obj.servoAngle + obj.angleStep;
                    if tempServoAngle < obj.lowlimit
                        obj.angleStep = -obj.angleStep;
                        obj.ATW_engaged = false;
%                         disp('                     ATW OFF!');
                    end
                end

%                 disp('after ATW bounds check');
%                 fprintf('ATW_engaged = %d\n', obj.ATW_engaged);
%                 fprintf('angleStep = %.2f\n\n', obj.angleStep);

                % Increment servo angle
                obj.servoAngle = obj.servoAngle + obj.angleStep;

                % Plot info figure
                global infoFig; set(0, 'CurrentFigure', infoFig);
                obj.plotBox(obj.touchBox, 'k', '-', obj.touchFlag, 'TOUCH');
                obj.plotBox(obj.ATWBox, 'k', '-', obj.ATW_engaged, 'AUTO REVERSE');
                obj.plotArrow(obj.angleStep);



                set(hDeltaPlot, 'YData', delta);
                set(hRawPlot, 'YData', raw);
                if (toc > 1)
                    set(obj.hTitle, 'String', sprintf('%.2f frames/sec', obj.frameCounter/toc));
                    tic;
                    obj.frameCounter = 0;
                end
                drawnow;
            end
            obj.touchCommObject.close();

            % end communication with arduino
            clear obj.arduinoObject
            clear ob.servoObject
        end

         function plotBox(obj, bbox, colorString, lineStyle, stateFlag, textString)
            hold on
            x = [bbox.L-0.5, bbox.L-0.5, bbox.R+0.5, bbox.R+0.5, bbox.L-0.5];
            y = [bbox.T-0.5, bbox.B+0.5, bbox.B+0.5, bbox.T-0.5, bbox.T-0.5];
            line(x, y, 'LineWidth', 2, 'Color', colorString, 'LineStyle', lineStyle);

            if stateFlag == true
                fillColor = [0 0.5 0];
            else
                fillColor = [0.9568 0.36 0.259]; % 244 92 66
            end

            fill(x, y, fillColor);
            set(gca, 'XTick', []); set(gca, 'YTick', []);
            set(findobj(gcf, 'type','axes'), 'Visible','off')

            text(bbox.L+2.5, bbox.T+3, textString, ...
                'HorizontalAlignment', 'center', ...
                'FontWeight', 'bold', ...
                'FontSize', 36);
            hold off
        end

        function plotArrow(obj, angleStep)
            hold on
            if angleStep > 0
                fill(obj.upTriangle.x, obj.upTriangle.y, 'b');
                fill(obj.downTriangle.x, obj.downTriangle.y, 'w');
            else
                fill(obj.downTriangle.x, obj.downTriangle.y, 'b');
                fill(obj.upTriangle.x, obj.upTriangle.y, 'w');
            end
            hold off
        end
    end
end

