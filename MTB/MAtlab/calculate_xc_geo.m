function geo = calculate_xc_geo(rider_height_mm, rider_wingspan_mm, rider_inseam_mm, rider_shoulder_mm)
% calculate_xc_geo - Calculates XC Bicycle Geometry based on rider anthropometrics
% 
% Input Parameters (Units: mm):
%   rider_height_mm   : Rider's height
%   rider_wingspan_mm : Rider's wingspan
%   rider_inseam_mm   : Rider's inseam / standover height
%   rider_shoulder_mm : Rider's shoulder width (currently for documentation only)
% 
% Output Parameter:
%   geo               : Geometry structure ready for mtb_fit_and_plot
%
% Note: The calculation logic is based on empirical XC race geometry and the 
%       assumption of an 'optimal' body position (steep angles, low front end).

% =========================================================================
% XC Geometry Parameter Estimation Logic
% =========================================================================

% --- Reach and Stack Estimation (Driven by Height/Wingspan/Torso) ---
torso_length = rider_height_mm - rider_inseam_mm;

% 1. Base Reach (Linear model: 1700mm Height -> 420mm Reach)
base_reach = 420 + (rider_height_mm - 1700) * 2.5;

% 2. Wingspan Correction (Wingspan-Height Difference)
wingspan_diff = rider_wingspan_mm - rider_height_mm;
reach_modifier_wingspan = wingspan_diff * 0.4;

% 3. Torso Correction (Assuming 900mm average torso length)
torso_modifier = (torso_length - 900) * 0.2;

Reach_calc = base_reach + reach_modifier_wingspan + torso_modifier;
Reach_final = round(Reach_calc / 5) * 5;
Reach_final = max(390, min(500, Reach_final)); % Limit to reasonable XC size range [390, 500]

% Stack Estimation
base_stack = Reach_final + 100;
stack_modifier = (rider_height_mm - 1700) * 1.2;
Stack_final = round((base_stack + stack_modifier) / 5) * 5;
Stack_final = max(580, min(650, Stack_final)); % Limit to reasonable range [580, 650]


% --- Seat Tube Length Estimation (Driven by Inseam) ---
% Simple linear estimation (approx 58% of inseam to allow for post and BB space)
SeatTubeLen_final = round(rider_inseam_mm * 0.58);
SeatTubeLen_final = max(400, min(520, SeatTubeLen_final)); % Limit range


% =========================================================================
% Construct geo Structure (Using calculated values and fixed XC race parameters)
% =========================================================================
geo = struct();
geo.Reach=Reach_final;
geo.Stack=Stack_final;
geo.head_angle_deg=68.0;    % Fixed XC angle
geo.head_tube_len=90;       % Estimated value

geo.seat_angle_deg=75.0;    % Fixed XC angle (Steep for efficient power transfer)
geo.seat_angle_mode='horizontal';
geo.seat_tube_dir='backward';               % Lean backward (Default)
geo.seat_tube_len=SeatTubeLen_final;
geo.seat_tube_extend=80;                    % Visible seat tube extension
geo.seat_anchor_from_top_mm = 200;          % Anchor point 200 mm from visible top

geo.chainstay=430;          % Fixed XC length
geo.bb_drop=55;             % Fixed XC depth
geo.fork_offset=51;         % Fixed XC offset
geo.wheel_radius=370;       % 29" wheel radius

end