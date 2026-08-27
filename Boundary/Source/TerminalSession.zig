const std = @import("std");
const builtin = @import("builtin");

const is_windows = builtin.os.tag == .windows;
const allocator = std.heap.page_allocator;

const TerminalHandle = if (is_windows) WindowsHandle else PosixHandle;

const PosixHandle = struct {
    process: i32 = -1,
    master: i32 = -1,
    running: bool = false,
    status: i32 = 0,
    signaled: bool = false,
    error_code: i32 = 0,
    buffer: [4096]u8 = undefined,
};

const WindowsHandle = struct {
    process: usize = 0,
    input: usize = 0,
    output: usize = 0,
    pseudo_console: usize = 0,
    running: bool = false,
    status: u32 = 0,
    error_code: i32 = 0,
    buffer: [4096]u8 = undefined,
};

export fn sx_terminal_spawn(
    executable_address: usize,
    arguments_address: usize,
    directory_address: usize,
    environment_address: usize,
    columns: i32,
    rows: i32,
) callconv(.c) usize {
    const handle = allocator.create(TerminalHandle) catch return 0;
    handle.* = .{};
    if (columns <= 0 or rows <= 0) {
        handle.error_code = 22;
        return @intFromPtr(handle);
    }
    if (is_windows) {
        spawnWindows(handle, executable_address, arguments_address, directory_address, environment_address, columns, rows);
    } else {
        spawnPosix(handle, executable_address, arguments_address, directory_address, environment_address, columns, rows);
    }
    return @intFromPtr(handle);
}

export fn sx_terminal_error(handle_address: usize) callconv(.c) i32 {
    const handle = terminalHandle(handle_address) orelse return 22;
    return handle.error_code;
}

export fn sx_terminal_write(handle_address: usize, bytes_address: usize, byte_count: i32) callconv(.c) i32 {
    const handle = terminalHandle(handle_address) orelse return -1;
    if (byte_count < 0 or (byte_count > 0 and bytes_address == 0)) {
        handle.error_code = 22;
        return -1;
    }
    if (!handle.running) return -2;
    if (is_windows) return writeWindows(handle, bytes_address, byte_count);
    return writePosix(handle, bytes_address, byte_count);
}

// Positive values are byte counts, zero is a timeout, -1 is an error,
// -1000 is a normal exit and -2000 is a signaled exit.
fn terminalPoll(
    handle_address: usize,
    bytes_address: usize,
    byte_capacity: i32,
    timeout_milliseconds: i32,
) callconv(.c) i32 {
    const handle = terminalHandle(handle_address) orelse return -1;
    if (bytes_address == 0 or byte_capacity <= 0 or timeout_milliseconds < 0) {
        handle.error_code = 22;
        return -1;
    }
    if (is_windows) return pollWindows(handle, bytes_address, byte_capacity, timeout_milliseconds);
    return pollPosix(handle, bytes_address, byte_capacity, timeout_milliseconds);
}

export fn sx_terminal_poll_buffered(handle_address: usize, timeout_milliseconds: i32) callconv(.c) i32 {
    const handle = terminalHandle(handle_address) orelse return -1;
    const result = terminalPoll(handle_address, @intFromPtr(&handle.buffer), handle.buffer.len, timeout_milliseconds);
    if (result == -1) return 7000;
    if (result == -2000) return 6000;
    if (result == -1000) return 5000;
    return result;
}

export fn sx_terminal_byte(handle_address: usize, index: i32) callconv(.c) i32 {
    const handle = terminalHandle(handle_address) orelse return 0;
    if (index < 0 or index >= handle.buffer.len) return 0;
    return handle.buffer[@intCast(index)];
}

export fn sx_terminal_resize(handle_address: usize, columns: i32, rows: i32) callconv(.c) i32 {
    const handle = terminalHandle(handle_address) orelse return 0;
    if (columns <= 0 or rows <= 0) {
        handle.error_code = 22;
        return 0;
    }
    if (is_windows) return resizeWindows(handle, columns, rows);
    return resizePosix(handle, columns, rows);
}

export fn sx_terminal_terminate(handle_address: usize) callconv(.c) i32 {
    const handle = terminalHandle(handle_address) orelse return 0;
    if (!handle.running) return 1;
    if (is_windows) return terminateWindows(handle);
    return terminatePosix(handle);
}

