
asset_model_dar=./asset-model/.daml/dist/asset-model-0.0.1.dar

.PHONY: help
 help:	                                            ## Show list of available make targets
	@cat Makefile | grep -e "^[a-zA-Z_\-]*: *.*   ## *" | sort | awk 'BEGIN {FS = ":.*?   ## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: build-daml build-python install-scribe       ## Ensure the project is fully built and ready to run

.PHONY: build-daml
build-daml: ${asset_model_dar}

${asset_model_dar}: .damlsdk                        ## Build all Daml code in the project
	(cd asset-model && daml build)

.PHONY: test-daml
test-daml: target/daml-test-results.xml

target/daml-test-results.xml: ${asset_model_dar}
	(cd asset-model && daml test --junit ../target/daml-test-results.xml)

.PHONY: build-python
build-python: target/_gen/.gen                      ## Setup the Python Environment.

.PHONY: format-python
format-python: .venv                                ## Automatically reformat the Python code
	black python/*.py

.PHONY: clean
clean: stop-ledger                                  ## Reset the build to a clean state without any build targets
	(cd asset-model && daml clean)
	rm -fr .damlsdk .protobufs target
	rm -fr python/__pycache__
	rm -frv log/*

.PHONY: clean-all
clean-all: clean                                    ## Reset the build to a fully clean state, including the Python venv
	rm -rf .venv

.venv: requirements.txt
	mkdir -p target
	python3 -m venv .venv
	.venv/bin/pip3 install -r requirements.txt

.damlsdk: daml.yaml
	scripts/install-daml-sdk.sh $< $@

.protobufs: daml.yaml
	scripts/install-protobufs.sh $< $@ target

.PHONY: install-scribe                              ## Install Scribe
install-scribe: target/scribe.jar

target/scribe.jar: daml.yaml
	mkdir -p target
	scripts/install-pqs-scribe.sh $< $@

protobuf_tag = $(shell cat .protobufs)

target/_gen/.gen: .venv .protobufs
	mkdir -p target/_gen

	(cd target && unzip -o "protobufs-${protobuf_tag}.zip")

	.venv/bin/python3 -m grpc_tools.protoc \
	    -Ivendor \
		-I$$(find target -name "protos-*" -type d -print -quit) \
	    --python_out=target/_gen \
	    --pyi_out=target/_gen \
	    --grpc_python_out=target/_gen \
	    $$(find target -name "*.proto" -not -name "daml_lf*.proto") \
	    $$(find vendor -name "*.proto")

	touch target/_gen/.gen

.PHONY: run
run: target/_gen/.gen ${asset_model_dar} target/scribe.jar  ## Start a locally running sandbox ledger and PQS instance
	asset_model_dar=${asset_model_dar} .venv/bin/honcho start

.PHONY: drop-pqs-db
drop-pqs-db:                                       ## Drop the local PQS database
	scripts/drop-pqs-db.sh
