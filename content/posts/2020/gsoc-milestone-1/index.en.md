---
title: "GSoC Milestone 1"
date: 2020-06-20T18:01:49+09:00
type: posts
draft: false
---

### Introduction.
Hello. I'm currently participating in GSoC and developing under the Gentoo Foundation. I am developing a sandbox mechanism. Development is under going at [this repository on the GitHub](https://github.com/pluser/fusebox).

I started writing code at the beginning of June and am now roughly three weeks into it. In this article, I will summarize the results to date and explain what and how I am developing it. 

### What is a sandbox?
A sandbox, in a nutshell, is a type of security mechanism that ensures security by allowing potentially dangerous operations to be performed in a different environment than the real one.

So how, exactly, is the sandbox used?
In Gentoo Linux, the build process runs when the package is introduced. A normal application, for example, can be built by accessing the program's source files and using or access to tools installed on your system. However, some applications behave strangely during the build process. For example, they may rewrite the system's configuration file without your permission. These unintended behaviors can be a source of system breakage for a package system. This is why you need a software program that monitors the system for this kind of behavior. 

### How Fusebox works
Here I'm going to explain how my current sandbox, "Fusebox", works.

Fusebox uses the technology in its name, FUSE. So, before I explain about Fusebox, I should explain about FUSE. 

#### What is FUSE?
[FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace) stands for Filesystem in Userspace. This is a feature that Linux and BSD kernels have. I'd like to assume a Linux system for the sake of explanation.

![Structure of FUSE](FUSE_structure.svg)

ref: https://commons.wikimedia.org/wiki/File:FUSE_structure.svg

Normally, I/O instructions to a file from a user program go through a part called VFS. It is passed to the filesystem driver and from there to the hardware. This mechanism allows the VFS to absorb the differences between file systems. Therefore, userland programs do not have to worry about file system differences. 

In other words, file system development is essentially about creating an interface for VFS and programming how to store data on the abstracted hardware.

All of the file system implementations described so far run on top of the kernel space. Therefore, if there is a problem with the implementation, it can cause serious system problems, such as causing a kernel panic and, to make matters worth, makes debugging more difficult.

So "FUSE" has been designed to provide this file system with a userland implementation. The system calls issued by the application are sent via VFS to the FUSE module and passed to the userland program.

Furthermore, you can use FUSE to create a virtual file system. We are all familiar with the `/proc` and `/sys` virtual file systems, but you can also create a virtual file system using FUSE. You can create a virtual file system similar to those. 

#### Application of FUSE.
So what does FUSE, which implements the file system in userland, have to do with the sandbox?
The current plan is to mirror the entire root file system with Fusebox. And on that mirrored file system (Fusebox), I can monitor and control access to your files by build process.

### Current Fusebox Status
Let's take a look at the current implementation of Fusebox.

Fusebox mounts the root file system and mount the `/sys` and `/dev` over it. Because that pseudo filesystem is needed by the application such as `emerge`. And then `chroot` on the Fusebox file system. By implementing FUSE interface, now I can run `emerge --info`, `emerge -p gentoo-source` commands. The file system I implemented allows me to take logging, and monitoring.

There are a lot of things I am going to do, but the most important one is integration with `emerge` tools. The fusebox  should be able to launch seamlessly from the `emerge` tool. To be honest, I don't have detailed knowledge of the inner workings of the `emerge` tool. I'll have to read the code and think about how to implement it.

### Difficult Part of Implementation
The most difficult part of implementing Fusebox so far is getting the inodes to work. The FUSE API by the kernel sends a operation order from the application to the Fusebox. But some of them only contain the inode of the target file. As a matter of fact, all the root inodes of the filesystem, such as `/` `/proc` `/sys`, are 1. So, if you try to mirror the tree with these filesystems mounted, you'll see that Inode conflicts occur.

How it's implemented is that applications usually use `open()` and other Before accessing the file, the file list is fetched by `lookup()` and the path Call the API to get the inode number from the name. At that point, for special paths such as `/sys` and `proc`, there is a completely different By returning the inode number, we avoid collisions.

Here's how it's implemented. Applications usually start by fetching a list of files, such as a `lookup()`, and then file accesses such as `open()` are performed based on the inode number. So, if `lookup()` is called with special paths such as `/sys` and `/proc`, fusebox reply lying inode number to avoid inode collision.

Currently, the project uses the `pyfuse3` library, as it is the same developer of the widely-used C library `libfuse`. It supports asynchronous processing and thus has good for performance. However, this low-level library is tied in one-to-one with the kernel processing, so the You need to know more about the behavior of the system and it's not easy.
