# create Mojolicious::Lite one server script from src/* sources
build:
	cat ./src/mojolicious-lite-radio-box-server.pl | ./helpers/build_result_script.pl > ./mojolicious-radio-box.pl
	chmod a+x mojolicious-radio-box.pl

test-syntax:
	perl -c ./mojolicious-radio-box.pl

run:
	./mojolicious-radio-box.pl

# run for develop (auto update new code)
run-dev:
	morbo --listen 'http://*:8080' ./mojolicious-radio-box.pl

# run as daemon
run-prod:
	hypnotoad ./mojolicious-radio-box.pl

# stop daemon
stop-prod:
	hypnotoad --stop ./mojolicious-radio-box.pl

# deploy to Raspberry Pi
# add before: git remote add raspberrypi ssh://raspberrypi.local/home/user/path_to.../mojolicious-radio-box
# and change config on RPi repo: git config receive.denyCurrentBranch ignore
# usage:
#   make deploy; ssh raspberrypi.local 'cd ~/path_to.../mojolicious-radio-box && git reset --hard'
deploy:
	git push raspberrypi
