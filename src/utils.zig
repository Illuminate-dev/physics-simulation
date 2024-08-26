const std = @import("std");
const rl = @import("raylib");
const math = std.math;

pub const Vector2D = @Vector(2, f32);

pub const GraphSettings = struct {
    scale: u32,
    spacing: u32,
    num_lines: u32,
};

pub inline fn intToStr(int: i32, comptime max_len: u32) [max_len]u8 {
    var buf: [max_len]u8 = .{0} ** max_len;
    _ = std.fmt.bufPrint(&buf, "{}", .{int}) catch unreachable;
    return buf;
}

// converts a rectangular 2d vector to polar form (magnitude, angle in deg);
pub fn toPolar(vec: Vector2D) Vector2D {
    const magnitude = math.sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
    const angle = math.atan2(vec[1], vec[0]);

    return Vector2D{ magnitude, angle * math.deg_per_rad };
}

pub fn toRectangular(vec: Vector2D) Vector2D {
    const y = math.sin(vec[1] * math.rad_per_deg) * vec[0];
    const x = math.cos(vec[1] * math.rad_per_deg) * vec[0];

    return Vector2D{ x, y };
}

pub fn toRlVector2(vec: Vector2D, origin: rl.Vector2, settings: GraphSettings) rl.Vector2 {
    return rl.Vector2{ .x = origin.x + vec[0] * @as(f32, @floatFromInt(settings.spacing)) / @as(f32, @floatFromInt(settings.scale)), .y = origin.y - vec[1] * @as(f32, @floatFromInt(settings.spacing)) / @as(f32, @floatFromInt(settings.scale)) };
}

pub fn fromRlVector2(vec: rl.Vector2, origin: rl.Vector2, settings: GraphSettings) Vector2D {
    return Vector2D{ @as(f32, @floatFromInt(settings.scale)) * (vec.x - origin.x) / @as(f32, @floatFromInt(settings.spacing)), @as(f32, @floatFromInt(settings.scale)) * (origin.y - vec.x) / @as(f32, @floatFromInt(settings.spacing)) };
}

test "toPolar" {
    const vec1 = Vector2D{ 1, 4 };
    const vec1_polar = toPolar(vec1);
    const vec1_polar_approx = Vector2D{ math.sqrt(17.0), 75.9637565 };
    try std.testing.expectApproxEqAbs(vec1_polar[0], vec1_polar_approx[0], 0.0001);
    try std.testing.expectApproxEqAbs(vec1_polar[1], vec1_polar_approx[1], 0.0001);

    const vec2 = Vector2D{ -1, -4 };
    const vec2_polar = toPolar(vec2);
    const vec2_polar_approx = Vector2D{ math.sqrt(17.0), -104.03624347 };
    try std.testing.expectApproxEqAbs(vec2_polar[0], vec2_polar_approx[0], 0.0001);
    try std.testing.expectApproxEqAbs(vec2_polar[1], vec2_polar_approx[1], 0.0001);
}

test "toRectangular" {
    const vec1 = Vector2D{ math.sqrt(17.0), 75.9637565 };
    const vec1_rect = toRectangular(vec1);
    const vec1_rect_approx = Vector2D{ 1, 4 };
    try std.testing.expectApproxEqAbs(vec1_rect[0], vec1_rect_approx[0], 0.0001);
    try std.testing.expectApproxEqAbs(vec1_rect[1], vec1_rect_approx[1], 0.0001);

    const vec2 = Vector2D{ math.sqrt(17.0), -104.03624347 };
    const vec2_rect = toRectangular(vec2);
    const vec2_rect_approx = Vector2D{ -1, -4 };
    try std.testing.expectApproxEqAbs(vec2_rect[0], vec2_rect_approx[0], 0.0001);
    try std.testing.expectApproxEqAbs(vec2_rect[1], vec2_rect_approx[1], 0.0001);
}

test "toRlVector2" {
    const settings = GraphSettings{ .scale = 1, .spacing = 25, .num_lines = 10 };
    const origin = rl.Vector2{ .x = 200, .y = 200 };

    const vec1 = Vector2D{ 2, 3 };

    const rl_vec1_exact = rl.Vector2{ .x = 250, .y = 125 };
    const rl_vec1 = toRlVector2(vec1, origin, settings);

    try std.testing.expectEqual(rl_vec1.x, rl_vec1_exact.x);
    try std.testing.expectEqual(rl_vec1.y, rl_vec1_exact.y);
}

test "fromRlVector2" {
    const settings = GraphSettings{ .scale = 1, .spacing = 25, .num_lines = 10 };
    const origin = rl.Vector2{ .x = 200, .y = 200 };

    const vec1 = rl.Vector2{ .x = 250, .y = 125 };

    const rl_vec1_exact = Vector2D{ 2, 3 };
    const rl_vec1 = fromRlVector2(vec1, origin, settings);

    try std.testing.expectEqual(rl_vec1[0], rl_vec1_exact[0]);
    try std.testing.expectEqual(rl_vec1[1], rl_vec1_exact[1]);
}
