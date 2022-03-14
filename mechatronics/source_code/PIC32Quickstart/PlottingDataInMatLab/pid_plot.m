function data = pid_plot(port,Kp,Ki,WF,center,AMP)
%   pid_plot plot the data from the pwm controller to the current figure
%
%   data = pid_plot(port,Kp,Ki)
%
%   Input Arguments:
%       port - the name of the com port.  This should be the same as what
%               you use in screen or putty in quotes ' '
%       Kp - proportional gain for controller
%       Ki - integral gain for controller
%       WF - Waveform
%            (1) Square wave at 1 Hz
%            (2) Sinusouidal wave wit preset period. To change this,
%                must access c code
%            (3) Saw shape at 1 Hz with positive slope
%            (4) Saw shape at 1 Hz with negative slope
%            (5) Send over an arbitrary reference trajectory specified
%                in MATLAB
%       center - 0-1000 value of the vertical offset of reference wave
%       AMP - 0-1000 value of amplitude of reference wave
%   Output Arguments:
%       data - The collected data.  Each column is a time slice
%
%   Example:
%       data = pid_plot('/dev/ttyUSB0',1.0,1.0) (Linux)
%       data = pid_plot('/dev/tty.usbserial-00001014A',1.0,1.0) (Mac)
%       data = pid_plot('COM3',1.0,1.0) (PC)
%

%% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end
fprintf('Opening port %s....\n',port);
mySerial = serial(port, 'BaudRate', 230400, 'FlowControl', 'hardware'); 
%mySerial.OutputBufferSize = 2000;
fopen(mySerial); % opens serial connection
clean = onCleanup(@()fclose(mySerial)); % closes serial port when function exits

%% Sending Data
% Printing to matlab Command window
fprintf('Setting Kp = %f, Ki = %f\n', Kp, Ki);
% Writing to serial port
fprintf(mySerial,'%f %f %d %d %d\n',[Kp,Ki,WF,center,AMP]);
% If the user chooses to use a wave generated in MATLAB...
if WF==5
   % The code between the two green lines creates a reference wave.
   % By default it is composed of 10 random values ranging from center-AMP
   % to center+AMP, each value spanning 100 of 1000 points
   %--------------------------------------
   REFshortArray=randperm(2*AMP,10)+ones(1,10)*center-AMP;
   REFlongArray= ones(1,0);
   for i=1:10
    REFlongArray = [REFlongArray,REFshortArray(i)*ones(1,100)];
   end
   %----------------------------------------
   % sends 1000 points of reference wave to the PIC
   for i=1:1000 
    fprintf(mySerial,'%d\n', REFlongArray(i));
   end
end
%% Reading data
fprintf('Waiting for samples ...\n');

sampnum = 1; % index for number of samples read
read_samples = 10; % When this value from PIC32 equals 1, it is done sending data
while read_samples > 1
    data_read = fscanf(mySerial,'%d %d %d %d'); % reading data from serial port
    % Extracting variables from data_read
    read_samples=data_read(1); 
    ADCval(sampnum)=data_read(2);
    ref(sampnum)=data_read(3);
    CRL(sampnum)=data_read(4);
    sampnum=sampnum+1; % incrementing loop number
end
data = [ref;ADCval]; % setting data variable

%% Plotting data
clf;
hold on;
t = 1:sampnum-1;
plot(t,ref);
plot(t,ADCval);
%plot(t,CRL);
legend('Reference', 'ADC Value')
title(['Kp: ',num2str(Kp),'  Ki: ',num2str(Ki)]);
ylabel('Brightness (ADC counts)');
xlabel('Sample Number (at 100 Hz)');
hold off;
end
