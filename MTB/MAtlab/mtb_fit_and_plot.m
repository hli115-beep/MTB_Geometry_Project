function out = mtb_fit_and_plot(geo, opts)
% MTB full frame geometry plotter (no rider) + geometry solver (v4.2)
% -----------------------------------------------------------------------------
% 新规则：top tube（不要求水平）与 seatstay 都在 seat tube 上、距"座管可视顶点"
% seat_anchor_from_top_mm 的位置与 seat tube 相交；座管变长/变短，交点随之联动。
%
% ===== geo (mm/deg) =====
%  Reach, Stack
%  head_angle_deg, head_tube_len
%  seat_angle_deg
%  seat_angle_mode     : 'horizontal'(默认) | 'vertical' | 'auto'
%  seat_tube_dir       : 'backward'(默认后倾) | 'forward'(前倾)
%  seat_tube_len       : 可视座管的基础长度
%  seat_tube_extend    : 仅用于再延长可视座管长度(>=0)
%  seat_anchor_from_top_mm : 交点相对座管"可视顶点"的回退距离，默认 200(mm)
%  chainstay, bb_drop
%  fork_offset, wheel_radius
%
% ===== opts =====
%  title, export_png, lw, show_ground
%  annot_dx(160), annot_anchor('front_axle')
%
% 输出 out.points / out.geometry
% -----------------------------------------------------------------------------

% -------- defaults --------
if nargin < 2, opts = struct(); end
if ~isfield(opts,'title'),       opts.title = 'MTB Frame Geometry (v4.2)'; end
if ~isfield(opts,'export_png'),  opts.export_png = ''; end
if ~isfield(opts,'lw'),          opts.lw = 2.2; end
if ~isfield(opts,'show_ground'), opts.show_ground = true; end
if ~isfield(opts,'annot_dx'),     opts.annot_dx = 160; end
if ~isfield(opts,'annot_anchor'), opts.annot_anchor = 'front_axle'; end

if ~isfield(geo,'seat_angle_mode'),      geo.seat_angle_mode = 'horizontal'; end
if ~isfield(geo,'seat_tube_dir'),        geo.seat_tube_dir   = 'backward'; end
if ~isfield(geo,'seat_tube_len'),        geo.seat_tube_len   = 400; end
if ~isfield(geo,'seat_tube_extend'),     geo.seat_tube_extend= 0; end
if ~isfield(geo,'seat_anchor_from_top_mm'), geo.seat_anchor_from_top_mm = 200; end
% 可忽略的旧参数（保持兼容但不使用）：top_tube_drop, seatstay_joint

% -------- normalize seat angle to horizontal acute --------
seat_angle_in = geo.seat_angle_deg;
mode = lower(string(geo.seat_angle_mode));
switch mode
    case "horizontal"
        seat_angle_h = seat_angle_in;
    case "vertical"
        seat_angle_h = 90 - seat_angle_in;
    case "auto"
        if seat_angle_in > 90 && seat_angle_in < 180
            seat_angle_h = 180 - seat_angle_in;
        else
            seat_angle_h = seat_angle_in;
        end
    otherwise
        seat_angle_h = seat_angle_in;
end
seat_angle_h = max(30, min(89.5, seat_angle_h));
geo.seat_angle_eff_deg = seat_angle_h;

% -------- shorthand --------
R   = geo.Reach;
S   = geo.Stack;
hta = deg2rad(geo.head_angle_deg);
sta = deg2rad(geo.seat_angle_eff_deg);

% -------- base points --------
BB   = [0, -geo.bb_drop];
RA   = [-geo.chainstay, 0];
HTop = [R, -geo.bb_drop + S];

% 头管轴/法向、头管底
u_axis_down = [cos(hta), -sin(hta)];
n_forward   = [sin(hta),  cos(hta)];
HB          = HTop + geo.head_tube_len * u_axis_down;

% 前轴（含 offset，强制 y=0）
t_along = (HTop(2) + geo.fork_offset*cos(hta)) / sin(hta);
FA      = HTop + t_along*u_axis_down + geo.fork_offset*n_forward;
FA(2)   = 0;
A2C_implied = t_along;

% 坐管方向：后倾/前倾
switch lower(string(geo.seat_tube_dir))
    case "forward",  v_seat = [ cos(sta),  sin(sta)];
    otherwise,       v_seat = [-cos(sta),  sin(sta)]; % backward 默认
end

