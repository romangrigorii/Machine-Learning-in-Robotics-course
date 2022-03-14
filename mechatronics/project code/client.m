function client(port)
%   provides a menu for accessing PIC32 motor control functions
%
%   client(port)
%
%   Input Arguments:
%       port - the name of the com port.  This should be the same as what
%               you use in screen or putty in quotes ' '
%
%   Example:
%       client('/dev/ttyUSB0') (Linux/Mac)
%       client('COM3') (PC)
%
%   For convenience, you may want to change this so that the port is hardcoded.
   
% Opening COM connection
if ~isempty(instrfind)
    fclose(instrfind);
    delete(instrfind);
end

    fprintf('PIC32 MOTOR DRIVER INTERFACE\n\n');
    % display the menu options; this list will grow
    fprintf('\t a: Read current sensor (ADC counts)    b: Read current sensor (mA)\n');
    fprintf('\t c: Read encoder (counts)               d: Read encoder (deg)      \n');
    fprintf('\t e: Reset encoder                       f: Set PWM (-100 to 100)   \n');
    fprintf('\t g: Set current gains                   h: Get current gains       \n');
    fprintf('\t i: Set position gains                  j: Get position gains      \n');
    fprintf('\t k: Test current control                l: Go to angle             \n');
    fprintf('\t m: Load step trajectory                n: Load cubic trajectory   \n');
    fprintf('\t o: Execute trajectory                  p: Unpower the motor       \n');
    fprintf('\t q: Quit client                         r: Get mode                \n');
    
fprintf('Opening port %s....\n',port);

% settings for opening the serial port. baud rate 230400, hardware flow control
% wait up to 120 seconds for data before timing out
mySerial = serial(port, 'BaudRate', 230400, 'FlowControl', 'hardware','Timeout',10); 
% opens serial connection
fopen(mySerial);
% closes serial port when function exits
clean = onCleanup(@()fclose(mySerial));                                 

has_quit = false;
% menu loop
PKp = 0;
PKd = 0;
PKi = 0;
IKp = 0;
IKd = 0;
IKi = 0;
ADC = 0;
I = 0;
EC = 0; %encoder counts
PWM = 0;
DEG = 0; %degrees of the motor
mode = 'IDLE';
Icount = 0;
GoToAngle = 0;
FeedBackOn = 0;
while ~has_quit

    % read the user's choice
    selection = input('\nENTER COMMAND: ', 's');
    % send the command to the PIC32
    fprintf(mySerial,'%c\n',selection);
    % take the appropriate action
    switch selection
        case 'a' % Read Current sensor - ADC counts
            ADC = fscanf(mySerial,'%d');
            fprintf('The motor current is %d counts\n',ADC);
        case 'b' % Read current sensor - (mA)
            I = fscanf(mySerial,'%d');
            fprintf('The motor current is %d mA\n',I);
        case 'c' % Read the encoder counts
            data_read = fscanf(mySerial,'%d');
            EC = data_read(1);
            fprintf('The motor angle is %d counts\n', EC);
        case 'd'
            data_read = fscanf(mySerial,'%d');
            DEG = (data_read(1) - 32768)*360/1760;
            DEG = rem(DEG,360);
            if DEG<0
                DEG = -DEG;
            end
            fprintf('The motor angle is %3f degrees\n', DEG);
        case 'e' % Reset encoder
            EC = 32768;
        case 'f' % Set PWM (-100 to 100)
            PWM = input('What PWM value would you like? (-100 to 100)  ');
            if PWM>0
               fprintf('The PWM value has been set to %d in the CCW direction\n',PWM);
            elseif PWM<0
               fprintf('The PWM value has been set to %d in the CW direction\n',-PWM);
            else fprintf('The motor is set to be still\n');
            end    
            fprintf(mySerial,'%d\n',PWM); 
        case 'g' % Set current gains
            fprintf('Last Kp was %d and Ki was %d \n' ,IKp, IKi);
            IKp = input('Enter your desired Kp current gain \n');
            IKi = input('Enter your desired Ki current gain \n');
            fprintf('Current Gains: Kp = %f Kd = %f Ki = %f\n',IKp,IKd,IKi);
            fprintf(mySerial,'%f %f\n',[IKp,IKi]);
        case 'h' % Get current gain
            fprintf('Current Gains: Kp = %f Kd = %f Ki = %f\n',IKp,IKd,IKi);
        case 'i' % Set position gains
            PKp = input('Enter your desired Kp position gain \n');
            PKd = input('Enter your desired Kd position gain \n');
            PKi = input('Enter your desired Ki position gain \n');
            fprintf('Position Gains: Kp = %f Kd = %f Ki = %f\n',PKp,PKd,PKi);
            fprintf(mySerial,'%f %f %f\n',[PKp,PKd,PKi]);
        case 'j' % Get poition gains
            fprintf('Position Gains: Kp = %d Kd = %d Ki = %d\n',PKp,PKd,PKi);
        case 'k' % Test current control
            mode = 'ITEST';
            fprintf('The mode has been set to ITEST\n');
            read_plot_matrix(mySerial);
        case 'l' % Go to angle (deg)
            GoToAngle = input('Provide angle (deg) you wish to go to \n');
            fprintf(mySerial,'%d\n',GoToAngle);
        case 'm' % Load step trajectory
            traj = input('Enter Step Trajectory: ');
            traj_points = genRef(traj,'step');
            N = length(traj_points);
            fprintf(mySerial,'%d\n',N);
            for i = 1:N
              fprintf(mySerial,'%d\n',(round(traj_points(i)* 1760/360 + 32768)));  
            end
        case 'n' % Load cubic trajectory
            traj = input('Enter Step Trajectory: ');
            traj_points = genRef(traj,'cubic');
            N = length(traj_points);
            fprintf(mySerial,'%d\n',N);
             for i = 1:N
              fprintf(mySerial,'%d\n',(round(traj_points(i)* 1760/360 + 32768)));  
            end
        case 'o' % Execute trajectory
            trajActual = linspace(1,1,N);
            timeSpace = linspace(1,N/200,N);
            for i = 1:N
              trajActual(i) = (fscanf(mySerial,'%d')-32768)*360/1760;  
            end
            clf('reset');
            hold on;
            plot(timeSpace,traj_points);
            plot(timeSpace,trajActual);
        case 'p' % Unpower the motor
            fprintf('Motor has been unpowered\n');
        case 'q'
            has_quit = true; % exit client
        case 'r' % Get mode
            mode = fscanf(mySerial,'%s');
            fprintf('The PIC is set to mode: %s\n',mode);
        case 'x' % Checking mode
            n1 = input('Enter first number \n');
            n2 = input('Enter second number \n');
            fprintf('The sum of two numbers is %d\n',n1+n2);
        case 'y' %Feed Forward based control
            Kt = input('Enter 0 to turn off FF control, and any other value than zero to set Kt to that value and enable FF\n');
            if Kt==0
               fprintf('FF turned off\n');
               fprintf(mySerial,'%d %d\n',[0,0]);
            else
               fprintf('FeedForward is turned on\n');
               fprintf(mySerial,'%d %d\n',[Kt,1]);
            end
          
        otherwise
            fprintf('Invalid Selection %c\n', selection);
    end
end

end
