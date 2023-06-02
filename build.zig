const std = @import("std");

const src_cpp = [_][]const u8{
    "lib/upstream/llama.cpp",
};

const cxx_flags = [_][]const u8{
    "-std=gnu++11",
    "-Wall",
    "-Wextra",
    "-Wpedantic",
    "-Wcast-qual",
    "-Wno-unused-function",
    "-Wno-multichar",
};

const src_c = [_][]const u8{
    "lib/upstream/ggml.c",
};

const c_flags = [_][]const u8{
    "-std=gnu11",
    "-Wall",
    "-Wextra",
    "-Wpedantic",
    "-Wcast-qual",
    "-Wdouble-promotion",
    "-Wshadow",
    "-Wstrict-prototypes",
    "-Wpointer-arith",
};

const src_main = [_][]const u8{
    "lib/upstream/examples/common.cpp",
    "lib/upstream/examples/main/main.cpp",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "llama",
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibCpp();
    lib.addCSourceFiles(&src_cpp, &cxx_flags);
    lib.addCSourceFiles(&src_c, &c_flags);
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "llama",
        .target = target,
        .optimize = optimize,
    });
    exe.addCSourceFiles(&src_main, &cxx_flags);
    exe.addIncludePath("lib/include");
    exe.addIncludePath("lib/upstream");
    exe.addIncludePath("lib/upstream/examples");
    exe.linkLibrary(lib);
    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // const unit_tests = b.addTest(.{
    //     .root_source_file = .{ .path = "src/main.zig" },
    //     .target = target,
    //     .optimize = optimize,
    // });

    // const run_unit_tests = b.addRunArtifact(unit_tests);
    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&run_unit_tests.step);
}
