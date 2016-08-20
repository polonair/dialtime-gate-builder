.PHONY: all clean 

all:
	composer install
	mkdir -p build/DEBIAN
	mkdir -p build/etc/dialtime/gate
	mkdir -p build/etc/cron.d
	mkdir -p build/usr/bin
	mkdir -p build/usr/share/doc/dialtime-gate
	mkdir -p build/usr/share/dialtime/gate/app
	mkdir -p build/usr/share/dialtime/gate/vendor
	mkdir -p build/var/cache/dialtime/gate
	mkdir -p build/var/lib/dialtime/gate/records
	mkdir -p build/var/log/dialtime/gate
	cp config/* build/etc/dialtime/gate/
	cp bin/* build/usr/bin/
	cp app/* build/usr/share/dialtime/gate/app/
	cp -r vendor/* build/usr/share/dialtime/gate/vendor/
	cp -t build/DEBIAN deb/postinst deb/preinst deb/conffiles deb/config deb/templates
	sed -e "s/^Installed-size.*/Installed-size: `du -s build/ | grep -o [0-9]*`/" deb/control > build/DEBIAN/control
	cp deb-doc/* build/usr/share/doc/dialtime-gate/
	gzip -9 build/usr/share/doc/dialtime-gate/changelog
	cp cron/* build/etc/cron.d/
	chmod 0644 build/etc/dialtime/gate/* build/usr/share/doc/dialtime-gate/* build/DEBIAN/* build/etc/cron.d/dialtime-gate
	chmod 0755 build/DEBIAN/postinst build/DEBIAN/preinst build/DEBIAN/config build/usr/bin/*
	find build/usr/share/dialtime/gate -type f -exec chmod 644 {} \;
	find build/usr/share/dialtime/gate -type d -exec chmod 755 {} \;
	find build/usr/share/dialtime/gate/vendor/ -name '.git*' -exec unlink {} \;
	find build/usr/share/dialtime/gate/vendor/ -name 'LICENSE*' -exec unlink {} \;
	find build/usr/share/dialtime/gate/vendor/ -name '*.sh' -exec chmod 775 {} \;
	cd build; find usr/ -type f -exec md5deep -rl {} \; >> DEBIAN/md5sums
	cd build; find etc/ -type f -exec md5deep -rl {} \; >> DEBIAN/md5sums
	chmod 0644 build/DEBIAN/md5sums
	mkdir ./out
	fakeroot dpkg-deb --build build ./out

clean:
	rm -rf build vendor out
	rm -rf composer.lock
	rm -rf *.deb
	find ./ -name '*~' -exec unlink {} \;