export fn sx_terminal_status(handle_address: usize) callconv(.c) u32 {
    const handle = terminalHandle(handle_address) orelse return 0;
    return @intCast(handle.status);
}

export fn sx_terminal_destroy(handle_address: usize) callconv(.c) void {
    const handle = terminalHandle(handle_address) orelse return;
    if (is_windows) destroyWindows(handle) else destroyPosix(handle);
    allocator.destroy(handle);
}

fn terminalHandle(address: usize) ?*TerminalHandle {
    if (address == 0) return null;
    return @ptrFromInt(address);
}

const PollFd = extern struct { fd: i32, events: i16, revents: i16 };
const WindowSize = extern struct { rows: u16, columns: u16, x_pixels: u16, y_pixels: u16 };

extern fn posix_openpt(flags: i32) i32;
extern fn grantpt(descriptor: i32) i32;
extern fn unlockpt(descriptor: i32) i32;
extern fn ptsname(descriptor: i32) ?[*:0]u8;
extern fn fork() i32;
extern fn setsid() i32;
extern fn open(path: [*:0]const u8, flags: i32, ...) i32;
extern fn dup2(source: i32, target: i32) i32;
extern fn close(descriptor: i32) i32;
extern fn chdir(path: [*:0]const u8) i32;
extern fn execve(path: [*:0]const u8, arguments: [*:null]const ?[*:0]const u8, environment: [*:null]const ?[*:0]const u8) i32;
extern fn _exit(status: i32) noreturn;
extern fn waitpid(process: i32, status: *i32, options: i32) i32;
extern fn kill(process: i32, signal: i32) i32;
extern fn poll(descriptors: [*]PollFd, count: usize, timeout: i32) i32;
extern fn pipe(descriptors: *[2]i32) i32;
extern fn read(descriptor: i32, buffer: [*]u8, count: usize) isize;
extern fn write(descriptor: i32, buffer: [*]const u8, count: usize) isize;
extern fn ioctl(descriptor: i32, request: usize, argument: usize) i32;
extern fn __ioctl(descriptor: i32, request: usize, argument: usize) i32;
extern fn usleep(microseconds: u32) i32;
extern fn __error() *i32;
extern fn __errno_location() *i32;

fn posixError(fallback: i32) i32 {
    const value = if (builtin.os.tag == .macos) __error().* else __errno_location().*;
    return if (value == 0) fallback else value;
}

fn systemIoctl(descriptor: i32, request: usize, argument: usize) i32 {
    if (builtin.os.tag == .macos) return __ioctl(descriptor, request, argument);
    return ioctl(descriptor, request, argument);
}

fn spawnPosix(
    handle: *PosixHandle,
    executable_address: usize,
    arguments_address: usize,
    directory_address: usize,
    environment_address: usize,
    columns: i32,
    rows: i32,
) void {
    const executable: [*:0]const u8 = @ptrFromInt(executable_address);
    const arguments: [*:null]const ?[*:0]const u8 = @ptrFromInt(arguments_address);
    const environment: [*:null]const ?[*:0]const u8 = @ptrFromInt(environment_address);
    const open_no_ctty: i32 = if (builtin.os.tag == .macos) 0x0002_0000 else 0x0100;
    const master = posix_openpt(2 | open_no_ctty);
    if (master < 0) {
        handle.error_code = 1;
        return;
    }
    if (grantpt(master) != 0 or unlockpt(master) != 0) {
        _ = close(master);
        handle.error_code = 2;
        return;
    }
    const slave_name = ptsname(master) orelse {
        _ = close(master);
        handle.error_code = 3;
        return;
    };
    var ready_pipe = [2]i32{ -1, -1 };
    if (pipe(&ready_pipe) != 0) {
        _ = close(master);
        handle.error_code = 4;
        return;
    }
    const child = fork();
    if (child < 0) {
        _ = close(ready_pipe[0]);
        _ = close(ready_pipe[1]);
        _ = close(master);
        handle.error_code = 4;
        return;
    }
    if (child == 0) {
        _ = close(ready_pipe[0]);
        if (setsid() < 0) _exit(127);
        const slave = open(slave_name, 2);
        if (slave < 0) _exit(127);
        const controlling_terminal: usize = if (builtin.os.tag == .macos) 0x2000_7461 else 0x540E;
        _ = systemIoctl(slave, controlling_terminal, 0);
        var initial_size = WindowSize{
            .rows = @intCast(rows),
            .columns = @intCast(columns),
            .x_pixels = 0,
            .y_pixels = 0,
        };
        const set_window_size: usize = if (builtin.os.tag == .macos) 0x8008_7467 else 0x5414;
        _ = systemIoctl(slave, set_window_size, @intFromPtr(&initial_size));
        if (dup2(slave, 0) < 0 or dup2(slave, 1) < 0 or dup2(slave, 2) < 0) _exit(127);
        if (slave > 2) _ = close(slave);
        _ = close(master);
        var ready: u8 = 1;
        _ = write(ready_pipe[1], @ptrCast(&ready), 1);
        _ = close(ready_pipe[1]);
        if (directory_address != 0) {
            const directory: [*:0]const u8 = @ptrFromInt(directory_address);
            if (chdir(directory) != 0) _exit(127);
        }
        _ = execve(executable, arguments, environment);
        _exit(127);
    }
    _ = close(ready_pipe[1]);
    var ready: u8 = 0;
    const ready_count = read(ready_pipe[0], @ptrCast(&ready), 1);
    _ = close(ready_pipe[0]);
    if (ready_count != 1) {
        _ = kill(child, 15);
        var ignored: i32 = 0;
        _ = waitpid(child, &ignored, 0);
        _ = close(master);
        handle.error_code = 5;
        return;
    }
    handle.process = child;
    handle.master = master;
    handle.running = true;
}

