# MakeDepends.make
#
# Handles auto-dependency generation for C/C++ files.
#
# How to use it:
#  - make sure any #include's you want marked as dependencies use
#    "" not <>
#  - include this file from the main Makefile
#  - make "cleandeps" a prerequisite for the "clean" target
#
# We override implicit rules for creating .o from .c/cpp/cc files -
# so don't create explicit compilation rules unless you have to.
# E.g. if you need to pass -Isomeplace for a certain .cpp, instead of this:
#	some.o: some.cpp
#		gcc -c -o $@ $< -Isomeplace $(CFLAGS)
# just override CFLAGS, like this:
#	some.o: CFLAGS += -Isomeplace
#
# If you do need a custom compilation rule, pass $(MAKEDEPENDS_CPPFLAGS)
# along to the compiler, and run $(DEPENDS_DANCING) at the end of the rule,
# like this:
#	some.o: some.cpp
#		gcc -c -o $@ $< --something $(MAKEDEPENDS_CPPFLAGS)
#		$(DEPENDS_DANCING)
#
# Origin:
# Scott McPeak's article on autodependencies with GNU make:
#	http://www.cs.berkeley.edu/~smcpeak/autodepend/autodepend.html
# Also Paul Smith's similar technique:
#	http://www.paulandlesley.org/gmake/autodep.html

# Instead of passing -MMD to gcc (which creates an autodependency file
# in the top-level directory), we have to tell it to pass the option
# with the right .d filename to the preprocessor.
MAKEDEPENDS_CPPFLAGS = -Wp,-MMD,$*.dtmp

define DEPENDS_DANCING
@gawk -v target=$@ -f MakeDepends.awk < $*.dtmp > $(dir $*)/.$(notdir $*).depend
@rm $*.dtmp
endef

%.o : %.cpp
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(MAKEDEPENDS_CPPFLAGS) $< -o $@
	$(DEPENDS_DANCING)

%.o : %.cc
	$(CXX) -c $(CXXFLAGS) $(CPPFLAGS) $(MAKEDEPENDS_CPPFLAGS) $< -o $@
	$(DEPENDS_DANCING)

%.o : %.c
	$(CC) -c $(CFLAGS) $(CPPFLAGS) $(MAKEDEPENDS_CPPFLAGS) $< -o $@
	$(DEPENDS_DANCING)


cleandeps:
	find . -name '.*.depend' | xargs rm -f


# I hope this is deep enough :)
-include /dev/null $(wildcard .*.depend */.*.depend */*/.*.depend	\
	*/*/*/.*.depend */*/*/*/.*.depend */*/*/*/*/.*.depend)
