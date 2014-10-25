REBAR=/usr/bin/env rebar
ERL=/usr/bin/env erl
SRC=./src
BIN=./ebin
DEPS=./deps
APP=plank
CONF=./app.config

.PHONY: all build clean deps

all: clean build

build:
	$(REBAR) compile

clean:
	$(REBAR) clean

deps:
	$(REBAR) get-deps

update:
	$(REBAR) update-deps

run:
	$(ERL) -setcookie testcookie -pa $(DEPS)/*/ebin -pa $(BIN) -config $(CONF) -eval "application:ensure_all_started($(APP))"