fn writePosix(handle: *PosixHandle, bytes_address: usize, byte_count: i32) i32 {
    const bytes: [*]const u8 = @ptrFromInt(bytes_address);
    const result = write(handle.master, bytes, @intCast(byte_count));
    if (result < 0) {
        handle.error_code = 5;
        refreshPosixExit(handle);
        return if (handle.running) -1 else -2;
    }
    return @intCast(result);
}

fn pollPosix(handle: *PosixHandle, bytes_address: usize, byte_capacity: i32, timeout_milliseconds: i32) i32 {
    if (!handle.running) return encodedPosixExit(handle);
    var descriptor = PollFd{ .fd = handle.master, .events = 0x0001, .revents = 0 };
    const ready = poll(@ptrCast(&descriptor), 1, timeout_milliseconds);
    if (ready < 0) {
        handle.error_code = 6;
        return -1;
    }
    if (ready > 0 and (descriptor.revents & (0x0001 | 0x0010)) != 0) {
        const bytes: [*]u8 = @ptrFromInt(bytes_address);
        const count = read(handle.master, bytes, @intCast(byte_capacity));
        if (count > 0) return @intCast(count);
        if (count < 0 and (descriptor.revents & 0x0001) != 0) {
            handle.error_code = 7;
            return -1;
        }
    }
    refreshPosixExit(handle);
    return if (handle.running) 0 else encodedPosixExit(handle);
}

fn encodedPosixExit(handle: *PosixHandle) i32 {
    return if (handle.signaled) -2000 else -1000;
}

fn resizePosix(handle: *PosixHandle, columns: i32, rows: i32) i32 {
    if (handle.master < 0) return 0;
    var size = WindowSize{
        .rows = @intCast(rows),
        .columns = @intCast(columns),
        .x_pixels = 0,
        .y_pixels = 0,
    };
    const request: usize = if (builtin.os.tag == .macos) 0x8008_7467 else 0x5414;
    var attempt: i32 = 0;
    while (attempt < 100) : (attempt += 1) {
        if (systemIoctl(handle.master, request, @intFromPtr(&size)) == 0) return 1;
        if (posixError(8) != 25) break;
        _ = usleep(1000);
    }
    handle.error_code = posixError(8);
    return 0;
}

fn terminatePosix(handle: *PosixHandle) i32 {
    if (kill(-handle.process, 15) == 0) return 1;
    refreshPosixExit(handle);
    if (!handle.running) return 1;
    handle.error_code = 9;
    return 0;
}

fn refreshPosixExit(handle: *PosixHandle) void {
    if (!handle.running) return;
    var status: i32 = 0;
    const result = waitpid(handle.process, &status, 1);
    if (result <= 0) return;
    handle.running = false;
    if ((status & 0x7f) == 0) {
        handle.status = (status >> 8) & 0xff;
        handle.signaled = false;
    } else {
        handle.status = status & 0x7f;
        handle.signaled = true;
    }
}

