
include CONFIG

MATH = $(patsubst %.cpp,%.o,$(wildcard Math/*.cpp))

TOOLS = $(patsubst %.cpp,%.o,$(wildcard Tools/*.cpp))

NETWORK = $(patsubst %.cpp,%.o,$(wildcard Networking/*.cpp))

PROCESSOR = $(patsubst %.cpp,%.o,$(wildcard Processor/*.cpp))

FHEOBJS = $(patsubst %.cpp,%.o,$(wildcard FHEOffline/*.cpp FHE/*.cpp)) Protocols/CowGearOptions.o

GC = $(patsubst %.cpp,%.o,$(wildcard GC/*.cpp)) $(PROCESSOR)
GC_SEMI = GC/SemiPrep.o GC/square64.o

OT = $(patsubst %.cpp,%.o,$(wildcard OT/*.cpp))
OT_EXE = ot.x ot-offline.x

COMMONOBJS = $(MATH) $(TOOLS) $(NETWORK) GC/square64.o Processor/OnlineOptions.o Processor/BaseMachine.o Processor/DataPositions.o Processor/ThreadQueues.o Processor/ThreadQueue.o
COMPLETE = $(COMMON) $(PROCESSOR) $(FHEOFFLINE) $(TINYOTOFFLINE) $(GC) $(OT)
YAO = $(patsubst %.cpp,%.o,$(wildcard Yao/*.cpp)) $(OT) BMR/Key.o
BMR = $(patsubst %.cpp,%.o,$(wildcard BMR/*.cpp BMR/network/*.cpp))
MINI_OT = OT/OTTripleSetup.o OT/BaseOT.o $(LIBSIMPLEOT)
VMOBJS = $(PROCESSOR) $(COMMONOBJS) GC/square64.o GC/Instruction.o OT/OTTripleSetup.o OT/BaseOT.o $(LIBSIMPLEOT)
VM = $(MINI_OT) $(SHAREDLIB)
COMMON = $(SHAREDLIB)
TINIER =  Machines/Tinier.o $(OT)
SPDZ = Machines/SPDZ.o $(TINIER)


LIB = libSPDZ.a
SHAREDLIB = libSPDZ.so
FHEOFFLINE = libFHE.so
LIBRELEASE = librelease.a


LIBSIMPLEOT = SimpleOT/libsimpleot.a

# used for dependency generation
OBJS = $(BMR) $(FHEOBJS) $(TINYOTOFFLINE) $(YAO) $(COMPLETE) $(patsubst %.cpp,%.o,$(wildcard Machines/*.cpp Utils/*.cpp))
DEPS := $(wildcard */*.d */*/*.d)

# never delete
.SECONDARY: $(OBJS) $(patsubst %.cpp,%.o,$(wildcard */*.cpp))


all: arithmetic binary gen_input online offline externalIO bmr
vm: arithmetic binary

.PHONY: doc
doc:
	cd doc; $(MAKE) html

arithmetic: rep-ring rep-field shamir semi2k-party.x semi-party.x mascot sy dealer-ring-party.x
binary: rep-bin yao semi-bin-party.x tinier-party.x tiny-party.x ccd-party.x malicious-ccd-party.x real-bmr

all: overdrive she-offline
arithmetic: semi-he gear

