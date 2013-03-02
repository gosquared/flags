# Flag-set-generating makefile

INDIR := src/flags
OUTDIR := flags
OVERLAYDIR := src/overlays

SIZES ?= 16 24 32 48 64

# icns files don't support 24x24 or 64x64
ICNS_SIZES := $(filter-out 24 64,$(SIZES))

FLAGS := $(shell ls $(INDIR))

SQUARE := $(filter Vatican-City Switzerland,$(FLAGS))
NEPAL := $(filter Nepal,$(FLAGS))
NORMAL := $(filter-out $(SQUARE) $(NEPAL),$(FLAGS))

PNGCRUSH_OPTIONS ?= -q -brute -rem alla

# temporary file prefix we'll use
TMP_FILE := $(shell mktemp -u)
PWD := $(shell pwd)

# change to cp for testing puposes
copy_png = pngcrush ${PNGCRUSH_OPTIONS}

# a lot of the files are just renames of other generated
# files. This is the least messy way I can find to do it.
define copy_file
$1: $2
	@mkdir -p $$(@D)
	cp $$^ $$@
endef

define process_flag
# flat normal
$2: $1
	@mkdir -p $$(@D)
	$(copy_png) $$^ $$@

# shiny normal
$3: $1
	@mkdir -p $$(@D)
	composite ${OVERLAYDIR}/$6/$7.png $$^ $8; $(copy_png) $8 $$@
	@rm -f $8

# iso
$(call copy_file,$4,$2)
$(call copy_file,$5,$3)

FLAG_FILES += $2 $3 $4 $5
endef


define define_icon
# normal
$1/flat/$5/$3.$5: $(addsuffix /$3.png,$(addprefix $1/flat/,$6))
$1/shiny/$5/$3.$5: $(addsuffix /$3.png,$(addprefix $1/shiny/,$6))

# iso
$(call copy_file,$2/flat/$5/$4.$5,$1/flat/$5/$3.$5)
$(call copy_file,$2/shiny/$5/$4.$5,$1/shiny/$5/$3.$5)

$1/flat/$5/$3.$5 $1/shiny/$5/$3.$5:
	@mkdir -p $$(@D)
ifeq (ico,$5)
	convert $$^ $$@
else
	png2icns $$@ $$^ > /dev/null
endif

FLAG_FILES += \
	$1/flat/$5/$3.$5 \
	$2/flat/$5/$4.$5 \
	$1/shiny/$5/$3.$5 \
	$2/shiny/$5/$4.$5
endef

define define_flag
$(foreach size,${SIZES},\
	$(call process_flag,\
		${INDIR}/$1/$(size).png,\
		${OUTDIR}/flags/flat/$(size)/$1.png,\
		${OUTDIR}/flags/shiny/$(size)/$1.png,\
		${OUTDIR}/flags-iso/flat/$(size)/$2.png,\
		${OUTDIR}/flags-iso/shiny/$(size)/$2.png,$3,$(size),${TMP_FILE}.$2.$(size).png))

$(call define_icon,${OUTDIR}/flags,${OUTDIR}/flags-iso,$1,$2,ico,$(SIZES))
$(call define_icon,${OUTDIR}/flags,${OUTDIR}/flags-iso,$1,$2,icns,$(ICNS_SIZES))
endef


.PHONY: all clean

all: flags.zip



$(foreach flag,${NORMAL}, \
	$(eval $(call define_flag,$(flag),$(shell cat "${INDIR}/$(flag)/code"),normal)))

$(foreach flag,${SQUARE}, \
	$(eval $(call define_flag,$(flag),$(shell cat "${INDIR}/$(flag)/code"),square)))

$(foreach flag,${NEPAL}, \
	$(eval $(call define_flag,$(flag),$(shell cat "${INDIR}/$(flag)/code"),nepal)))

ZIPFILES = \
	${FLAG_FILES} \
	${OUTDIR}/LICENSE.txt \
	${OUTDIR}/Hello.txt


flags.zip: ${OUTDIR} ${ZIPFILES}
	$(if $(wildcard $@),rm -f $@,)
	cd ${OUTDIR}; zip -q -r -9 -T ${PWD}/$@ *

${OUTDIR}: ${ZIPFILES}

${OUTDIR}/%.txt: %.txt
	cp $*.txt $@

clean:
	rm -fr ${OUTDIR} flags.zip