fn destroyPosix(handle: *PosixHandle) void {
    if (handle.running) {
        _ = kill(-handle.process, 15);
        var status: i32 = 0;
        var attempt: i32 = 0;
        while (attempt < 100) : (attempt += 1) {
            if (waitpid(handle.process, &status, 1) == handle.process) break;
            _ = usleep(1000);
        }
        if (attempt == 100) {
            _ = kill(-handle.process, 9);
            _ = waitpid(handle.process, &status, 0);
        }
        handle.running = false;
    }
    if (handle.master >= 0) {
        _ = close(handle.master);
        handle.master = -1;
    }
}

const Coord = extern struct { x: i16, y: i16 };
const StartupInfoW = extern struct {
    cb: u32,
    reserved: ?[*:0]u16,
    desktop: ?[*:0]u16,
    title: ?[*:0]u16,
    x: u32,
    y: u32,
    x_size: u32,
    y_size: u32,
    x_characters: u32,
    y_characters: u32,
    fill_attribute: u32,
    flags: u32,
    show_window: u16,
    reserved_size: u16,
    reserved_bytes: ?[*]u8,
    standard_input: usize,
    standard_output: usize,
    standard_error: usize,
};
const StartupInfoExW = extern struct { startup: StartupInfoW, attributes: ?*anyopaque };
const ProcessInformation = extern struct { process: usize, thread: usize, process_id: u32, thread_id: u32 };

extern "kernel32" fn CreatePipe(read_pipe: *usize, write_pipe: *usize, attributes: ?*anyopaque, size: u32) callconv(.winapi) i32;
extern "kernel32" fn CreatePseudoConsole(size: Coord, input: usize, output: usize, flags: u32, pseudo_console: *usize) callconv(.winapi) i32;
extern "kernel32" fn ResizePseudoConsole(pseudo_console: usize, size: Coord) callconv(.winapi) i32;
extern "kernel32" fn ClosePseudoConsole(pseudo_console: usize) callconv(.winapi) void;
extern "kernel32" fn InitializeProcThreadAttributeList(attributes: ?*anyopaque, count: u32, flags: u32, size: *usize) callconv(.winapi) i32;
extern "kernel32" fn UpdateProcThreadAttribute(attributes: *anyopaque, flags: u32, attribute: usize, value: *const anyopaque, size: usize, previous: ?*anyopaque, returned_size: ?*usize) callconv(.winapi) i32;
extern "kernel32" fn DeleteProcThreadAttributeList(attributes: *anyopaque) callconv(.winapi) void;
extern "kernel32" fn CreateProcessW(application: ?[*:0]const u16, command_line: [*:0]u16, process_attributes: ?*anyopaque, thread_attributes: ?*anyopaque, inherit_handles: i32, creation_flags: u32, environment: ?*anyopaque, directory: ?[*:0]const u16, startup: *StartupInfoW, process: *ProcessInformation) callconv(.winapi) i32;
extern "kernel32" fn PeekNamedPipe(pipe: usize, buffer: ?*anyopaque, buffer_size: u32, bytes_read: ?*u32, available: ?*u32, remaining: ?*u32) callconv(.winapi) i32;
extern "kernel32" fn ReadFile(file: usize, buffer: *anyopaque, count: u32, read_count: *u32, overlapped: ?*anyopaque) callconv(.winapi) i32;
extern "kernel32" fn WriteFile(file: usize, buffer: *const anyopaque, count: u32, written_count: *u32, overlapped: ?*anyopaque) callconv(.winapi) i32;
extern "kernel32" fn WaitForSingleObject(handle: usize, milliseconds: u32) callconv(.winapi) u32;
extern "kernel32" fn GetExitCodeProcess(process: usize, exit_code: *u32) callconv(.winapi) i32;
extern "kernel32" fn TerminateProcess(process: usize, exit_code: u32) callconv(.winapi) i32;
extern "kernel32" fn CloseHandle(handle: usize) callconv(.winapi) i32;
extern "kernel32" fn GetLastError() callconv(.winapi) u32;
extern "kernel32" fn GetTickCount64() callconv(.winapi) u64;
extern "kernel32" fn Sleep(milliseconds: u32) callconv(.winapi) void;

