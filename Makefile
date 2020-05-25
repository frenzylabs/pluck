
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
