
all: dev

PORT=${PORT:-3001}
dev:
	@foreman start -f Procfile.dev -p ${PORT}

build:
	$(eval PL_COMMIT=$(shell git --git-dir=./.git rev-parse --short HEAD))
  # COMMIT=${LK_COMMIT} docker-compose build layerkeep
	docker build -t registry.digitalocean.com/frenzylabs/pluck:${PL_COMMIT} .

push:
	$(eval PL_COMMIT=$(shell git --git-dir=./.git rev-parse --short HEAD))	
	docker push registry.digitalocean.com/frenzylabs/pluck:${PL_COMMIT}


RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(RUN_ARGS):;@:)

release:	
	echo ${RUN_ARGS}
	yarn version --${RUN_ARGS}
	git push origin --follow-tags

prune-tags:
	git tag -l | xargs git tag -d && git fetch -t 
	