fn spawnWindows(
    handle: *WindowsHandle,
    executable_address: usize,
    arguments_address: usize,
    directory_address: usize,
    environment_address: usize,
    columns: i32,
    rows: i32,
) void {
    var input_read: usize = 0;
    var input_write: usize = 0;
    var output_read: usize = 0;
    var output_write: usize = 0;
    if (CreatePipe(&input_read, &input_write, null, 0) == 0 or CreatePipe(&output_read, &output_write, null, 0) == 0) {
        handle.error_code = @intCast(GetLastError());
        closeWindowsHandle(input_read);
        closeWindowsHandle(input_write);
        closeWindowsHandle(output_read);
        closeWindowsHandle(output_write);
        return;
    }
    var pseudo_console: usize = 0;
    if (CreatePseudoConsole(.{ .x = @intCast(columns), .y = @intCast(rows) }, input_read, output_write, 0, &pseudo_console) != 0) {
        handle.error_code = @intCast(GetLastError());
        closeWindowsHandle(input_read);
        closeWindowsHandle(input_write);
        closeWindowsHandle(output_read);
        closeWindowsHandle(output_write);
        return;
    }
    closeWindowsHandle(input_read);
    closeWindowsHandle(output_write);

    var attribute_bytes: [128]usize = undefined;
    var attribute_size: usize = @sizeOf(@TypeOf(attribute_bytes));
    const attributes: *anyopaque = @ptrCast(&attribute_bytes);
    if (InitializeProcThreadAttributeList(attributes, 1, 0, &attribute_size) == 0 or
        UpdateProcThreadAttribute(attributes, 0, 0x0002_0016, @ptrFromInt(pseudo_console), @sizeOf(usize), null, null) == 0)
    {
        handle.error_code = @intCast(GetLastError());
        ClosePseudoConsole(pseudo_console);
        closeWindowsHandle(input_write);
        closeWindowsHandle(output_read);
        return;
    }
    defer DeleteProcThreadAttributeList(attributes);

    _ = executable_address;
    var command_line: [32768]u16 = undefined;
    const command = commandLine(arguments_address, &command_line) orelse {
        handle.error_code = 206;
        ClosePseudoConsole(pseudo_console);
        closeWindowsHandle(input_write);
        closeWindowsHandle(output_read);
        return;
    };
    var environment: [32768]u16 = undefined;
    var environment_pointer: ?[*]u16 = null;
    if (environment_address != 0) {
        environment_pointer = environmentBlock(environment_address, &environment) orelse {
            handle.error_code = 206;
            ClosePseudoConsole(pseudo_console);
            closeWindowsHandle(input_write);
            closeWindowsHandle(output_read);
            return;
        };
    }
    var directory_utf16: [32768]u16 = undefined;
    const directory = if (directory_address == 0) null else utf16String(directory_address, &directory_utf16);
    if (directory_address != 0 and directory == null) {
        handle.error_code = 1113;
        ClosePseudoConsole(pseudo_console);
        closeWindowsHandle(input_write);
        closeWindowsHandle(output_read);
        return;
    }

    var startup = std.mem.zeroes(StartupInfoExW);
    startup.startup.cb = @sizeOf(StartupInfoExW);
    startup.attributes = attributes;
    var process = std.mem.zeroes(ProcessInformation);
    const raw_environment: ?*anyopaque = if (environment_pointer) |pointer| @ptrCast(pointer) else null;
    var creation_flags: u32 = 0x0008_0000;
    if (raw_environment != null) creation_flags |= 0x0000_0400;
    if (CreateProcessW(
        null,
        command,
        null,
        null,
        0,
        creation_flags,
        raw_environment,
        directory,
        &startup.startup,
        &process,
    ) == 0) {
        handle.error_code = @intCast(GetLastError());
        ClosePseudoConsole(pseudo_console);
        closeWindowsHandle(input_write);
        closeWindowsHandle(output_read);
        return;
    }
    closeWindowsHandle(process.thread);
    handle.process = process.process;
    handle.input = input_write;
    handle.output = output_read;
    handle.pseudo_console = pseudo_console;
    handle.running = true;
}

fn writeWindows(handle: *WindowsHandle, bytes_address: usize, byte_count: i32) i32 {
    var written: u32 = 0;
    const bytes: *const anyopaque = @ptrFromInt(bytes_address);
    if (WriteFile(handle.input, bytes, @intCast(byte_count), &written, null) == 0) {
        handle.error_code = @intCast(GetLastError());
        refreshWindowsExit(handle);
        return if (handle.running) -1 else -2;
    }
    return @intCast(written);
}

