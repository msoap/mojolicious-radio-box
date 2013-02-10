build:
	cat ./src/mojolicious-lite-radio-box-server.pl | ./helpers/build_result_script.pl > ./mojolicious-radio-box.pl
	chmod a+x mojolicious-radio-box.pl

test-syntax:
	perl -c ./mojolicious-radio-box.pl

run:
	morbo --listen 'http://*:8080' ./mojolicious-radio-box.pl

run-prod:
	hypnotoad ./mojolicious-radio-box.pl

stop-prod:
	hypnotoad --stop ./mojolicious-radio-box.pl
