PROJECT = gs2_
REGNAME = $(PROJECT)registry
REDCACHE = $(PROJECT)redis
REGCONTAINER = $(REGNAME)_daemon
FRONTEND = $(REGNAME)_gui
IMG_SOURCE = 

all: run

build:
	docker build -t $(REGNAME) .

run:
	mkdir -p /data/registry/storage
	mkdir -p /data/registry/index
	docker run -d --name $(REDCACHE) $(IMG_SOURCE)redis:latest
	docker run -d -v /data/registry/storage:/opt/registry -v /data/registry/index:/opt/index -p 5000:5000 --link $(REDCACHE):redis --name $(REGCONTAINER) $(IMG_SOURCE)h3nrik/simple-registry:latest
	docker run -d -e ENV_DOCKER_REGISTRY_HOST=0.0.0.0.5000 -e ENV_DOCKER_REGISTRY_PORT=5000 -p 0.0.0.0:5001:80 --name $(FRONTEND) $(IMG_SOURCE)konradkleine/docker-registry-frontend:latest

stop:
	docker stop $(FRONTEND)
	docker stop $(REGCONTAINER)
	docker stop $(REDCACHE)

clean: 
	docker rm -v $(FRONTEND)
	docker rm -v $(REGCONTAINER)
	docker rm -v $(REDCACHE)