fn pollWindows(handle: *WindowsHandle, bytes_address: usize, byte_capacity: i32, timeout_milliseconds: i32) i32 {
    if (!handle.running) return -1000;
    const deadline = GetTickCount64() + @as(u64, @intCast(timeout_milliseconds));
    while (true) {
        var available: u32 = 0;
        if (PeekNamedPipe(handle.output, null, 0, null, &available, null) != 0 and available > 0) {
            var read_count: u32 = 0;
            const count: u32 = @min(available, @as(u32, @intCast(byte_capacity)));
            const bytes: *anyopaque = @ptrFromInt(bytes_address);
            if (ReadFile(handle.output, bytes, count, &read_count, null) == 0) {
                handle.error_code = @intCast(GetLastError());
                return -1;
            }
            return @intCast(read_count);
        }
        refreshWindowsExit(handle);
        if (!handle.running) return -1000;
        if (GetTickCount64() >= deadline) return 0;
        Sleep(1);
    }
}

fn resizeWindows(handle: *WindowsHandle, columns: i32, rows: i32) i32 {
    if (handle.pseudo_console == 0) return 0;
    if (ResizePseudoConsole(handle.pseudo_console, .{ .x = @intCast(columns), .y = @intCast(rows) }) == 0) return 1;
    handle.error_code = @intCast(GetLastError());
    return 0;
}

fn terminateWindows(handle: *WindowsHandle) i32 {
    if (TerminateProcess(handle.process, 1) != 0) return 1;
    refreshWindowsExit(handle);
    if (!handle.running) return 1;
    handle.error_code = @intCast(GetLastError());
    return 0;
}

fn refreshWindowsExit(handle: *WindowsHandle) void {
    if (!handle.running or handle.process == 0) return;
    if (WaitForSingleObject(handle.process, 0) != 0) return;
    var status: u32 = 0;
    if (GetExitCodeProcess(handle.process, &status) == 0) {
        handle.error_code = @intCast(GetLastError());
        return;
    }
    handle.status = status;
    handle.running = false;
}

fn destroyWindows(handle: *WindowsHandle) void {
    if (handle.running and handle.process != 0) {
        _ = TerminateProcess(handle.process, 1);
        _ = WaitForSingleObject(handle.process, 5000);
        handle.running = false;
    }
    if (handle.pseudo_console != 0) ClosePseudoConsole(handle.pseudo_console);
    closeWindowsHandle(handle.input);
    closeWindowsHandle(handle.output);
    closeWindowsHandle(handle.process);
}

fn closeWindowsHandle(handle: usize) void {
    if (handle != 0 and handle != std.math.maxInt(usize)) _ = CloseHandle(handle);
}

fn utf16String(address: usize, output: *[32768]u16) ?[*:0]u16 {
    const input: [*:0]const u8 = @ptrFromInt(address);
    var source: usize = 0;
    var target: usize = 0;
    while (input[source] != 0) {
        const decoded = decodeUtf8(input + source) orelse return null;
        if (!appendCodepoint(output, &target, decoded.codepoint)) return null;
        source += decoded.length;
    }
    if (target >= output.len) return null;
    output[target] = 0;
    return @ptrCast(output);
}

fn commandLine(arguments_address: usize, output: *[32768]u16) ?[*:0]u16 {
    const arguments: [*:null]const ?[*:0]const u8 = @ptrFromInt(arguments_address);
    var target: usize = 0;
    var index: usize = 0;
    while (arguments[index]) |argument| : (index += 1) {
        if (index > 0 and !appendUnit(output, &target, ' ')) return null;
        if (!appendQuotedArgument(output, &target, argument)) return null;
    }
    if (target >= output.len) return null;
    output[target] = 0;
    return @ptrCast(output);
}

fn environmentBlock(environment_address: usize, output: *[32768]u16) ?[*]u16 {
    const environment: [*:null]const ?[*:0]const u8 = @ptrFromInt(environment_address);
    var target: usize = 0;
    var index: usize = 0;
    while (environment[index]) |entry| : (index += 1) {
        var source: usize = 0;
        while (entry[source] != 0) {
            const decoded = decodeUtf8(entry + source) orelse return null;
            if (!appendCodepoint(output, &target, decoded.codepoint)) return null;
            source += decoded.length;
        }
        if (!appendUnit(output, &target, 0)) return null;
    }
    if (!appendUnit(output, &target, 0)) return null;
    if (index == 0 and !appendUnit(output, &target, 0)) return null;
    return @ptrCast(output);
}

