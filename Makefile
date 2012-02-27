name=voms-api-java
spec=spec/$(name).spec
version=$(shell grep "Version:" $(spec) | sed -e "s/Version://g" -e "s/[ \t]*//g")
release=1
rpmbuild_dir=$(shell pwd)/rpmbuild
stage_dir=dist

.PHONY: stage etics clean rpm

all: 	dist rpm

clean:	
		rm -rf target $(rpmbuild_dir) tgz RPMS dir

dist:
		mvn -B -s src/config/emi-build-settings.xml assembly:assembly

rpm:		
		mkdir -p 	$(rpmbuild_dir)/BUILD $(rpmbuild_dir)/RPMS \
					$(rpmbuild_dir)/SOURCES $(rpmbuild_dir)/SPECS \
					$(rpmbuild_dir)/SRPMS

		cp target/$(name)-$(version)-src.tar.gz $(rpmbuild_dir)/SOURCES/$(name)-$(version).tar.gz
		rpmbuild --nodeps -v -ba $(spec) --define "_topdir $(rpmbuild_dir)" 

etics: 	rpm
		mkdir -p tgz RPMS
		cp target/*.tar.gz tgz
		cp -r $(rpmbuild_dir)/RPMS/* $(rpmbuild_dir)/SRPMS/* RPMS

stage:	 
	mkdir -p $(stage_dir)
	
	for r in $(shell find $(rpmbuild_dir)/RPMS -name '*.rpm') ; do \
		echo "Istalling `basename $$r` in $(stage_dir)..."; \
		pushd . ; cp $$r $(stage_dir); cd $(stage_dir); \
		rpm2cpio `basename $$r` | cpio -idm; \
		rm `basename $$r`; popd; \
	done
