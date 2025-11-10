geo = struct();
geo.Reach=470; 
geo.Stack=640; 
geo.head_angle_deg=64.5; 
geo.head_tube_len=90;
geo.seat_angle_deg=77.5; 
geo.seat_angle_mode='horizontal';
geo.seat_tube_dir='backward';              % 后倾
geo.seat_tube_len=540; 
geo.seat_tube_extend=80;  % 可视座管长度 = 500 mm
geo.seat_anchor_from_top_mm = 200;         % 交点距座管顶 200 mm

geo.chainstay=445; 
geo.bb_drop=30; 
geo.fork_offset=44; 
geo.wheel_radius=370;

opts = struct('title','Anchor 200mm from Seat Top','annot_dx',240,'annot_anchor','front_axle');
out = mtb_fit_and_plot(geo, opts);


