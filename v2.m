function varargout = v2(varargin)
% V2 MATLAB code for v2.fig
%      V2, by itself, creates a new V2 or raises the existing
%      singleton*.
%
%      H = V2 returns the handle to a new V2 or the handle to
%      the existing singleton*.
%
%      V2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in V2.M with the given input arguments.
%
%      V2('Property','Value',...) creates a new V2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before v2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to v2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help v2

% Last Modified by GUIDE v2.5 16-Jul-2018 11:03:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @v2_OpeningFcn, ...
    'gui_OutputFcn',  @v2_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before v2 is made visible.
function v2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to v2 (see VARARGIN)

% Choose default command line output for v2

handles.output = hObject;
handles.button_pressed = 0;

% tutorial message
handles.Instruction = "Please load the image using the Load button on top left corner.";
set(handles.InstructionBox, 'String', handles.Instruction);
drawnow;

% Calibration button is invisible until user chooses data collection mode
set(handles.CalibrateImageButton,'Visible','Off');
% Data Collection button is invisible until user has calibrated the image
set(handles.DataCollectionButton,'Visible','Off');
set(handles.AnalyzeDataButton,'Visible','Off');
set(handles.popupmenu1,'Visible','Off');
set(handles.prev,'Visible','Off');
set(handles.next,'Visible','Off');
set(handles.DefineROIButton,'Visible','Off');
set(handles.SaveDataButton,'Visible','Off');
set(handles.InstructionBox,'enable','inactive');
axes(handles.axes1);
cla reset;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes v2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = v2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in LoadDataButton.
function LoadDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to LoadDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% store current directory so we can come back and script will keep working
scr_dir = cd;

handles.output = hObject;

% get dicom file directory
[filename, pathname, ~] = uigetfile('*.dcm','Select the first dicom file in the stack');
% go to dicom file location and read
cd(pathname);
handles.stack = dicomread(filename);
handles.stacksize = size(handles.stack);
handles.stacksize = handles.stacksize(4);
% go back to .m file location
cd(scr_dir);

% plot the first image in dicom stack
handles.slide = 1;
axes(handles.axes1);
imshow(handles.stack(:,:,:,handles.slide)); hold on;

set(handles.slider1,'min',1);
set(handles.slider1,'max',handles.stacksize);
set(handles.slider1,'Value',handles.slide);

handles.filename = filename;
filename = filename(1,1:end-4);
filename = strcat('Subject: ',filename);
set(handles.FileText,'String',filename);
set(handles.popupmenu1,'Visible','On');
set(handles.prev,'Visible','On');
set(handles.next,'Visible','On');
set(handles.SaveDataButton,'Visible','On');
handles.ImageCountString = strcat('Image Number: ',num2str(handles.slide));
set(handles.ImageCountText,'String',handles.ImageCountString);

handles.Instruction = "Please select data collection mode from the drop down menu on the right." + newline + handles.Instruction;
set(handles.InstructionBox, 'String', handles.Instruction);
% set(handles.text3, 'String', 'Notes: Please select data collection mode from the drop down menu on the right.');
drawnow;

guidata(hObject,handles);

% --- Executes on button press in prev.
% Will move to previous image in the dicom stack
% Unless current image is the first image in the stack, in which case will
% stay on the first image of the stack.
function prev_Callback(hObject, eventdata, handles)
% hObject    handle to prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.slide == 1 % if first image, stay on first image
    % do nothing
else
    handles.slide = handles.slide - 1; % update slide number
    guidata(hObject, handles);
    set(handles.slider1,'Value',handles.slide);
    drawnow;
    axes(handles.axes1);
    cla reset;
    imshow(handles.stack(:,:,:,handles.slide)); hold on;
    if isfield(handles,'diam_data_pts')
        currentsize = size(handles.diam_data_pts);
        currentsize = currentsize(1,2);
        if handles.slide <= currentsize && not(isempty(handles.diam_data_pts{handles.slide}))
            plot(handles.diam_data_pts{handles.slide}{1}(:,1),handles.diam_data_pts{handles.slide}{1}(:,2),...
                'ko','MarkerSize',5,'MarkerFaceColor',[0 1 0]);
            plot(handles.diam_data_pts{handles.slide}{2}(:,1),handles.diam_data_pts{handles.slide}{2}(:,2),...
                'ko','MarkerSize',5,'MarkerFaceColor',[1 0 0]);
        end
    end
end


handles.ImageCountString = strcat('Image Number: ',num2str(handles.slide));
set(handles.ImageCountText,'String',handles.ImageCountString);
set(handles.slider1,'Value',handles.slide);

guidata(hObject, handles);


% --- Executes on button press in next.
% Will move to next image in the dicom stack
% Unless current image is the last image in the stack, in which case will
% stay on the last image of the stack
function next_Callback(hObject, eventdata, handles)
% hObject    handle to next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.slide == handles.stacksize % if last image, stay on last image
    % do nothing
    %     axes(handles.axes1);
    %     cla reset;
    %     imshow(handles.stack(:,:,:,handles.slide));