% -------- seat tube 可视端点（完全由你输入控制） --------
seat_tube_len_draw = max(0, geo.seat_tube_len) + max(0, geo.seat_tube_extend);
ST_vis_top         = BB + seat_tube_len_draw * v_seat;

% -------- 统一锚点：距座管顶点 seat_anchor_from_top_mm 的位置 --------
% 将"回退距离(mm)"转成沿坐管方向的 参数长度（因为 v_seat 是单位向量，参数=距离）
t_anchor = max(0, seat_tube_len_draw - max(0, geo.seat_anchor_from_top_mm));
SeatJoint = BB + t_anchor * v_seat;   % top tube & seatstay 都连到这里

% -------- 其余几何（不受新锚点影响） --------
% Trail：轴线与地面(y=-wheelR)交点到接地点的水平距离
t_ground = (HTop(2) + geo.wheel_radius) / sin(hta);
Gx       = HTop(1) + t_ground * cos(hta);
trail    = FA(1) - Gx;

wheelbase   = FA(1) - RA(1);
frontcenter = FA(1) - BB(1);
BB_height   = geo.wheel_radius + BB(2);
% ETT：按行业常用"水平有效上管长"定义，取 HeadTop 的 x 与 SeatJoint 在同一水平的 x 差
ETT         = abs(HTop(1) - SeatJoint(1));

% -------- 绘图 --------
figure('Color','w','Name','MTB Frame Geometry v4.2'); hold on; axis equal
title(opts.title); xlabel('x (mm)'); ylabel('y (mm)'); grid on

% 地面与轴线
if opts.show_ground
    xspan = [RA(1)-220, FA(1)+220];
    plot(xspan, [-geo.wheel_radius, -geo.wheel_radius], ':', 'Color',[0.6 0.6 0.6], 'LineWidth',1.1);
end
plot([RA(1) FA(1)], [0 0], '-', 'Color',[0.75 0.75 0.75], 'LineWidth',1);

% 轮子
draw_circle(RA, geo.wheel_radius, [0.2 0.2 0.2], 1.2);
draw_circle(FA, geo.wheel_radius, [0.2 0.2 0.2], 1.2);

% 颜色
c_head=[0.85 0.10 0.10]; c_top=[0.00 0.45 0.74]; c_down=[0.00 0.60 0.50];
c_seat=[0.95 0.55 0.10]; c_cs=[0.55 0.00 0.90];  c_ss=[0.40 0.25 0.10];
c_fork=[0.10 0.10 0.10];

% 管件
plot([HB(1) HTop(1)],[HB(2) HTop(2)],'-','Color',c_head,'LineWidth',opts.lw,'DisplayName','Head tube');
plot([HTop(1) FA(1)],[HTop(2) FA(2)],'-','Color',c_fork,'LineWidth',opts.lw,'DisplayName','Fork');
% top tube（不再要求水平）：SeatJoint -> HeadTop
plot([SeatJoint(1) HTop(1)],[SeatJoint(2) HTop(2)],'-','Color',c_top,'LineWidth',opts.lw,'DisplayName','Top tube');
% down tube
plot([HB(1) BB(1)],[HB(2) BB(2)],'-','Color',c_down,'LineWidth',opts.lw,'DisplayName','Down tube');
% seat tube（可视长度）
plot([BB(1) ST_vis_top(1)],[BB(2) ST_vis_top(2)],'-','Color',c_seat,'LineWidth',opts.lw,'DisplayName','Seat tube');
% chainstay
plot([BB(1) RA(1)],[BB(2) RA(2)],'-','Color',c_cs,'LineWidth',opts.lw,'DisplayName','Chainstay');
% seatstay（Rear Axle -> SeatJoint）
plot([SeatJoint(1) RA(1)],[SeatJoint(2) RA(2)],'-','Color',c_ss,'LineWidth',opts.lw,'DisplayName','Seatstay');

% 关键点
plot(SeatJoint(1), SeatJoint(2),'o','MarkerSize',5,'MarkerFaceColor',c_top,'MarkerEdgeColor','none'); % 统一交点
plot(ST_vis_top(1), ST_vis_top(2),'s','MarkerSize',5,'MarkerFaceColor',c_seat,'MarkerEdgeColor','none'); % 座管顶

% Stack / Reach markers
plot([0 R],[BB(2) BB(2)],'k--','LineWidth',1);
plot([R R],[BB(2) BB(2)+S],'k--','LineWidth',1);