fn appendQuotedArgument(output: *[32768]u16, target: *usize, argument: [*:0]const u8) bool {
    var quoted = argument[0] == 0;
    var probe: usize = 0;
    while (argument[probe] != 0) : (probe += 1) {
        if (argument[probe] == ' ' or argument[probe] == '\t' or argument[probe] == '"') quoted = true;
    }
    if (quoted and !appendUnit(output, target, '"')) return false;
    var source: usize = 0;
    var backslashes: usize = 0;
    while (true) {
        const byte = argument[source];
        if (byte == '\\') {
            backslashes += 1;
            source += 1;
            continue;
        }
        if (byte == '"') {
            var count: usize = 0;
            while (count < backslashes * 2 + 1) : (count += 1) if (!appendUnit(output, target, '\\')) return false;
            if (!appendUnit(output, target, '"')) return false;
            backslashes = 0;
            source += 1;
            continue;
        }
        if (byte == 0) {
            const multiplier: usize = if (quoted) 2 else 1;
            var count: usize = 0;
            while (count < backslashes * multiplier) : (count += 1) if (!appendUnit(output, target, '\\')) return false;
            break;
        }
        var count: usize = 0;
        while (count < backslashes) : (count += 1) if (!appendUnit(output, target, '\\')) return false;
        backslashes = 0;
        const decoded = decodeUtf8(argument + source) orelse return false;
        if (!appendCodepoint(output, target, decoded.codepoint)) return false;
        source += decoded.length;
    }
    if (quoted and !appendUnit(output, target, '"')) return false;
    return true;
}

const Decoded = struct { codepoint: u21, length: usize };

fn decodeUtf8(input: [*]const u8) ?Decoded {
    const first = input[0];
    if (first < 0x80) return .{ .codepoint = first, .length = 1 };
    var length: usize = 0;
    var codepoint: u32 = 0;
    var minimum: u32 = 0;
    if ((first & 0xE0) == 0xC0) { length = 2; codepoint = first & 0x1F; minimum = 0x80; }
    else if ((first & 0xF0) == 0xE0) { length = 3; codepoint = first & 0x0F; minimum = 0x800; }
    else if ((first & 0xF8) == 0xF0) { length = 4; codepoint = first & 0x07; minimum = 0x10000; }
    else return null;
    var index: usize = 1;
    while (index < length) : (index += 1) {
        const byte = input[index];
        if ((byte & 0xC0) != 0x80) return null;
        codepoint = (codepoint << 6) | (byte & 0x3F);
    }
    if (codepoint < minimum or codepoint > 0x10FFFF or (codepoint >= 0xD800 and codepoint <= 0xDFFF)) return null;
    return .{ .codepoint = @intCast(codepoint), .length = length };
}

fn appendCodepoint(output: *[32768]u16, target: *usize, codepoint: u21) bool {
    if (codepoint <= 0xFFFF) return appendUnit(output, target, @intCast(codepoint));
    const adjusted: u32 = @as(u32, codepoint) - 0x10000;
    return appendUnit(output, target, @intCast(0xD800 + (adjusted >> 10))) and
        appendUnit(output, target, @intCast(0xDC00 + (adjusted & 0x3FF)));
}

fn appendUnit(output: *[32768]u16, target: *usize, value: u16) bool {
    if (target.* >= output.len) return false;
    output[target.*] = value;
    target.* += 1;
    return true;
}

test "PTY accepts an empty environment and can be resized" {
    if (is_windows) return;
    const executable: [:0]const u8 = "/bin/cat";
    var arguments = [_]usize{ @intFromPtr(executable.ptr), 0 };
    var environment = [_]usize{0};
    const handle = sx_terminal_spawn(
        @intFromPtr(executable.ptr),
        @intFromPtr(&arguments),
        0,
        @intFromPtr(&environment),
        80,
        24,
    );
    try std.testing.expect(handle != 0);
    defer sx_terminal_destroy(handle);
    try std.testing.expectEqual(@as(i32, 0), sx_terminal_error(handle));
    try std.testing.expectEqual(@as(i32, 1), sx_terminal_resize(handle, 100, 30));
}
