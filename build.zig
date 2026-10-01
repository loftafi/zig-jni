const std = @import("std");

pub fn build(b: *std.Build) !void {
    // build options
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    // module exports
    const module = b.addModule("JNI", .{
        .root_source_file = b.path("src/main/zig/lib.zig"),
        .target = target,
        .optimize = optimize,
    });
    const cjni = b.addTranslateC(.{
        .root_source_file = b.path("src/include/jni/jni.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    module.addImport("cjni", cjni.createModule());

    if (target.result.abi.isAndroid()) {
        if (@import("build/FindNDK.zig").FindNDK.find(b.graph.io, &b.graph.environ_map) catch null) |android_ndk| {
            cjni.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{
                android_ndk,
                "toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include/",
            }) });
            cjni.addSystemIncludePath(.{ .cwd_relative = b.pathJoin(&.{
                android_ndk,
                "toolchains/llvm/prebuilt/darwin-x86_64/sysroot/usr/include/aarch64-linux-android/",
            }) });
        } else {
            @panic("android/linux build requires ndk. Set ANDROID_NDK_HOME");
        }
    }
}
