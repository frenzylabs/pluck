
all: dev

dev:
	@foreman start -f Procfile.dev -p 3000

build:
	$(eval PL_COMMIT=$(shell git --git-dir=./.git rev-parse --short HEAD))
  # COMMIT=${LK_COMMIT} docker-compose build layerkeep
	docker build -t layerkeep/pluck:${PL_COMMIT} .

push:
	$(eval PL_COMMIT=$(shell git --git-dir=./.git rev-parse --short HEAD))	
	docker push layerkeep/pluck:${PL_COMMIT}
