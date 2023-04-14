### basmati - jasmin compiler in a container
#### Yawning Angel <yawning@schwanenlied.me>

This is the [jasmin][1] compiler and dependencies packaged in a
container in an attempt to make it easy to do development WITH
jasmin, for people that don't neccecarily want to install nix
or OPAM on their system, based on the [quick start instructions][2]
by Peter Schwabe.

This has been developed on an envrionment with podman instead of docker
however, docker should work, and will probably work better than podman
because the bind-mount situation is less nightmarish.  If you are stuck
using podman, read the contents of `storage.conf.podman` before building
the container image.

##### Dockerfile arguments

| Argument              | Default value | Description                          |
| --------------------- | ------------- | ------------------------------------ |
| `OPAM_UID`            | `1000`        | uid of the `opam` user               |
| `OPAM_GID`            | `1000`        | gid of the `opam` user               |
| `JASMIN_GIT_CHECKOUT` | `main`        | jasmin branch/tag/commit to checkout |
| `JASMIN_FORCE`        | `no`          | force rebuild of the jasmin layer    |

##### basmati-shell

A handy shell-script is provided that will spawn the container with the
current working directory bind-mounted in.  This assumes that the docker
image is tagged as `basmati`, and is sufficient for building the quickstart
example, and even compile/testing libjade.

```
ypres :: Documents/Development/basmati % cd example
ypres :: Development/basmati/example % ../basmati-shell
opam@771e24689603:/data$ make
jasminc -o addvec.s -lea addvec.jazz
"addvec.jazz", line 64 (2-28)
warning: extra assignment introduced:
           RAX = #LEA_64((RSP + ((64u) 1536))); /* :r */
"addvec.jazz", line 64 (2-28)
warning: extra assignment introduced:
           RCX = #LEA_64((RSP + ((64u) 512))); /* :r */
"addvec.jazz", line 64 (2-28)
warning: extra assignment introduced:
           R8 = #MOV_64(RSP); /* :r */
"addvec.jazz", line 65 (2-30)
warning: extra assignment introduced:
           RAX = #LEA_64((RSP + ((64u) 2048))); /* :r */
"addvec.jazz", line 65 (2-30)
warning: extra assignment introduced:
           RCX = #LEA_64((RSP + ((64u) 512))); /* :r */
"addvec.jazz", line 65 (2-30)
warning: extra assignment introduced:
           R8 = #MOV_64(RSP); /* :r */
"addvec.jazz", line 66 (2-29)
warning: extra assignment introduced:
           RAX = #LEA_64((RSP + ((64u) 1024))); /* :r */
"addvec.jazz", line 66 (2-29)
warning: extra assignment introduced:
           RCX = #LEA_64((RSP + ((64u) 512))); /* :r */
"addvec.jazz", line 66 (2-29)
warning: extra assignment introduced:
           R8 = #MOV_64(RSP); /* :r */
gcc -Wall -Wextra -Wpedantic main.c addvec.s -o main
opam@771e24689603:/data$ ./main
opam@771e24689603:/data$
```

###### Configuration environment variables

| Variable              | Default value | Description                 |
| --------------------- | ------------- | --------------------------- |
| BASMATI_IMAGE_TAG     | `basmati`     | container image tag/hash    |
| BASMATI_CONTAINER_CMD | (autodetects) | container tool executable   |
| BASMATI_SELINUX       | (unset)       | configure the SELinux label |

[1]: https://github.com/jasmin-lang/jasmin
[2]: https://cryptojedi.org/programming/jasmin.shtml