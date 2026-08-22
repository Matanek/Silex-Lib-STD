const std = @import("std");

const flate = std.compress.flate;

export fn silex_compression_decompress(
    input_pointer: [*]const u8,
    input_count: u64,
    output_pointer: [*]u8,
    output_capacity: u64,
    format: u32,
) callconv(.c) i64 {
    const input_length = std.math.cast(usize, input_count) orelse return -3;
    const output_length = std.math.cast(usize, output_capacity) orelse return -3;
    const container: flate.Container = switch (format) {
        0 => .raw,
        1 => .gzip,
        2 => .zlib,
        else => return -3,
    };

    var input: std.Io.Reader = .fixed(input_pointer[0..input_length]);
    var output: std.Io.Writer = .fixed(output_pointer[0..output_length]);
    var decompressor: flate.Decompress = .init(&input, container, &.{});
    const written = decompressor.reader.streamRemaining(&output) catch |err| switch (err) {
        error.WriteFailed => return -2,
        else => return -1,
    };
    return std.math.cast(i64, written) orelse -3;
}
