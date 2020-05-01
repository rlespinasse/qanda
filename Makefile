.PHONY: build publish run run-sample build-test test

build: 
	@docker build -t rlespinasse/qanda .

publish:
	@docker push rlespinasse/qanda

FILE?=
run:
	@docker run -it -v $(PWD):/data rlespinasse/qanda $(FILE)

SAMPLE?=samples/simple_question.puml
run-sample:
	@docker run -it -v $(PWD):/data rlespinasse/qanda $(SAMPLE)

build-test:
	@docker build -t rlespinasse/bats-qanda .github/actions/bats

test: build-test
	@docker run -it -v $(PWD):/code -w '/code' rlespinasse/bats-qanda:latest
