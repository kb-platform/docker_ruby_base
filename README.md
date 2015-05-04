To build a new image

./bin/docker_build


Then push the image


For QUAY:

docker tag REF quay.io/marcusbaguley/docker_ruby_base
docker push quay.io/marcusbaguley/docker_ruby_base

# FOR docker.io which we are not using: ./bin/docker_push