-include $(DEPS)
include $(wildcard *.d static/*.d)

%.o: %.cpp
	$(CXX) -o $@ $< $(CFLAGS) -MMD -MP -c

online: Fake-Offline.x Server.x Player-Online.x Check-Offline.x emulate.x

offline: $(OT_EXE) Check-Offline.x mascot-offline.x cowgear-offline.x mal-shamir-offline.x

gen_input: gen_input_f2n.x gen_input_fp.x

externalIO: bankers-bonus-client.x

bmr: bmr-program-party.x bmr-program-tparty.x

real-bmr: $(patsubst Machines/%.cpp,%.x,$(wildcard Machines/*-bmr-party.cpp))

yao: yao-party.x

she-offline: Check-Offline.x spdz2-offline.x

overdrive: simple-offline.x pairwise-offline.x cnc-offline.x gear
gear: cowgear-party.x chaigear-party.x lowgear-party.x highgear-party.x
semi-he: hemi-party.x soho-party.x temi-party.x

rep-field: malicious-rep-field-party.x replicated-field-party.x ps-rep-field-party.x

rep-ring: replicated-ring-party.x brain-party.x malicious-rep-ring-party.x ps-rep-ring-party.x rep4-ring-party.x

rep-bin: replicated-bin-party.x malicious-rep-bin-party.x ps-rep-bin-party.x Fake-Offline.x

replicated: rep-field rep-ring rep-bin

spdz2k: spdz2k-party.x ot-offline.x Check-Offline-Z2k.x galois-degree.x Fake-Offline.x
mascot: mascot-party.x spdz2k mama-party.x

ifeq ($(OS), Darwin)
tldr: mac-setup
else
tldr: mpir linux-machine-setup
endif

tldr:
	$(MAKE) mascot-party.x

ifeq ($(MACHINE), aarch64)
tldr: simde/simde
endif

shamir: shamir-party.x malicious-shamir-party.x atlas-party.x galois-degree.x

sy: sy-rep-field-party.x sy-rep-ring-party.x sy-shamir-party.x



$(LIBRELEASE): Protocols/MalRepRingOptions.o $(PROCESSOR) $(COMMONOBJS) $(TINIER) $(GC)
	$(AR) -csr $@ $^

CFLAGS += -fPIC
LDLIBS += -Wl,-rpath -Wl,$(CURDIR)

$(SHAREDLIB): $(PROCESSOR) $(COMMONOBJS) GC/square64.o GC/Instruction.o
	$(CXX) $(CFLAGS) -shared -o $@ $^ $(LDLIBS)

$(FHEOFFLINE): $(FHEOBJS) $(SHAREDLIB)
	$(CXX) $(CFLAGS) -shared -o $@ $^ $(LDLIBS)

static/%.x: Machines/%.o $(LIBRELEASE) $(LIBSIMPLEOT)
	$(CXX) $(CFLAGS) -o $@ $^ -Wl,-Map=$<.map -Wl,-Bstatic -static-libgcc -static-libstdc++  $(LIBRELEASE) $(LIBSIMPLEOT) $(BOOST) $(LDLIBS) -Wl,-Bdynamic -ldl


static-dir:
	@ mkdir static 2> /dev/null; true

static-release: static-dir $(patsubst Machines/%.cpp, static/%.x, $(wildcard Machines/*-party.cpp)) static/emulate.x



%.x: Utils/%.o $(COMMON)
	$(CXX) -o $@ $(CFLAGS) $^ $(LDLIBS)

%.x: Machines/%.o $(MINI_OT) $(SHAREDLIB)
	$(CXX) -o $@ $(CFLAGS) $^ $(LDLIBS)


pii.x: ibs/pii.o ibs/P256Element.o ibs/ibsElement.o $(VM)
	$(CXX) -o $@ $(CFLAGS) $^ $(LDLIBS) $(LIBRELIC)

ibs.x: ibs/ibs.o ibs/P256Element.o ibs/ibsElement.o $(VM)
	$(CXX) -o $@ $(CFLAGS) $^ $(LDLIBS) $(LIBRELIC)



pii.x: $(OT) $(LIBSIMPLEOT)
ibs.x: $(OT) $(LIBSIMPLEOT)


ifeq ($(AVX_OT), 1)
$(LIBSIMPLEOT): SimpleOT/Makefile
	$(MAKE) -C SimpleOT

OT/BaseOT.o: SimpleOT/Makefile

SimpleOT/Makefile:
	git submodule update --init SimpleOT
endif

ifeq ($(MACHINE), aarch64)
mac-machine-setup:
	-echo ARCH = >> CONFIG.mine
linux-machine-setup:
	-echo ARCH = -march=armv8.2-a+crypto >> CONFIG.mine
else
mac-machine-setup:
linux-machine-setup:
endif

simde/simde:
	git submodule update --init simde || git clone http://github.com/simd-everywhere/simde

clean:
	-rm -f */*.o *.o */*.d *.d *.x core.* *.a gmon.out */*/*.o static/*.x *.so
