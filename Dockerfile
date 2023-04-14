#
# basmati - jasmin compiler in a container
#

LABEL org.opencontainers.image.title="basmati"
LABEL org.opencontainers.image.description="jasmin compiler"
LABEL org.opencontainers.image.authors="Yawning Angel <yawning@schwanenlied.me>"

# Update the OCaml base image, and install fundemental dependencies and
# build tools.
#
# Notes:
#  * libjade defaults to clang for CC (gcc appeared to work fine)
#  * python3-yaml is required by the jasmin compiler test suite.
#  * Pruning the apt lists would only save 40 MiB.
FROM docker.io/ocaml/opam:ubuntu-lts-ocaml-4.14 AS basmati-base
USER root
RUN apt-get update && apt-get install -y \
  # Basic development tools
  build-essential \
  clang \
  # Other dependencies
  autoconf \
  cvc4 \
  libgmp-dev \
  libmpfr-dev \
  libpcre3-dev \
  libppl-dev \
  pkg-config \
  python3-distutils \
  python3-yaml \
  vim \
  zlib1g-dev \
  && apt-get clean
# && rm -rf /var/lib/apt/lists/*

# Slay Docker permission demons, by making it possible to match the
# internal opam user's uid to an external uid.
#
# This is quite time consuming, and wastes disk-space by touching every
# file in the opam user's home directory, so in an ideal world the
# external user has gid/uid of 1000:1000 to match what the container
# comes with by default.
#
# TODO:
#  * Figure out a better solution to this problem.
ARG OPAM_UID=1000
ARG OPAM_GID=1000
RUN if [ 1000 -ne $OPAM_UID ] ; then usermod -u $OPAM_UID opam ; fi
RUN if [ 1000 -ne $OPAM_GID ] ; then groupmod -g $OPAM_GID opam && chgrp -R opam /home/opam ; fi

# Install the jasmin dependencies, and configure easycrypt.
FROM basmati-base AS basmati-jasmin-deps
USER opam
WORKDIR /home/opam
RUN eval $(opam env) \
  && opam pin -yn add easycrypt https://github.com/EasyCrypt/easycrypt.git \
  && opam pin -yn add jasmin https://github.com/jasmin-lang/jasmin.git \
  && opam repo add coq-released https://coq.inria.fr/opam/released \
  && opam pin -yn add coq-mathcomp-word https://github.com/jasmin-lang/coqword.git \
  && opam install alt-ergo.2.4.1 z3.4.11.0 \
  && opam install easycrypt \
  && opam install --deps-only jasmin \
  && opam clean \
  && easycrypt why3config

# Fetch and compile jasmin.
#
# TODO:
#  * Once `make check` passes, run it as part of the container build
#    process.  As of 2023/04/13 it fails in the ARM tests.
FROM basmati-jasmin-deps AS basmati
ARG JASMIN_GIT_CHECKOUT=main
ARG JASMIN_FORCE=no
WORKDIR /home/opam
RUN eval $(opam env) \
  && git clone https://github.com/jasmin-lang/jasmin.git \
  && cd jasmin/compiler \
  && git checkout $JASMIN_GIT_CHECKOUT \
  && make CIL \
  && make
COPY easycrypt.conf /home/opam/.config/easycrypt/

# Stick the jasmin executables in the PATH.
#
# Note: The location of the actual artifacts has changed as of
# https://github.com/jasmin-lang/jasmin/commit/471fe637d2563d91225717656282742381805b02
RUN ln -s /home/opam/jasmin/compiler/_build/default/entry/jasminc.exe /home/opam/.opam/4.14/bin/jasminc \
  && ln -s /home/opam/jasmin/compiler/_build/default/entry/jazz2tex.exe /home/opam/.opam/4.14/bin/jazz2tex
