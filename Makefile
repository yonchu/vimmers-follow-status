.PHONY: build release

COFFEE=coffee
LESSC=lessc

build:
	@$(COFFEE) -c -o contents/js  src/coffee/*.coffee
	@$(LESSC)  src/less/vimmers.less contents/css/vimmers.css

release: build
	@cd contents && zip -r ../release.zip ./