else
    handles.slide = handles.slide + 1; % update slide number
    guidata(hObject, handles);
    set(handles.slider1,'Value',handles.slide);
    drawnow;
    axes(handles.axes1);
    cla reset;
    imshow(handles.stack(:,:,:,handles.slide)); hold on;

    if isfield(handles,'diam_data_pts')
        currentsize = size(handles.diam_data_pts);
        currentsize = currentsize(1,2);
        if handles.slide <= currentsize && not(isempty(handles.diam_data_pts{handles.slide}))
            plot(handles.diam_data_pts{handles.slide}{1}(:,1),handles.diam_data_pts{handles.slide}{1}(:,2),...
                'ko','MarkerSize',5,'MarkerFaceColor',[0 1 0]);
            plot(handles.diam_data_pts{handles.slide}{2}(:,1),handles.diam_data_pts{handles.slide}{2}(:,2),...
                'ko','MarkerSize',5,'MarkerFaceColor',[1 0 0]);
        end
    end
end

handles.ImageCountString = strcat('Image Number: ',num2str(handles.slide));
set(handles.ImageCountText,'String',handles.ImageCountString);
set(handles.slider1,'Value',handles.slide);

guidata(hObject, handles);


% --- Executes on selection change in popupmenu1.
% Selects what kind of data will be collected. Also controls the visibility
% of buttons that are necessary for data collection.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

handles.case = handles.popupmenu1.Value;
% if no data collection mode has been selected, no buttons are visible.
if handles.case == 2 || handles.case == 3
    set(handles.CalibrateImageButton,'Visible','On');
else
    set(handles.CalibrateImageButton,'Visible','Off');
end

handles.Instruction = "Please calibrate the image using the Calibration Button." + newline + handles.Instruction;
set(handles.InstructionBox, 'String', handles.Instruction);
%set(handles.text3, 'String', 'Notes: Please calibrate the image using the Calibration Button.');
drawnow;

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CalibrateImageButton.
% Calibrates image resolution
function CalibrateImageButton_Callback(hObject, eventdata, handles)
% hObject    handle to CalibrateImageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.Instruction = "Please zoom on to the calibration region using left mouse click, then press enter" + newline + handles.Instruction;
set(handles.InstructionBox, 'String', handles.Instruction);
%set(handles.text3, 'String', 'Notes: Please zoom on to the calibration region using left mouse click, then press enter');
drawnow;

axes(handles.axes1);
hold on
zoom on %zoom in on region
waitfor(gcf,'CurrentCharacter',char(13)) %hit 'Enter' to get out of zoom
zoom reset
zoom off

handles.Instruction = "Press on the major tick marks for calibration." + newline + handles.Instruction;
set(handles.InstructionBox, 'String', handles.Instruction);
% set(handles.text3, 'String', 'Notes: Press on the major tick marks for calibration.');
drawnow;

handles.res_matrix = zeros(2,2);
[handles.res_matrix(1,1),handles.res_matrix(1,2)] = ginput(1);
plot(handles.res_matrix(1,1),handles.res_matrix(1,2),'c+');
[handles.res_matrxi(2,1),handles.res_matrix(2,2)] = ginput(1);
plot(handles.res_matrix(2,1),handles.res_matrix(2,2),'c+');
hold off;

handles.Instruction = "Please define region of interest (ROI) by clicking on Define ROI button." + newline + handles.Instruction;
set(handles.InstructionBox, 'String', handles.Instruction);
% set(handles.text3, 'String', 'Notes: Please define region of interest (ROI) by clicking on Define ROI button. ');
drawnow;

axes(handles.axes1);
cla reset;
imshow(handles.stack(:,:,:,handles.slide)); hold on;
handles.calib = 1/(abs(handles.res_matrix(1,2) - handles.res_matrix(2,2)));
handles.calib_string = strcat('Image resolution = ',num2str(handles.calib),' mm');
guidata(hObject,handles);
%disp(strcat({'Image resolution = '},num2str(handles.calib),{' mm'}))
set(handles.DefineROIButton,'Visible','On');
guidata(hObject,handles);

% --- Executes on button press in DefineROIButton.
function DefineROIButton_Callback(hObject, eventdata, handles)
% hObject    handle to DefineROIButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in AnalyzeDataButton.

handles.Instruction = "Please define ROI by zooming in on the region of interest. i.e. vessel" + newline + handles.Instruction;
set(handles.InstructionBox, 'String', handles.Instruction);
% set(handles.text3, 'String', 'Notes: Please define ROI by zooming in on the region of interest. i.e. vessel');
drawnow;

