// raylib-zig (c) Nikolas Wipper 2023

const rl = @import("raylib");
const std = @import("std");
const utils = @import("utils.zig");
const intToStr = utils.intToStr;
const Vector2D = utils.Vector2D;
const GraphSettings = utils.GraphSettings;

const Vector2DColorTuple = std.meta.Tuple(&.{ Vector2D, rl.Color });

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    const graphSettings = GraphSettings{ .scale = 1, .spacing = 50, .num_lines = 10 };

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var vectors_2d = std.ArrayList(Vector2DColorTuple).init(allocator);
    defer vectors_2d.deinit();

    try vectors_2d.append(.{ Vector2D{ 1, 4 }, rl.Color.red });
    try vectors_2d.append(.{ Vector2D{ -1, -3 }, rl.Color.green });

    try vectors_2d.append(.{ vectors_2d.items[0][0] + vectors_2d.items[1][0], rl.Color.dark_blue });

    rl.initWindow(screenWidth, screenHeight, "Physics simulation");
    defer rl.closeWindow(); // Close window and OpenGL context

    // const camera = rl.Camera2D{
    //     .offset = .{ .x = 0, .y = 0 },
    //     .target = .{ .x = 0, .y = 0 },
    //     .rotation = 0,
    //     .zoom = 1.0,
    // };

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        rl.drawFPS(10, 5);
        drawCoordPlane(graphSettings);
        drawVectors(vectors_2d, graphSettings);

        //----------------------------------------------------------------------------------
    }
}

fn drawCoordPlane(settings: GraphSettings) void {
    const spacing = settings.spacing;
    const num_lines = settings.num_lines;
    const scale = settings.scale;

    const height = rl.getScreenHeight();
    const width = rl.getScreenWidth();

    const origin = .{ .x = @divFloor(width, 2), .y = @divFloor(height, 2) };

    const insignficant_color = rl.Color.dark_gray;
    const significant_color = rl.Color.white;

    const fontsize = 12;

    // draw non-axis lines

    var i: u32 = 1;
    while (i <= num_lines) : (i += 1) {
        const offset: i32 = @intCast(spacing * i);

        // vertical
        const display_px = intToStr(@intCast(i * scale), 20);
        rl.drawLine(origin.x + offset, height, origin.x + offset, 0, insignficant_color);
        rl.drawText(@ptrCast(&display_px), origin.x + offset, origin.y + @divFloor(fontsize, 2), fontsize, significant_color);

        const display_nx = intToStr(-@as(i32, @intCast(i * scale)), 20);
        rl.drawLine(origin.x - offset, height, origin.x - offset, 0, insignficant_color);
        rl.drawText(@ptrCast(&display_nx), origin.x - offset, origin.y + @divFloor(fontsize, 2), fontsize, significant_color);

        // horizontal
        const display_py = intToStr(@intCast(i * scale), 20);
        rl.drawLine(0, origin.y - offset, width, origin.y - offset, insignficant_color);
        rl.drawText(@ptrCast(&display_py), origin.x - fontsize * 2, origin.y - offset, fontsize, significant_color);

        const display_ny = intToStr(-@as(i32, @intCast(i * scale)), 20);
        rl.drawLine(0, origin.y + offset, width, origin.y + offset, insignficant_color);
        rl.drawText(@ptrCast(&display_ny), origin.x - fontsize * 2, origin.y + offset, fontsize, significant_color);
    }

    // draw y-axis
    rl.drawLine(origin.x, height, origin.x, 0, significant_color);
    //
    // draw x-axis
    rl.drawLine(width, origin.y, 0, origin.y, significant_color);
}

fn drawVectors(vectors: std.ArrayList(Vector2DColorTuple), settings: GraphSettings) void {
    const height = rl.getScreenHeight();
    const width = rl.getScreenWidth();

    const origin_vec2 = rl.Vector2{ .x = @as(f32, @floatFromInt(width)) / 2.0, .y = @as(f32, @floatFromInt(height)) / 2.0 };

    const triangle_angle_offset = 1.0;
    const offset_factor = std.math.sqrt(@as(f32, @floatFromInt(height * height)) + @as(f32, @floatFromInt(width * width))) / 180.0;

    for (vectors.items) |v_c| {
        const v = v_c[0];
        const color = v_c[1];

        const vec = utils.toRlVector2(v, origin_vec2, settings);
        // rl.drawLine(origin.x, origin.y, origin.x + @as(i32, @intFromFloat(v[0] * @as(f32, @floatFromInt(settings.spacing)))), origin.y - @as(i32, @intFromFloat(v[1] * @as(f32, @floatFromInt(settings.spacing)))), color);
        rl.drawLineV(origin_vec2, vec, color);

        // draw triangle pointer thing

        const polar = utils.toPolar(v);

        const magnitude_offset = offset_factor / @as(f32, @floatFromInt(settings.spacing));

        const side1 = utils.toRlVector2(utils.toRectangular(Vector2D{ polar[0] - magnitude_offset, polar[1] - triangle_angle_offset }), origin_vec2, settings);
        const side2 = utils.toRlVector2(utils.toRectangular(Vector2D{ polar[0] - magnitude_offset, polar[1] + triangle_angle_offset }), origin_vec2, settings);

        rl.drawTriangle(side1, vec, side2, color);
    }
}
