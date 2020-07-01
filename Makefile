
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

# 5c5fb76psr7v7w8s84qgvnlg	
# docker run --rm \
# 		-v ${PWD}/.cache/vendor/bundle:/var/www/pluck/bundlecache \
# 		-v ${PWD}/.cache/public:/var/www/pluck/publiccache \
# 		${ASSET_IMAGE} /bin/sh -c "cp -rf vendor/bundle/* bundlecache/ && cp -rf public/* publiccache/"

# docker run --rm \
# 	-v ${PWD}/../cache/yarn_cache:/var/www/pluck/nodecache \
# 	${ASSET_IMAGE} /bin/sh -c 'CACHE_DIR=$$(yarn cache dir) && cp -rf $${CACHE_DIR} nodecache/'		

buildassets:
	$(eval IMAGE=localhost/pluck:test10)
	$(eval ASSET_IMAGE=localhost/assets:latest)
	DOCKER_BUILDKIT=1 docker build -f Dockerfile.app --cache-from localhost/assets:latest -t localhost/assets:latest --target assets . 
	# DOCKER_BUILDKIT=1 docker build -f Dockerfile.app --cache-from localhost/assets:latest --build-arg BUILDKIT_INLINE_CACHE=1 -t localhost/assets:latest --target assets . 

buildassets3:
	$(eval IMAGE=localhost/pluck:test10)
	$(eval ASSET_IMAGE=localhost/assets:latest)
	
	mkdir -p ${PWD}/.cache/vendor/bundle
	mkdir -p ${PWD}/.cache/public/assets
	mkdir -p ${PWD}/.cache/public/packs
	mkdir -p ${PWD}/.cache/yarn_cache
	
	mv -f ${PWD}/.cache/vendor/bundle/** ${PWD}/vendor/bundle/
	mv -f ${PWD}/.cache/public/assets ${PWD}/public/
	mv -f ${PWD}/.cache/public/packs ${PWD}/public/
	mv -f ${PWD}/.cache/yarn_cache ${PWD}/
	# cp -rf ${PWD}/.cache/vendor/bundle ${PWD}/vendor/
	# cp -rf ${PWD}/.cache/public/assets ${PWD}/public/assets
	# cp -rf ${PWD}/.cache/public/packs ${PWD}/public/packs
	# cp -rf ${PWD}/.cache/yarn_cache ${PWD}/yarn_cache
	DOCKER_BUILDKIT=1 docker build -f Dockerfile.app -t localhost/assets:latest --target assets .
	
	rm -rf ${PWD}/vendor/bundle/ruby
	rm -rf ${PWD}/public/assets
	rm -rf ${PWD}/public/packs
	rm -rf ${PWD}/yarn_cache/**


	docker create -ti --name dummy ${ASSET_IMAGE} /bin/bash
	docker cp dummy:/var/www/pluck/vendor/bundle $(PWD)/.cache/vendor
	docker cp dummy:/var/www/pluck/public $(PWD)/.cache/
	docker cp dummy:/var/www/pluck/yarn_cache $(PWD)/.cache/
	docker rm -f dummy

buildfinal:	
	$(eval IMAGE=localhost/pluck:test10)
	DOCKER_BUILDKIT=1 docker build -f Dockerfile.app --cache-from localhost/assets:latest -t ${IMAGE} --target final .

buildpluck2:
	$(eval IMAGE=localhost/pluck:test10)
	$(eval ASSET_IMAGE=localhost/assets:latest)
	
	mkdir -p ${PWD}/.cache/vendor/bundle
	mkdir -p ${PWD}/.cache/public/assets
	mkdir -p ${PWD}/.cache/public/packs
	mkdir -p ${PWD}/.cache/yarn_cache
	
	cp -rf ${PWD}/.cache/vendor/bundle ${PWD}/vendor/
	cp -rf ${PWD}/.cache/public/assets ${PWD}/public/assets
	cp -rf ${PWD}/.cache/public/packs ${PWD}/public/packs
	cp -rf ${PWD}/.cache/yarn_cache ${PWD}/yarn_cache
	docker build -f Dockerfile.app -t localhost/assets:latest --target assets .
	
	rm -rf ${PWD}/vendor/bundle/ruby
	rm -rf ${PWD}/public/assets
	rm -rf ${PWD}/public/packs
	rm -rf ${PWD}/yarn_cache/**


	docker create -ti --name dummy ${ASSET_IMAGE} /bin/bash
	docker cp dummy:/var/www/pluck/vendor/bundle $(PWD)/.cache/vendor
	docker cp dummy:/var/www/pluck/public $(PWD)/.cache/
	docker cp dummy:/var/www/pluck/yarn_cache $(PWD)/.cache/
	docker rm -f dummy

	

	docker build -f Dockerfile.app -t ${IMAGE} --target final .

run:
	$(eval KUBECONFIG=${PWD}/../layerkeep-infra/staging)
	$(eval ELASTIC_PWD=cfxrt6lf8fk7vj9m66946hcd)
# $(eval ELASTIC_PWD=$(shell cd ${PWD}/../layerkeep-infra/staging && kubectl get secret layerkeep-es-elastic-user -n elastic-system --template={{.data.elastic}} | base64 -d))
	echo "${ELASTIC_PWD}"
	docker run -it -p 3002:3002 -p 5432 -p 9200 \
	-e RAILS_LOG_TO_STDOUT=true \
	-e RAILS_SERVE_STATIC_FILES=true \
	-e SECRET_KEY_BASE=1234 \
	-e PG_HOST=host.docker.internal \
	-e PG_PASSWORD=d22LFEbD4zUATJT0 \
	-e ELASTIC_PWD=${ELASTIC_PWD} \
	-e ELASTICSEARCH_URL="https://elastic:$(ELASTIC_PWD)@host.docker.internal:9200" \
	localhost/pluck:test10 bundle exec rails s -p 3002 -b 0.0.0.0
	#/bin/bash 


# --mount type=bind,source="$(PWD)/.cache/vendor/bundle",target=/var/www/pluck/bundlecache2,consistency=cached \
# 		${IMAGE} /bin/sh -c "cp -rf vendor/bundle/* bundlecache/"

cacheit2:
	$(eval IMAGE=localhost/assets:latest)
	docker create -ti --name dummy ${IMAGE} /bin/bash
	docker cp dummy:/var/www/pluck/vendor/bundle $(PWD)/.cache/vendor
	docker cp dummy:/var/www/pluck/public $(PWD)/.cache/
	docker rm -f dummy

# 	--mount type=bind,source="$(PWD)/.cache/vendor/bundle",target=/var/www/pluck/bundlecache2,consistency=cached \
# 	${IMAGE} /bin/sh -c "cp -rf vendor/bundle/* bundlecache/"

cacheit:
	docker run --privileged --rm \		
		-v $(PWD)/.cache/vendor/bundle:/var/www/pluck/bundlecache \
		-v $(PWD)/.cache/public:/var/www/pluck/publiccache \
		${IMAGE} /bin/sh -c "cp -rf vendor/bundle/* bundlecache/ && cp -rf public/* publiccache/"

cacheyarn:
	$(eval IMAGE=localhost/pluck:test7)
	echo ${IMAGE}
	docker run --rm \
	-v ${PWD}/yarn_cache:/var/www/pluck/nodecache \
	${IMAGE} /bin/sh -c 'CACHE_DIR=$$(yarn cache dir) && cp -rf $${CACHE_DIR} nodecache/'
	
# ${IMAGE} /bin/sh -c 'CACHE_DIR=$$(yarn cache dir) cp -rf $${CACHE_DIR} nodecache/'
# ${IMAGE} /bin/sh -c 'echo $$(yarn cache dir)'