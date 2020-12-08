GO_BIN_PATH = bin
GO_SRC_PATH = src
C_BUILD_PATH = build

NF = $(C_NF)
C_NF = upf

VERSION = $(shell git describe --tags)
BUILD_TIME = $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
COMMIT_HASH = $(shell git submodule status | $(@F) | awk '{print $$(1)}' | cut -c1-8)
COMMIT_TIME = $(shell cd $(@F) && git log --pretty="%ai" -1 | awk '{time=$$(1)"T"$$(2)"Z"; print time}')
LDFLAGS = -X free5gc/src/$(@F)/version.VERSION=$(VERSION) \
          -X free5gc/src/$(@F)/version.BUILD_TIME=$(BUILD_TIME) \
          -X free5gc/src/$(@F)/version.COMMIT_HASH=$(COMMIT_HASH) \
          -X free5gc/src/$(@F)/version.COMMIT_TIME=$(COMMIT_TIME)


.PHONY: $(NF) clean

all: $(NF)

$(C_NF): % :
	@echo "Start building $@...."
	rm -rf $(C_BUILD_PATH) && \
	mkdir -p $(C_BUILD_PATH) && \
	cd ./$(C_BUILD_PATH) && \
	cmake .. && \
	make -j$(nproc)

clean:
	rm -rf $(addprefix $(GO_BIN_PATH)/, $(GO_NF))
	rm -rf $(addprefix $(GO_SRC_PATH)/, $(addsuffix /$(C_BUILD_PATH), $(C_NF)))

