BUNDLE = bundle exec

doc:
	@$(BUNDLE) jazzy \
		--swift-build-tool spm \
		--min-acl public \
		--module ImagineUICore \
		--no-hide-documentation-coverage \
		--theme fullwidth \
		--output ./docs \
		--documentation=./*.md

doc-publish: doc
	@$(MAKE) -C docs publish

repl:
	swift run --repl
