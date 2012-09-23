# testing Makefile automatic dependency generation
# http://scottmcpeak.com/autodepend/autodepend.html

all: foo.o

ifdef GNUMAKE_VERSION
  DONTCARE := -
  $(shell echo "Setting DONTCARE to '-'" 1>&2)
endif

# compile and generate dependency info;
# more complicated dependency computation, so all prereqs listed
# will also become command-less, prereq-less targets
#   sed:    strip the target (everything before colon)
#   sed:    remove any continuation backslashes
#   fmt -1: list words one per line
#   sed:    strip leading spaces
#   sed:    add trailing colons
%.o: %.c
	gcc -c $(CFLAGS) $< -o $@
	gcc -MM $(CFLAGS) $< | sed 's/ / $(DONTCARE)/g' > $*.d

    @cp -f $*.d $*.d.tmp
    @sed -e 's/.*://' -e 's/\\$$//' < $*.d.tmp | fmt -1 | \
      sed -e 's/^ *//' -e 's/$$/:/' >> $*.d
    @rm -f $*.d.tmp

OBJS := foo.o

-include $(OBJS:.o=.d)

-include some-nonexistent-Makefile