h = figure;
imshow(handles.stack(:,:,:,handles.slide)); hold on;
zoom on %zoom in on region
waitfor(gcf,'CurrentCharacter',char(13)) %hit 'Enter' to get out of zoom
handles.x_dimen = xlim;
handles.y_dimen = ylim;
zoom off;
close(h);
set(handles.DataCollectionButton,'Visible','On');

handles.Instruction = "Please start collecting data using Data Collection Button." + newline + handles.Instruction;
set(handles.InstructionBox, 'String', handles.Instruction);
% set(handles.text3, 'String', 'Notes: Please start collecting data using Data Collection Button. ');
drawnow;
guidata(hObject,handles);


% --- Executes on button press in DataCollectionButton.
function DataCollectionButton_Callback(hObject, eventdata, handles)
% hObject    handle to DataCollectionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch handles.case
    % case 1: logitudinal
    % case 2: cross-sectional
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 2

        handles.button_pressed = handles.button_pressed + 1;

        handles.Instruction = "Please collect data by clicking along the borders of the vessel." + newline + handles.Instruction;
        set(handles.InstructionBox, 'String', handles.Instruction);
        drawnow;

        while handles.button_pressed == 1

            guidata(hObject,handles);
            axes(handles.axes1);
            cla reset;
            imshow(handles.stack(:,:,:,handles.slide));
            hold on
            xlim([handles.x_dimen(1) handles.x_dimen(2)]);
            ylim([handles.y_dimen(1) handles.y_dimen(2)]);

            for j = 1:2
                adv_pt = 1; %intialize to enter loop
                handles.geom_pt_matrix = [];
                while adv_pt == 1
                    %right click to exit; changes adv_pt to 2
                    [pt_x,pt_y,adv_pt] = ginput(1);
                    if j == 1
                        plot(pt_x,pt_y,'ko','MarkerSize',5,'MarkerFaceColor',...
                            [0 1 0])
                    else
                        plot(pt_x,pt_y,'ko','MarkerSize',5,'MarkerFaceColor',...
                            [1 0 0])
                    end
                    hold on
                    handles.geom_pt_matrix = [handles.geom_pt_matrix; pt_x pt_y];
                end
                handles.diam_data_pts{handles.slide}{j} = handles.geom_pt_matrix;
            end

            handles.FalseProgress = size(handles.diam_data_pts);
            handles.FalseProgress = handles.FalseProgress(1,2);
            handles.Progress = handles.FalseProgress;

            for j = 1:handles.FalseProgress
                if isempty(handles.diam_data_pts{1,j})
                    handles.Progress = handles.Progress - 1;
                end
            end

            handles.ProgressStringTop = strcat('Completed: ', num2str(handles.Progress));
            handles.ProgressStringBottom = strcat('Remaining: ', num2str(handles.stacksize - handles.Progress));
            set(handles.ProgressTextTop,'String',handles.ProgressStringTop);
            set(handles.ProgressTextBottom,'String',handles.ProgressStringBottom);
            drawnow;

            axes(handles.progressbar);
            barh((handles.Progress/handles.stacksize)*100,'g');
            xlim([0, 100]);
            set(gca,'Color',[0.94 0.94 0.94]);
            set(gca,'ytick',[]);
            xlabel('% completed');
            set(gca,'xtick',[0 20 40 60 80 100]);
            ylim([1.0,1.3]);

            if handles.Progress/handles.stacksize == 1
                set(handles.AnalyzeDataButton,'Visible','On');
                handles.Instruction = "Data Collection has been completed. You can now analyze data using Analzy Data Button." + newline + handles.Instruction;
                set(handles.InstructionBox, 'String', handles.Instruction);
                drawnow;
                handles.button_pressed = handles.button_pressed + 1;
            end

            axes(handles.axes1);
            if handles.slide < handles.stacksize
                handles.slide = handles.slide + 1;
                cla reset;
                imshow(handles.stack(:,:,:,handles.slide));
                hold on
                xlim([handles.x_dimen(1) handles.x_dimen(2)]);
                ylim([handles.y_dimen(1) handles.y_dimen(2)]);

                set(handles.slider1,'Value',handles.slide);
                handles.ImageCountString = strcat('Image Number: ',num2str(handles.slide));
                set(handles.ImageCountText,'String',handles.ImageCountString);
            end

        end

        WarningString = 'Data Collection not complete on image(s): ';
        if handles.FalseProgress == handles.stacksize && handles.slide == handles.stacksize
            WarningBool = false;
            for k = 1:handles.stacksize
                if isempty(handles.diam_data_pts{1,k})
                    WarningBool = true;
                    WarningString = strcat(WarningString,num2str(k));
                    WarningString = strcat(WarningString,', ');
                end
            end
            if WarningBool
                WarningString = WarningString(1,1:end-1);
                msgbox(WarningString,'Warning','warn');
            end
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    case 3
        handles.button_pressed = handles.button_pressed + 1;

        handles.Instruction = "Please collect data by clicking along the borders of the vessel." + newline + handles.Instruction;
        set(handles.InstructionBox, 'String', handles.Instruction);
        drawnow;

        while handles.button_pressed == 1

            s = handles.slide;

            guidata(hObject,handles);
            axes(handles.axes1);
            cla reset;
            imshow(handles.stack(:,:,:,s));
            hold on;
            xlim([handles.x_dimen(1) handles.x_dimen(2)]);
            ylim([handles.y_dimen(1) handles.y_dimen(2)]);

            handles.Instruction = "Please double click the beginning point when you are done segmenting." + newline + handles.Instruction;
            set(handles.InstructionBox,'String',handles.Instruction);
            drawnow;

            [handles.mask{s},handles.x{s},handles.y{s}] = roipoly(handles.stack(:,:,:,s));
            center_struct = regionprops(handles.mask{s},'centroid');
            handles.center{s} = cat(1,center_struct.Centroid);

            % AreaCalcTag
            handles.radii_points = 60;
            [handles.xx{s},handles.yy{s}] = equiangularSampling(handles.x{s},handles.y{s},handles.radii_points,...
                handles.center{s}(1),handles.center{s}(2));

            handles.area(s) = (handles.calib^2)*polyarea(handles.xx{s},handles.yy{s});
            % handles.r_avg_area(s) = sqrt(handles.area(s)/pi);

            guidata(hObject,handles);

            handles.FalseProgress = length(handles.x);
            handles.Progress = handles.FalseProgress;

            for j = 1:handles.FalseProgress
                if isempty(handles.x{j})
                    handles.Progress = handles.Progress - 1;
                end
            end

            guidata(hObject,handles);

            handles.ProgressStringTop = strcat('Completed: ', num2str(handles.Progress));
            handles.ProgressStringBottom = strcat('Remaining: ', num2str(handles.stacksize - handles.Progress));
            set(handles.ProgressTextTop,'String',handles.ProgressStringTop);
            set(handles.ProgressTextBottom,'String',handles.ProgressStringBottom);
            drawnow;

            guidata(hObject,handles);

            axes(handles.progressbar);
            barh((handles.Progress/handles.stacksize)*100,'g');
            xlim([0, 100]);
            set(gca,'Color',[0.94 0.94 0.94]);
            set(gca,'ytick',[]);
            xlabel('% completed');
            set(gca,'xtick',[0 20 40 60 80 100]);
            ylim([1.0,1.3]);

            if handles.Progress/handles.stacksize == 1
                set(handles.AnalyzeDataButton,'Visible','On');
                handles.Instruction = "Data Collection has been completed. You can now analyze data using Analzy Data Button." + newline + handles.Instruction;
                set(handles.InstructionBox, 'String', handles.Instruction);
                drawnow;
                handles.button_pressed = handles.button_pressed + 1;
            end

            axes(handles.axes1);
            if handles.slide < handles.stacksize
                handles.slide = handles.slide + 1;
                cla reset;
                imshow(handles.stack(:,:,:,handles.slide));
                hold on
                xlim([handles.x_dimen(1) handles.x_dimen(2)]);
                ylim([handles.y_dimen(1) handles.y_dimen(2)]);

                set(handles.slider1,'Value',handles.slide);
                handles.ImageCountString = strcat('Image Number: ',num2str(handles.slide));
                set(handles.ImageCountText,'String',handles.ImageCountString);
            end

        end

        WarningString = 'Data Collection not complete on image(s): ';
        if handles.FalseProgress == handles.stacksize && handles.slide == handles.stacksize
            WarningBool = false;
            for k = 1:handles.stacksize
                if isempty(handles.x{k})
                    WarningBool = true;
                    WarningString = strcat(WarningString,num2str(k));
                    WarningString = strcat(WarningString,', ');
                end
            end
            if WarningBool
                WarningString = WarningString(1,1:end-1);
                msgbox(WarningString,'Warning','warn');
            end
        end

