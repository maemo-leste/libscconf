NAME  = libscconf
SO    = .so.0
SOMIN = $(SO).1

INCNAME = scconf.h

DESTDIR  ?= test-install

CPPFLAGS += -DHAVE_STRINGS_H
CPPFLAGS += -I. -Icommon

CFLAGS   += -Wall
CFLAGS   += -O2
CFLAGS   += -g

LDFLAGS  +=

LDLIBS   += -Wl,--as-needed

%.pic.o : CFLAGS += -fPIC
%.pic.o : %.c ; $(CC) -c -o $@ $< $(CPPFLAGS) $(CFLAGS)

%.o     : %.c ; $(CC) -c -o $@ $< $(CPPFLAGS) $(CFLAGS)

lib%$(SO) : LDFLAGS += -Wl,-soname,$@
lib%$(SO) : ; $(CC) -shared -o $@ $^ -Wl,--version-script,scconf.version $(LDFLAGS) $(LDLIBS)
lib%.a    : ; $(AR) ru $@ $^

SRCS = scconf.c parse.c sclex.c write.c compat_strlcpy.c

OBJS_SHARED = $(SRCS:%.c=%.pic.o)
OBJS_STATIC = $(SRCS:%.c=%.o)

TARGETS += libscconf.a
TARGETS += libscconf$(SO)
TARGETS += libscconf.so

.PHONY: all install distclean clean mostlyclean

all:: $(TARGETS)

distclean:: clean

clean:: mostlyclean
	$(RM) $(TARGETS)

mostlyclean::
	$(RM) *.o *~

libscconf.a: $(OBJS_STATIC)
libscconf$(SO): $(OBJS_SHARED)
libscconf.so:
	ln -sf libscconf$(SO) $@

install:: all
	# install dirs
	install -d $(DESTDIR)/usr/lib $(DESTDIR)/usr/include
	# shared library
	install -m 644 libscconf$(SO) $(DESTDIR)/usr/lib/libscconf$(SOMIN)
	# versioned symlink to shared library
	ln -sf libscconf$(SOMIN) $(DESTDIR)/usr/lib/libscconf$(SO)
	# headers
	install -m 644 $(INCNAME) $(DESTDIR)/usr/include/
	# symlink to shared library for linking
	ln -sf libscconf$(SOMIN) $(DESTDIR)/usr/lib/libscconf.so
	# static library
	install -m 644 libscconf.a $(DESTDIR)/usr/lib/

.PHONY: debclean
debclean::
	fakeroot debian/rules clean

NORMALIZE_ALL += debian/control
NORMALIZE_ALL += debian/changelog
NORMALIZE_ALL += debian/copyright
NORMALIZE_ALL += debian/api

NORMALIZE_MAKE += Makefile
NORMALIZE_MAKE += debian/rules

.PHONY: normalize
normalize:
	crlf -a $(NORMALIZE_ALL)
	crlf -M $(NORMALIZE_MAKE)