% 文本框
switch lower(opts.annot_anchor)
    case 'head_top'
        ann_x0 = HTop(1); ann_y0 = HTop(2);
    otherwise
        ann_x0 = FA(1);   ann_y0 = geo.wheel_radius*0.65;
end
ann_y = max(HTop(2), ann_y0);
ann_x = ann_x0 + opts.annot_dx;

txt = {
    sprintf('Reach: %.1f mm', geo.Reach)
    sprintf('Stack: %.1f mm', geo.Stack)
    sprintf('Head angle: %.1f°', geo.head_angle_deg)
    sprintf('Head tube: %.1f mm', geo.head_tube_len)
    sprintf('Fork A2C (implied): %.1f mm | Offset: %.1f mm', A2C_implied, geo.fork_offset)
    sprintf('Trail: %.1f mm', trail)
    sprintf('Seat angle (eff): %.1f°  (%s input: %.1f°)', ...
            geo.seat_angle_eff_deg, lower(char(mode)), geo.seat_angle_deg)
    sprintf('Seat tube (vis): %.1f mm (%s)', seat_tube_len_draw, lower(char(geo.seat_tube_dir)))
    sprintf('Anchor from seat top: %.1f mm', max(0, geo.seat_anchor_from_top_mm))
    sprintf('Chainstay: %.1f mm', geo.chainstay)
    sprintf('Wheelbase: %.1f mm', wheelbase)
    sprintf('Front Center: %.1f mm', frontcenter)
    sprintf('BB Drop: %.1f mm  |  BB Height: %.1f mm', geo.bb_drop, BB_height)
    sprintf('ETT (horiz @SeatJoint): %.1f mm', ETT)
    };
text(ann_x, ann_y, strjoin(txt, '\n'), ...
     'FontSize',9, 'VerticalAlignment','top', ...
     'BackgroundColor',[1 1 1 0.82], 'EdgeColor',[0.8 0.8 0.8]);

% 关键点标签
scatter([BB(1) RA(1) FA(1) HTop(1) HB(1)], [BB(2) RA(2) FA(2) HTop(2) HB(2)], 24, 'k', 'filled');
text(BB(1)-12, BB(2)-14, 'BB');
text(RA(1)-22, RA(2)-14, 'Rear Axle');
text(FA(1)-22, FA(2)-14, 'Front Axle');
text(HTop(1)+6, HTop(2)+6, 'Head Top');

legend('Location','northoutside','NumColumns',4,'Box','off');

% 视窗
padx = 220 + max(0, opts.annot_dx - 40);
pady = 200;
xlim([RA(1)-padx, FA(1)+padx]);
ylim([-geo.wheel_radius - pady, max([HTop(2), geo.wheel_radius]) + pady]);

% 导出
if ~isempty(opts.export_png)
    exportgraphics(gcf, opts.export_png, 'Resolution', 220);
end

% 输出
out.points = struct('BB',BB,'RA',RA,'FA',FA,'HTop',HTop,'HB',HB, ...
                    'SeatJoint',SeatJoint,'ST_vis_top',ST_vis_top);
out.geometry = struct( ...
    'Reach',geo.Reach, 'Stack',geo.Stack, ...
    'HeadAngle_deg',geo.head_angle_deg, 'HeadTube_mm',geo.head_tube_len, ...
    'ForkA2C_implied_mm',A2C_implied, 'ForkOffset_mm',geo.fork_offset, ...
    'Trail_mm',trail, ...
    'SeatAngleEff_deg',geo.seat_angle_eff_deg, 'SeatAngleInput_deg',geo.seat_angle_deg, ...
    'SeatAngleMode',char(mode), 'SeatTubeDir',char(geo.seat_tube_dir), ...
    'SeatTubeVis_mm',seat_tube_len_draw, 'SeatAnchorFromTop_mm', max(0, geo.seat_anchor_from_top_mm), ...
    'Chainstay_mm',geo.chainstay, 'Wheelbase_mm',wheelbase, 'FrontCenter_mm',frontcenter, ...
    'BB_Drop_mm',geo.bb_drop, 'BB_Height_mm',BB_height, ...
    'ETT_mm',ETT, 'WheelRadius_mm',geo.wheel_radius ...
    );

end

% -------- helper --------
function draw_circle(C, r, col, lw)
th = linspace(0, 2*pi, 180);
plot(C(1)+r*cos(th), C(2)+r*sin(th), '-', 'Color', col, 'LineWidth', lw);
end
