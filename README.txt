###############################################################################
##
##    Termux Root Filesystem
##
###############################################################################

A static root filesystem for Termux (AArch64). It is based on packages
from http://termux.net and some advanced software.

To use this rootfs, you need to replace Termux 'usr' directory (${PREFIX})
with these files. Then restart you Termux app, and run 'termux-setup-rootfs'.

Also you should check the manual by running 'man termux-rootfs'.

###############################################################################
##
##    Requirements
##
###############################################################################

* AArch64 (ARM64) architecture
* Android 6.x.x (security features of Android 7.0+ may break some apps)
* SELinux permissive (if enforced, some apps may not work)
* Root (a few apps won't work if your device is not rooted)
* 4GB of free space in /data

For optimal experience, you need to use the following modified Termux apps:
* Termux (Termux:Boot, Termux:Styling, Termux:Widget are integrated)
  APK is located at ${PREFIX}/share/doc/termux-rootfs/Termux.apk

* Termux:API
  APK is located at ${PREFIX}/share/doc/termux-rootfs/TermuxAPI.apk

###############################################################################
##
##    Password login protection
##
###############################################################################

You can prevent using of termux by unwanted users by setting password with
command 'passwd'. If you want to use a such feature, you must use a patched
Termux app (${PREFIX}/share/doc/termux-rootfs/Termux.apk) to prevent login bypassing
with a 'failsafe' shell.

To remove password login, run command 'rmlogin' or delete file 'login.pwd'
that located in '${PREFIX}/etc'.

###############################################################################
##
##    Available software
##
###############################################################################

admin tools:
  apt, bmon, cpulimit, debootstrap, dnsutils, dpkg, fsmon, geoip, htop,
  httping, hping3, iproute2, iperf3, iw, macchanger, ngrep, nmap, proot,
  sensors, sslscan, sipcalc, tcpdump, tracepath, whois, wireless-tools

android:
  adb, apktool, baksmali, boot.img-tools, buildapk, create-android-app,
  fastboot, mtk-tools, resetprop, sdat2img, smali, sparse-image-tools

archivers/compressors:
  bsdtar, bzip2, cpio, gzip, lhasa, lz4, lzip, lzop, par2, p7zip, tar,
  unrar, unzip, xz-utils, zip

binary file editors:
  bvi, hexcurse, hexedit, hte, radare2

console utils:
  abduco, asciinema, dialog, dvtm, screen, tmux, ttyrec

databases:
  mariadb, postgresql, redis, sqlite3

data processors:
  bc, datamash, docx2txt, dos2unix, ed, hunspell, micro, nano, pcapfix,
  poppler, stag, txt2man, urlview, vim (with python), xmlstarlet, xsltproc

data rescue:
  ddrescue, extundelete, photorec, testdisk

development:
  astyle, autoconf, automake, bash-bats, binutils, bison, cargo, cccc,
  cfr, cgdb, cmake, clang, cppi, cpplint, cproto, cscope, ctags, diff2html,
  diffstat, ecj, elfutils, expect, fasm, fasmarm, flex, indent, jack, gcc,
  gdb, go, gperf, llvm, ltrace, lua, m4, make, nodejs, openjdk7-jre, patchelf,
  perl, pforth, python2, python3, ruby, rust, tcl, texinfo, unifdef, valac, yasm

encryption:
  aespipe, codecrypt, cryptsetup, encfs, gnupg, gnutls, openssl, scrypt,
  steghide

filesystem:
  btrfs-progs, duff, e2fsprogs, exfat-utils, lvm2, squashfs-tools, zerofree

games:
  2048, bs, curseofwar, hangman, moon-buggy, nsnake, nudoku, pacman,
  typespeed, vitetris

generic utilities:
  ag, bash, busybox, coreutils, dash, diffutils, file, findutils, fzf, gawk,
  gettext, global, grep, inetutils, info, less, man, mktorrent, patch, procps,
  pwgen, ranpwd, rhash, rsync, tree, tasksh, taskwarrior, timewarrior, units,
  util-linux, xdelta3, zsh

libraries:
  apr, apr-util, boost, cairo, c-ares, db, expat, fftw, flac, fontconfig,
  freetype, gdbm, glib, gnutls, harfbuzz, harfbuzz-icu, icu, imlib2,
  libandroid-glob, libandroid-shmem, libandroid-support, libcaca, libconfig,
  libconfuse, libclang, libcroco, libcrypt, libcryptopp, libcurl, libedit,
  libevent, libffi, libgcrypt, libgd, libgit2, libgrpc, libid3tag, libidn,
  libisl, libjansson, libjasper, libjpeg-turbo, libleveldb, liblz4, libmad,
  libmp3lame, libmpc, libmpfr, libnet, libnl, libnpth, libogg, libpcap,
  libpcre, libpipeline, libpng, libpopt, libprotobuf, libqrencode, librsync,
  libsodium, libssh, libssh2, libtalloc, libtermux-exec, libtiff, libunistring,
  libutil, libuuid, libvorbis, libx264, libx265, libxml2, libxslt, libyaml,
  libzmq, libzopfli, ldns, leptonica, littlecms, miniupnpc, ncurses, nettle,
  nghttp2, openblas, openjpeg, openssl, opus, pango, poppler, readline,
  c-toxcore, zlib

media:
  dcraw, ffmpeg, figlet, graphicsmagick, optipng, play-audio, sox, tesseract,
  toilet

misc:
  crunch, cmatrix, ent, eschalot, kona, lolcat, mathomatic, pick, sc,
  vanitygen-plus

networking:
  aria2, cryptcat, curl, elinks, irssi, lftp, lynx, megatools, netcat,
  socat, syncthing, torsocks, toxic, transmission, tsocks, upnpc, wget,
  wput, zsync

pentesting & cracking:
  aircrack-ng, bettercap, fcrackzip, hydra, john, mdk3, metasploit-framework,
  pkcrack, reaver

python 3 modules:
  asciinema, asn1crypto, astroid, attrs, Automat, autopep8, bash-kernel,
  beautifulsoup4, bleach, certifi, cffi, chardet, click, constantly, coverage,
  cryptography, cssselect, cycler, Cython, decorator, dismagic, dj-database-url,
  dj-static, Django, django-bootstrap3, django-ckeditor, django-js-asset,
  django-orm-magic, django-profiler-middleware, django-pygments,
  djangorestframework, entrypoints, et-xmlfile, gevent, greenlet,
  guess-language-spirit, gunicorn, html5lib, httpie, httplib2, hyperlink,
  idna, incremental, iotop, ipdb, ipykernel, ipynose, ipyparallel, ipytest,
  ipython, ipython-genutils, ipywidgets, isort, jdcal, jedi, Jinja2, jsonschema,
  jupyter, jupyter-c-kernel, jupyter-client, jupyter-console, jupyter-core,
  jupyter-fortran-kernel, lazy-object-proxy, line-profiler, lxml, Markdown,
  markdown2, MarkupSafe, matplotlib, mccabe, memory-profiler, mistune, mpmath,
  nbconvert, nbextensions, nbformat, nose, notebook, numpy, odfpy, olefile,
  openpyxl, pandas, pandocfilters, parsel, path.py, pbr, pep257, pep8, pexpect,
  pickleshare, Pillow, pip, prompt-toolkit, psutil, psycopg2, ptyprocess, py,
  pyasn1, pyasn1-modules, PyBrain, pycodestyle, pycparser, pycrypto,
  PyDispatcher, pydocstyle, pyflakes, Pygments, pylama, pylint, PyMySQL,
  pyOpenSSL, pyparsing, pytest, python-dateutil, pytz, PyYAML, pyzmq, qrcode,
  qtconsole, queuelib, redis, redis-kernel, requests, scapy-python3, scikit-learn,
  scipy, Scrapy, service-identity, setuptools, sh, simplegeneric, six,
  snowballstemmer, SQLAlchemy, static3, sympy, tablib, terminado, testpath,
  texttable, tornado, traitlets, Twisted, unicodecsv, Unidecode, urllib3,
  virtualenv, virtualenv-clone, w3lib, waitress, wcwidth, webencodings, WebOb,
  WebTest, Werkzeug, wheel, widgetsnbextension, wrapt, xlrd, xlwt, zope.interface

servers:
  minecraft (v1.11.2) server, nginx, openssh, polipo, privoxy, stunnel,
  tor, transfer.sh

special/custom:
  fakechroot, fakeroot, login, linkchk, myip, passwd, service-manager, su, sudo,
  termux-backup, termux-gensslcerts, testport, update-config-guess, wifi-dump,
  wifi-jam, wttr.in

vcs:
  git, mercurial, tig