end
guidata(hObject,handles);

% --- Executes on button press in SaveDataButton.
function SaveDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
scr_dir = cd;
[file,path] = uiputfile(' .mat');
cd(path);
save(file);
cd(scr_dir);

% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
axes(handles.axes1);
%cla reset;
handles.slide = round(get(hObject,'Value'));
guidata(hObject, handles);
imshow(handles.stack(:,:,:,handles.slide));
handles.ImageCountString = strcat('Image Number: ',num2str(handles.slide));
set(handles.ImageCountText,'String',handles.ImageCountString);

if isfield(handles,'diam_data_pts')
    currentsize = size(handles.diam_data_pts);
    currentsize = currentsize(1,2);
    if handles.slide <= currentsize && not(isempty(handles.diam_data_pts{handles.slide}))
        plot(handles.diam_data_pts{handles.slide}{1}(:,1),handles.diam_data_pts{handles.slide}{1}(:,2),...
            'ko','MarkerSize',5,'MarkerFaceColor',[0 1 0]);
        plot(handles.diam_data_pts{handles.slide}{2}(:,1),handles.diam_data_pts{handles.slide}{2}(:,2),...
            'ko','MarkerSize',5,'MarkerFaceColor',[1 0 0]);
    end
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function AnalyzeDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to AnalyzeDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch handles.case

    case 2

        handles.interp_pts = 10;

        guidata(hObject,handles);
        %extract diameter data
        handles.diam = zeros(handles.stacksize,10);
        guidata(hObject,handles);
        for m = 1:size(handles.diam_data_pts,2)

            %find minimum x-values between top and bottom and take maximum
            handles.min_x = min(handles.diam_data_pts{m}{1}(:,1));
            if min(handles.diam_data_pts{m}{2}(:,1)) > handles.min_x
                handles.min_x = min(handles.diam_data_pts{m}{2}(:,1));
            end

            %find maximum x-values between top and bottom and take minimum
            handles.max_x = max(handles.diam_data_pts{m}{1}(:,1));
            if max(handles.diam_data_pts{m}{2}(:,1)) < handles.max_x
                handles.max_x = max(handles.diam_data_pts{m}{2}(:,1));
            end
            handles.min_x = ceil(handles.min_x);
            handles.max_x = floor(handles.max_x);

            %linearly interpolate x position and round
            handles.x_pts = round(linspace(handles.min_x,handles.max_x,10))';

            %interpolate y position at top and bottom
            handles.interp_top = interp1(handles.diam_data_pts{m}{1}(:,1),...
                handles.diam_data_pts{m}{1}(:,2),handles.x_pts,'pchip');
            handles.interp_bot = interp1(handles.diam_data_pts{m}{2}(:,1),...
                handles.diam_data_pts{m}{2}(:,2),handles.x_pts,'pchip');

            handles.diam(m,:) = handles.calib*abs(handles.interp_top - handles.interp_bot)';
            guidata(hObject,handles);
        end

        %figure
        %colormap = hsv(size(handles.diam,2));
        for j = 1:size(handles.diam,2)

            %smooth data
            data = smooth(handles.diam(:,j),handles.interp_pts,'sgolay');
            % plot(data,'-','Color',colormap(j,:),'LineWidth',1)
            hold on
            guidata(hObject,handles);
        end
        ylabel('Diameter (mm)')
        hold off

        %determine overlapping x-positions across image set
        handles.min_x_globe = 0;
        handles.max_x_globe = inf;
        guidata(hObject,handles);
        for m = 1:size(handles.diam_data_pts,2)

            %determine min/max values within given image
            for j = 1:2
                %find minimum x-values between top and bottom and take maximum
                handles.min_x = min(handles.diam_data_pts{m}{1}(:,1));
                if min(handles.diam_data_pts{m}{2}(:,1)) > handles.min_x
                    handles.min_x = min(handles.diam_data_pts{m}{2}(:,1));
                end

                %find maximum x-values between top and bottom and take minimum
                handles.max_x = max(handles.diam_data_pts{m}{1}(:,1));
                if max(handles.diam_data_pts{m}{2}(:,1)) < handles.max_x
                    handles.max_x = max(handles.diam_data_pts{m}{2}(:,1));
                end
                handles.min_x = ceil(handles.min_x);
                handles.max_x = floor(handles.max_x);
            end

            %Check image min/max with global min/max
            if handles.min_x > handles.min_x_globe
                handles.min_x_globe = handles.min_x;
            end
            if handles.max_x < handles.max_x_globe
                handles.max_x_globe = handles.max_x;
            end
            guidata(hObject,handles);
        end
        handles.x_pts_globe = linspace(handles.min_x_globe,handles.max_x_globe,10)';
        guidata(hObject,handles);

        %interp y-positions for global x-positions
        handles.diam_data_pts_globe = cell(size(handles.stack,4),1);
        guidata(hObject,handles);
        for m = 1:size(handles.diam_data_pts,2)

            %interpolate y position at top and bottom
            handles.interp_top = interp1(handles.diam_data_pts{m}{1}(:,1),...
                handles.diam_data_pts{m}{1}(:,2),handles.x_pts_globe,'pchip');
            handles.interp_bot = interp1(handles.diam_data_pts{m}{2}(:,1),...
                handles.diam_data_pts{m}{2}(:,2),handles.x_pts_globe,'pchip');

            %populate global position data
            handles.diam_data_pts_globe{m}{1} = [handles.x_pts_globe handles.interp_top];
            handles.diam_data_pts_globe{m}{2} = [handles.x_pts_globe handles.interp_bot];
            guidata(hObject,handles);
        end

        %extract diameter data
        handles.diam_globe = zeros(size(handles.stack,4),handles.interp_pts);
        guidata(hObject,handles);

        for m = 1:size(handles.diam_data_pts,2)

            %find minimum x-values between top and bottom and take maximum
            handles.min_x = min(handles.diam_data_pts{m}{1}(:,1));
            guidata(hObject,handles);
            if min(handles.diam_data_pts{m}{2}(:,1)) > handles.min_x
                handles.min_x = min(handles.diam_data_pts{m}{2}(:,1));
            end
            guidata(hObject,handles);
            %find maximum x-values between top and bottom and take minimum
            handles.max_x = max(handles.diam_data_pts{m}{1}(:,1));
            guidata(hObject,handles);
            if max(handles.diam_data_pts{m}{2}(:,1)) < handles.max_x
                handles.max_x = max(handles.diam_data_pts{m}{2}(:,1));
            end
            guidata(hObject,handles);
            handles.min_x = ceil(handles.min_x);
            handles.max_x = floor(handles.max_x);
            guidata(hObject,handles);

            %linearly interpolate x position and round
            handles.x_pts = round(linspace(handles.min_x,handles.max_x,10))';
            guidata(hObject,handles);

            %interpolate y position at top and bottom
            handles.interp_top = interp1(handles.diam_data_pts{m}{1}(:,1),...
                handles.diam_data_pts{m}{1}(:,2),handles.x_pts,'pchip');
            guidata(hObject,handles);
            handles.interp_bot = interp1(handles.diam_data_pts{m}{2}(:,1),...
                handles.diam_data_pts{m}{2}(:,2),handles.x_pts,'pchip');
            guidata(hObject,handles);

            handles.diam_globe(m,:) = handles.calib*abs(handles.interp_top - handles.interp_bot)';
            guidata(hObject,handles);
        end
        guidata(hObject,handles);

        %average diameter data across spatial positions
        handles.diam_globe_avg = smooth(mean(handles.diam_globe,2),7,'sgolay');
        guidata(hObject,handles);
        % figure, plot(handles.diam_globe_avg,'k-')

        %extract min, max, avg diameter across cardiac cycle
        handles.diam_extract = handles.diam_globe_avg;%(41:62);
        guidata(hObject,handles);
        handles.max_diam_string = strcat('Max diameter is ',...
            num2str(max(handles.diam_extract)));
        handles.min_diam_string =  strcat('Min. diameter is ',...
            num2str(min(handles.diam_extract)));
        handles.avg_diam_string =  strcat('Avg. diameter is ',...
            num2str(mean(handles.diam_extract)));

        %quantify circumferential stretch
        handles.circ_stretch_globe = handles.diam_globe_avg./min(handles.diam_globe_avg);
        guidata(hObject,handles);

        %quantify circumferential (Green) strain
        handles.circ_strain_globe = 0.5*(handles.circ_stretch_globe.^2 - 1);
        guidata(hObject,handles);

        %quantify circumfrential avg strain
        handles.circ_strain_avg = mean(handles.circ_strain_globe);

        %determine peak strain
        handles.max_strain_string =  strcat('Max circumferential strain is ',...
            num2str(max(handles.circ_strain_globe)));

        %determine avg strain
        handles.avg_strain_string = strcat('Avg circumfrential strain is ',...
            num2str(handles.circ_strain_avg));

        %%%%% auto save %%%%%


        % make folder
        foldername = strcat(handles.filename(1,1:end-4),'_analyzed');
        mkdir(foldername);


        % save variables
        save(strcat(foldername,'/',handles.filename(1,1:end-4),'_variables.mat'),'handles');


        % text file containing important values
        textfile_name = strcat(foldername,'/',handles.filename(1,1:end-4),'_strain_results.txt');
        fid = fopen(textfile_name,'wt');
        fprintf(fid, '%s\n%s\n%s\n%s\n%s\n%s' ,handles.calib_string,handles.max_diam_string,...
            handles.min_diam_string,handles.avg_diam_string,handles.max_strain_string,handles.avg_strain_string);
        fclose(fid);



        % csv file containing diameter values
        csvwrite(strcat(foldername,'/',handles.filename(1,1:end-4),'_diameter.csv'),handles.diam);



        % making the video

        writerObj = VideoWriter(strcat(foldername,'/',handles.filename(1,1:end-4,...
            '_diameters.avi')));
        open(writerObj);

        for m = 1:size(handles.stack,4)

            %plot US image
            h = figure;
            imshow(handles.stack(:,:,:,m))
            hold on

            %find minimum x-values between top and bottom and take maximum
            min_x = min(handles.diam_data_pts{m}{1}(:,1));
            if min(handles.diam_data_pts{m}{2}(:,1)) > min_x
                min_x = min(handles.diam_data_pts{m}{2}(:,1));
            end

            %find maximum x-values between top and bottom and take minimum
            max_x = max(handles.diam_data_pts{m}{1}(:,1));
            if max(handles.diam_data_pts{m}{2}(:,1)) < max_x
                max_x = max(handles.diam_data_pts{m}{2}(:,1));
            end
            min_x = ceil(min_x);
            max_x = floor(max_x);

            %linearly interpolate x position and round
            x_pts = round(linspace(min_x,max_x,10))';

            %interpolate y position at top and bottom
            interp_top = interp1(handles.diam_data_pts{m}{1}(:,1),...
                handles.diam_data_pts{m}{1}(:,2),x_pts,'pchip');
            interp_bot = interp1(handles.diam_data_pts{m}{2}(:,1),...
                handles.diam_data_pts{m}{2}(:,2),x_pts,'pchip');

            %plot borders
            plot(x_pts,interp_top,'b-','LineWidth',2)
            hold on
            plot(x_pts,interp_bot,'r-','LineWidth',2)
            hold off
            frame = getframe;
            writeVideo(writerObj,frame);
            pause(0.5)
            close(h)
        end
        close(writerObj);



        % Saving segmented pictures
        for k = 1:handles.stacksize
            h = figure;
            imshow(handles.stack(:,:,:,k)); hold on;
            plot(handles.diam_data_pts{handles.slide}{1}(:,1),handles.diam_data_pts{handles.slide}{1}(:,2),...
                'ko','MarkerSize',5,'MarkerFaceColor',[0 1 0]);
            plot(handles.diam_data_pts{handles.slide}{2}(:,1),handles.diam_data_pts{handles.slide}{2}(:,2),...
                'ko','MarkerSize',5,'MarkerFaceColor',[1 0 0]);
            file_string = strcat(foldername,'/',num2str(k),'_segmented.png');
            saveas(gcf,file_string);
            close(h)
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% AnalyzeCase3Tag
    case 3

        handles.radii = zeros(handles.stacksize,handles.radii_points);
        handles.circ_stretch = zeros(handles.stacksize,handles.radii_points);
        handles.avg_radii = zeros(handles.stacksize,1);

        [handles.min_area, handles.min_index] = min(handles.area);
        [handles.max_area, handles.max_index] = max(handles.area);
        handles.r_dias = sqrt(handles.min_area/pi);
        handles.r_syst = sqrt(handles.max_area/pi);
        handles.r_avg_area = sqrt(handles.area/pi);

        % extract diameter data
        for s = 1:handles.stacksize
            for k = 1:handles.radii_points
                % handles. radii contains radii information
                % row, denoted as s here represents time (image #)
                % column, denoted as k here represents theta (radial position)
                handles.radii(s,k) = handles.calib*sqrt( (handles.xx{s}(k) - handles.center{s}(1))^2 ...
                    + (handles.yy{s}(k) - handles.center{s}(2))^2 );
                handles.lambda_theta(s,k) = handles.radii(s,k)/handles.r_dias;
            end
            handles.avg_radii(s) = mean(handles.radii(s,:));
        end

        handles.max_radii_globe_area = max(handles.r_avg_area);
        handles.min_radii_globe_area = min(handles.r_avg_area);
        handles.avg_radii_globe_area = mean(handles.r_avg_area);

        handles.circ_strain_area = 0.5*(handles.lambda_theta.^2 - 1);
        handles.circ_strain_max_area = max(handles.circ_strain_area,[],2)';
        handles.circ_strain_avg_area = mean(handles.circ_strain_area,2)';

        handles.max_radii_globe = max(handles.avg_radii);
        handles.min_radii_globe = min(handles.avg_radii);
        handles.avg_radii_globe = mean(handles.avg_radii);

        guidata(hObject, handles);

        handles.circ_stretch_globe = handles.avg_radii./handles.min_radii_globe;
        handles.circ_strain_globe = 0.5*(handles.circ_stretch_globe.^2 - 1);

        handles.circ_strain_max = max(handles.circ_strain_globe);
        handles.circ_strain_avg = mean(handles.circ_strain_globe);

        guidata(hObject, handles);

        handles.max_diam_string = strcat('Max radius is ',...
            num2str(handles.max_radii_globe));
        handles.min_diam_string =  strcat('Min. radius is ',...
            num2str(handles.min_radii_globe));
        handles.avg_diam_string =  strcat('Avg. radius is ',...
            num2str(handles.avg_radii_globe));
        handles.max_strain_string =  strcat('Max circumferential strain is ',...
            num2str(handles.circ_strain_max));
        handles.avg_strain_string = strcat('Avg circumfrential strain is ',...
            num2str(handles.circ_strain_avg));

        handles.max_diam_string_area = strcat('Max radius is ',...
            num2str(handles.max_radii_globe_area));
        handles.min_diam_string_area =  strcat('Min. radius is ',...
            num2str(handles.min_radii_globe_area));
        handles.avg_diam_string_area =  strcat('Avg. radius is ',...
            num2str(handles.avg_radii_globe_area));
        handles.max_strain_string_area =  strcat('Max circumferential strain is ',...
            num2str(handles.circ_strain_max_area));
        handles.avg_strain_string_area = strcat('Avg circumfrential strain is ',...
            num2str(handles.circ_strain_avg_area));


        % make folder
        foldername = strcat(handles.filename(1,1:end-4),'_analyzed');
        mkdir(foldername);


        % save variables
        save(strcat(foldername,'/',handles.filename(1,1:end-4),'_variables.mat'),'handles');


        % text file containing important values
        textfile_name = strcat(foldername,'/',handles.filename(1,1:end-4),'_strain_results.txt');
        fid = fopen(textfile_name,'wt');
        fprintf(fid, '%s\n%s\n%s\n%s\n%s\n%s' ,handles.calib_string,handles.max_diam_string,...
            handles.min_diam_string,handles.avg_diam_string,handles.max_strain_string,handles.avg_strain_string);
        fclose(fid);

        % text file containing important values (calculated from area)
        textfile_name = strcat(foldername,'/',handles.filename(1,1:end-4),'_strain_results_area_based.txt');
        fid = fopen(textfile_name,'wt');
        fprintf(fid, '%s\n%s\n%s\n%s\n%s\n%s' ,handles.calib_string,handles.max_diam_string_area,...
            handles.min_diam_string_area,handles.avg_diam_string_area,handles.max_strain_string_area,handles.avg_strain_string_area);
        fclose(fid);


        % csv file containing diameter values
        csvwrite(strcat(foldername,'/',handles.filename(1,1:end-4),'_radii.csv'),handles.radii);
        csvwrite(strcat(foldername,'/',handles.filename(1,1:end-4),'_radii_area_based.csv'),handles.r_avg_area);
        csvwrite(strcat(foldername,'/',handles.filename(1,1:end-4),'_area.csv'),handles.area);
        csvwrite(strcat(foldername,'/',handles.filename(1,1:end-4),'_circ_stretch_area_based.csv'),...
        handles.lambda_theta);



        % making the video

        writerObj = VideoWriter(strcat(foldername,'/',handles.filename(1,1:end-4),...
            '_radiis.avi'));
        open(writerObj);

        for m = 1:size(handles.stack,4)

            %plot US image
            h = figure;
            imshow(handles.stack(:,:,:,m))
            hold on;

            for k = 1:handles.radii_points
              temp_x = [handles.center{m}(1) handles.xx{m}(k)];
              temp_y = [handles.center{m}(2) handles.yy{m}(k)];
              plot(temp_x,temp_y,'--w'); hold on;
            end
            hold off;

            % plot(handles.xx{m},handles.yy{m},'o');
            frame = getframe;
            writeVideo(writerObj,frame);
            pause(0.5)
            close(h)
        end
        close(writerObj);

        % Plots
        % PlotTag
        figure;
        stack_size_array = (1:handles.stacksize);
        plot(stack_size_array,handles.r_avg_area,'k');
        xlim([1 handles.stacksize]);
        xlabel('time'); ylabel('radius');
        title('average radius over time using area');

        figure;
        plot(stack_size_array,handles.avg_radii);
        xlim([1 handles.stacksize]);
        xlabel('time'); ylabel('radius');
        title('average radius over time');

        for k = 1:handles.stacksize
            handles.lambda_theta_avg_area(k) = mean(handles.lambda_theta(k,:));
        end

        figure;
        plot(stack_size_array,handles.lambda_theta_avg_area,'k');
        xlim([1 handles.stacksize]);
        xlabel('time'); ylabel('circumfrential stretch');
        title('average circ. stretch over time using area');

        figure;
        plot(stack_size_array,handles.circ_stretch_globe);
        xlim([1 handles.stacksize]);
        xlabel('time'); ylabel('circumfrential stretch');
        title('average circ. stretch over time using min avg radii');

        figure;
        for k = 1:handles.radii_points
            plot(stack_size_array,handles.lambda_theta(:,k),'o'); hold on;
        end
        title('individual lambda over time');
        ylabel('circ. stretch'); xlabel('time');

        figure;
        for k = 1:handles.radii_points
          plot(stack_size_array,handles.radii(:,k),'x'); hold on;
        end
        title('individual radii over time');
        ylabel('radii'); xlabel('time');

        figure;
        plot(stack_size_array,handles.area);
        title('area over time');
        xlabel('time'); ylabel('area');
end
%--------------%
guidata(hObject,handles);



function InstructionBox_Callback(hObject, eventdata, handles)
% hObject    handle to InstructionBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of InstructionBox as text
%        str2double(get(hObject,'String')) returns contents of InstructionBox as a double


% --- Executes during object creation, after setting all properties.
function InstructionBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to InstructionBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end
